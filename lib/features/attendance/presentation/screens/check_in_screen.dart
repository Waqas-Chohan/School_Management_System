import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/attendance.dart';
import '../providers/attendance_providers.dart';

/// Check-In / Check-Out screen reached from the dashboard "My Attendance"
/// quick action (Figma frame 2147224601). Reproduces the design: a large live
/// clock, the Check-in Time / Working Hours / Check-out Time summary card, a
/// full-width slide bar (slide RIGHT to Check In, slide LEFT to Check Out) and
/// a matching pill button.
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

/// Formats a [DateTime] as a 12-hour clock label: "9:41 AM".
String _formatClock(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  final period = t.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

/// Formats a [Duration] as "7h 15m" (or "45m", "2h").
String _formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes % 60;
  if (hours == 0) return '${minutes}m';
  if (minutes == 0) return '${hours}h';
  return '${hours}h ${minutes}m';
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;

  bool _checkedIn = false;

  /// Set true right after a successful check-in/out so the follow-up summary
  /// re-fetch (triggered by the controller invalidating the provider) does not
  /// overwrite the authoritative times returned by the action itself.
  bool _actionApplied = false;

  /// Guards concurrent actions: while true, a second check-in/check-out (e.g. a
  /// quick re-drag of the slider) and/or popping the screen is blocked until the
  /// in-flight request + success dialog settles, so two POSTs or a pop can never
  /// race the Navigator's route transition.
  bool _busy = false;

  DateTime _clock = DateTime.now();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() => _clock = DateTime.now());
    });
  }

  /// Syncs the card from today's attendance row returned by the API. The portal
  /// keeps a single row per teacher/day and reuses it across check-in/check-out,
  /// leaving the previous day's `checkOut` stamped on the row. A checkout only
  /// "counts" when it happened at-or-after today's check-in time, otherwise the
  /// stale value is ignored so the slide stays in the checked-in position.
  void _syncFromApi(AttendanceSummary? summary) {
    // Never clobber times that came from a successful check-in/out action.
    if (_actionApplied) return;
    if (summary == null || summary.history.isEmpty) {
      setState(() {
        _checkedIn = false;
        _checkIn = null;
        _checkOut = null;
      });
      return;
    }
    // Prefer the most recent attendance row (the server day can lag the device).
    final latest = _latestEntry(summary.history);
    final inTime = _parseTime(latest.inTime);
    final outTime = _parseTime(latest.outTime);
    final checkedOut =
        outTime != null && (inTime == null || !outTime.isBefore(inTime));
    setState(() {
      _checkIn = inTime;
      _checkOut = checkedOut ? outTime : null;
      _checkedIn = inTime != null && !checkedOut;
    });
  }

  /// Manual pull-to-refresh: re-syncs from the live summary (clears the
  /// post-action guard).
  Future<void> _refreshFromApi() async {
    _actionApplied = false;
    final fresh = await ref.refresh(attendanceSummaryProvider.future);
    _syncFromApi(fresh);
  }

  /// Returns the entry carrying the latest calendar date.
  static AttendanceLogEntry _latestEntry(List<AttendanceLogEntry> entries) {
    var best = entries.first;
    DateTime? bestDate = _parseDateOnly(best.date);
    for (final entry in entries.skip(1)) {
      final date = _parseDateOnly(entry.date);
      if (date != null && (bestDate == null || date.isAfter(bestDate))) {
        best = entry;
        bestDate = date;
      }
    }
    return best;
  }

  static DateTime? _parseDateOnly(String raw) {
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
    if (iso != null) {
      return DateTime(
        int.parse(iso.group(1)!),
        int.parse(iso.group(2)!),
        int.parse(iso.group(3)!),
      );
    }
    final slash = RegExp(r'^(\d{2})/(\d{2})/(\d{4})').firstMatch(raw);
    if (slash != null) {
      return DateTime(
        int.parse(slash.group(3)!),
        int.parse(slash.group(2)!),
        int.parse(slash.group(1)!),
      );
    }
    return DateTime.tryParse(raw);
  }

  static DateTime? _parseTime(String raw) {
    final match = RegExp(
      r'(\d{1,2}):(\d{2})\s?(AM|PM)?',
      caseSensitive: false,
    ).firstMatch(raw);
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)?.toUpperCase() ?? '';
    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  Future<void> _performCheckIn() async {
    if (_busy) return;
    _busy = true;
    try {
      final controller = ref.read(checkInOutControllerProvider.notifier);
      final result = await controller.checkIn();
      if (!mounted) return;
      // Use the server's own timestamp so the card shows the live API time.
      final apiIn = result != null ? _parseTime(result.checkIn ?? '') : null;
      setState(() {
        _checkedIn = true;
        _actionApplied = true;
        _checkIn = apiIn ?? DateTime.now();
        _checkOut = null; // Check-in clears any stale checkout.
      });
      _showStatusDialog(
        title: 'Checked In Successfully!',
        message:
            'You have checked in at ${_formatClock(_checkIn ?? DateTime.now())}.\n'
            'Have a productive day!',
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> _performCheckOut() async {
    if (_busy) return;
    _busy = true;
    try {
      final controller = ref.read(checkInOutControllerProvider.notifier);
      final result = await controller.checkOut();
      if (!mounted) return;
      final apiOut = result != null ? _parseTime(result.checkOut ?? '') : null;
      setState(() {
        _checkedIn = false;
        _actionApplied = true;
        _checkOut = apiOut ?? DateTime.now();
      });
      _showStatusDialog(
        title: 'Checked Out Successfully!',
        message:
            'You have checked out at ${_formatClock(_checkOut ?? DateTime.now())}.\n'
            'Working hours: ${_workingHoursLabel(_checkOut ?? DateTime.now())}',
      );
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _dateLabel {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[_clock.weekday - 1]}, '
        '${months[_clock.month - 1]} ${_clock.day}, ${_clock.year}';
  }

  String _workingHoursLabel(DateTime end) {
    final checkIn = _checkIn;
    return checkIn == null ? '0m' : _formatDuration(end.difference(checkIn));
  }

  Future<void> _showStatusDialog({
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.fromLTRB(45, 24, 45, 24),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Green check inside a soft-green circle.
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF15803D),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF161616),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF737373),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch that today's attendance loads so the check-in card reflects the
    // server state when the screen opens (and re-syncs after the controller
    // invalidates the provider on a successful check-in / check-out).
    ref.listen<AsyncValue<AttendanceSummary>>(attendanceSummaryProvider, (
      prev,
      next,
    ) {
      if (next is AsyncData<AttendanceSummary>) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _syncFromApi(next.value));
        });
      }
    });
    // Keep the provider subscribed so rebuilds track the latest summary.
    ref.watch(attendanceSummaryProvider);
    final summaryEnd = _checkOut ?? _clock;

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              // Ignore pops while an action is in flight, or when this route is
              // no longer current (e.g. the success dialog is on top) — popping
              // mid-transition is what raced the Navigator and produced the
              // `AnimationController` / `_userGesturesInProgress` assertions.
              if (_busy) return;
              final route = ModalRoute.of(context);
              if (route == null || !route.isCurrent) return;
              context.pop();
            },
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          title: Text(
            'My Attendance',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF161616),
            ),
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: _refreshFromApi,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                // Large current time (Figma "9:41 AM").
                Text(
                  _formatClock(_clock),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF161616),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _dateLabel,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF737373),
                  ),
                ),
                const SizedBox(height: 24),
                _StatsCard(
                  checkIn: _checkIn,
                  checkOut: _checkOut,
                  end: summaryEnd,
                ),
                const SizedBox(height: 18),
                // Single slide control: slide RIGHT to check in, slide LEFT to
                // check out. The handle stays at the far right while checked in.
                _SlideActionBar(
                  checkedIn: _checkedIn,
                  onCheckIn: _performCheckIn,
                  onCheckOut: _performCheckOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A vertical divider between the three summary cells.
class _CellDivider extends StatelessWidget {
  const _CellDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 46, color: const Color(0xFFE8ECF0));
  }
}

/// One statistic cell inside the summary card.
class _StatsCell extends StatelessWidget {
  const _StatsCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF161616),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF737373),
            ),
          ),
        ],
      ),
    );
  }
}

/// Check-in Time / Working Hours / Check-out Time summary card.
class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.checkIn,
    required this.checkOut,
    required this.end,
  });

  final DateTime? checkIn;
  final DateTime? checkOut;
  final DateTime end;

  @override
  Widget build(BuildContext context) {
    final workingHours = checkIn == null
        ? Duration.zero
        : end.difference(checkIn!);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Row(
        children: [
          _StatsCell(
            icon: Icons.login_rounded,
            value: checkIn == null ? '--:--' : _formatClock(checkIn!),
            label: 'Check-in Time',
          ),
          const _CellDivider(),
          _StatsCell(
            icon: Icons.schedule_rounded,
            value: _formatDuration(workingHours),
            label: 'Working Hours',
          ),
          const _CellDivider(),
          _StatsCell(
            icon: Icons.logout_rounded,
            value: checkOut == null ? '--:--' : _formatClock(checkOut!),
            label: 'Check-out Time',
          ),
        ],
      ),
    );
  }
}

/// Full-width slide bar. The handle is at the LEFT with "Slide to Check In";
/// dragging it RIGHT past the midpoint triggers [onCheckIn] and the handle
/// animates to the RIGHT showing "Slide to Check Out". Dragging LEFT past the
/// midpoint triggers [onCheckOut].
///
/// A round arrow on the handle always points in the direction the knob needs
/// to travel for the next action: RIGHT while the knob sits on the left
/// (check in) and LEFT once the knob reaches the right side (check out); the
/// arrow smoothy flips 180° whenever the check-in state changes.
class _SlideActionBar extends StatefulWidget {
  const _SlideActionBar({
    required this.checkedIn,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  final bool checkedIn;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  @override
  State<_SlideActionBar> createState() => _SlideActionBarState();
}

class _SlideActionBarState extends State<_SlideActionBar> {
  static const double _handleSize = 60;
  static const double _trackHeight = 76;

  double _drag = 0;
  bool _dragging = false;

  void _endDrag(double offset, double maxDrag) {
    setState(() {
      _dragging = false;
      _drag = 0;
    });
    if (!widget.checkedIn && offset > maxDrag * 0.5) {
      widget.onCheckIn();
    } else if (widget.checkedIn && offset < maxDrag * 0.5) {
      widget.onCheckOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = (constraints.maxWidth - _handleSize).clamp(
          0.0,
          double.infinity,
        );
        final base = widget.checkedIn ? maxDrag : 0.0;
        final offset = (base + _drag).clamp(0.0, maxDrag);
        final label = widget.checkedIn
            ? 'Slide to Check Out'
            : 'Slide to Check In';

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => setState(() => _dragging = true),
          onHorizontalDragUpdate: (details) =>
              setState(() => _drag += details.delta.dx),
          onHorizontalDragEnd: (_) => _endDrag(offset, maxDrag),
          onHorizontalDragCancel: () => setState(() {
            _dragging = false;
            _drag = 0;
          }),
          child: Container(
            height: _trackHeight,
            decoration: BoxDecoration(
              color: const Color(0x262249DC),
              borderRadius: BorderRadius.circular(_trackHeight / 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Centered instruction label.
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.checkedIn
                                ? Icons.keyboard_double_arrow_left_rounded
                                : Icons.keyboard_double_arrow_right_rounded,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Sliding handle.
                AnimatedPositioned(
                  duration: _dragging
                      ? Duration.zero
                      : const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  left: offset,
                  top: (_trackHeight - _handleSize) / 2,
                  child: Container(
                    width: _handleSize,
                    height: _handleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4E6CF0), Color(0xFF2249DC)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF2249DC,
                          ).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: AnimatedRotation(
                      // Smoothly flips the handle arrow 180° when the state
                      // changes: points RIGHT (→) while the knob rests on the
                      // left before check-in, and points LEFT (←) once the knob
                      // reaches the right side after checking in.
                      turns: widget.checkedIn ? 0.5 : 0,
                      duration: _dragging
                          ? Duration.zero
                          : const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
