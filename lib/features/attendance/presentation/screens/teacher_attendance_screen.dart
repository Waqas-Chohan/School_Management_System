import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_dimensions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/attendance.dart';
import '../providers/attendance_providers.dart';

/// Teacher Attendance screen reproduced from the Figma "Teacher Attendance"
/// design (frame 92:1268): screen header, month selector pill, KPI summary
/// card with a circular progress ring, Summary stat cards, and the Recent
/// Attendance History log. Tapping the calendar chip opens a professional
/// monthly calendar; choosing a date filters the log to that day.
class TeacherAttendanceScreen extends ConsumerStatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  ConsumerState<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState
    extends ConsumerState<TeacherAttendanceScreen> {
  DateTime? _selectedDate;

  Future<void> _openCalendar() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AttendanceCalendarSheet(initialDate: _selectedDate),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(attendanceSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: Text(
          'Attendance',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF161616),
          ),
        ),
      ),
      body: SafeArea(
        child: summary.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF2249DC)),
          ),
          error: (error, _) => _AttendanceErrorView(
            message: error is AppFailure
                ? error.message
                : 'Unable to load attendance.',
            onRetry: () => ref.invalidate(attendanceSummaryProvider),
          ),
          data: (data) {
            // Filter the history log to the selected date, if any.
            final filteredHistory = _selectedDate == null
                ? data.history
                : data.history.where((h) => _matchesDate(h, _selectedDate!)).toList();

            return RefreshIndicator(
              color: const Color(0xFF2249DC),
              onRefresh: () => ref.refresh(attendanceSummaryProvider.future),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _MonthSelectorRow(
                    monthLabel: data.monthLabel,
                    selectedDate: _selectedDate,
                    onTap: _openCalendar,
                  ),
                  const SizedBox(height: 20),
                  _KpiCard(summary: data),
                  const SizedBox(height: 20),
                  _SummarySection(stats: data.stats),
                  const SizedBox(height: 20),
                  _HistorySection(history: filteredHistory),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  bool _matchesDate(AttendanceLogEntry entry, DateTime date) {
    // The mock uses "Mon, 4 Aug 2026" style — try day of week + day + month.
    final dateStr = entry.date;
    final dayMatch = RegExp(r'(\d{1,2})\s+(\w+)').firstMatch(dateStr);
    if (dayMatch == null) return true;
    final dayInt = int.tryParse(dayMatch.group(1) ?? '');
    final monthName = dayMatch.group(2);
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    final monthInt = months[monthName];
    return dayInt == date.day && monthInt == date.month;
  }
}
// ─── Month Selector Row (Figma 92:1277) ────────────────────────────────────

class _MonthSelectorRow extends StatelessWidget {
  const _MonthSelectorRow({
    required this.monthLabel,
    this.selectedDate,
    required this.onTap,
  });

  final String monthLabel;
  final DateTime? selectedDate;
  final VoidCallback onTap;

  String get _chipLabel {
    if (selectedDate == null) return 'Select Date';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${selectedDate!.day} ${months[selectedDate!.month - 1]} '
        '${selectedDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          monthLabel,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF161616),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: selectedDate == null
                    ? const Color(0xFFD9D9D9)
                    : const Color(0xFF2249DC),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: selectedDate == null
                      ? const Color(0xFF777777)
                      : const Color(0xFF2249DC),
                ),
                const SizedBox(width: 8),
                Text(
                  _chipLabel,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selectedDate == null
                        ? const Color(0xFF777777)
                        : const Color(0xFF2249DC),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: selectedDate == null
                      ? const Color(0xFF777777)
                      : const Color(0xFF2249DC),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── KPI Summary Card (Figma 92:1283) ──────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.summary});

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Circular progress ring (Figma 92:1284)
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: summary.percent / 100,
                  strokeWidth: 5.4,
                  color: const Color(0xFF2249DC),
                  backgroundColor: const Color(0xFFD9D9D9),
                ),
                Center(
                  child: Text(
                    '${summary.percent}%',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2249DC),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.headline,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF161616),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF737373),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ─── Summary stat cards (Figma 92:1681) ────────────────────────────────────

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.stats});

  final List<AttendanceStat> stats;

  static const Map<AttendanceStatType, Color> _dotColors = {
    AttendanceStatType.present: Color(0xFF10B981),
    AttendanceStatType.absent: Color(0xFFEF4444),
    AttendanceStatType.leave: Color(0xFFF59E0B),
    AttendanceStatType.late: Color(0xFFF97316),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF161616),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  stat: stats[i],
                  dotColor: _dotColors[stats[i].type] ?? const Color(0xFF10B981),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat, required this.dotColor});

  final AttendanceStat stat;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${stat.count}',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF161616),
            ),
          ),
        ],
      ),
    );
  }
}
// ─── Recent Attendance History (Figma 92:1704) ─────────────────────────────

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.history});

  final List<AttendanceLogEntry> history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Attendance History',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF161616),
          ),
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD9D9D9)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.event_busy_rounded,
                  size: 28,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(height: 8),
                Text(
                  'No attendance record for the selected date.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF737373),
                  ),
                ),
              ],
            ),
          )
        else
          for (final entry in history)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _HistoryItem(entry: entry),
            ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.entry});

  final AttendanceLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (entry.status) {
      AttendanceDayStatus.present => (
          const Color(0xFFE6F4EA),
          const Color(0xFF10B981),
        ),
      AttendanceDayStatus.absent => (
          const Color(0xFFFEE2E2),
          const Color(0xFFBC3429),
        ),
      AttendanceDayStatus.leave => (
          const Color(0xFFFEF3C7),
          const Color(0xFFF59E0B),
        ),
      AttendanceDayStatus.late => (
          const Color(0xFFFFEDD5),
          const Color(0xFFF97316),
        ),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF161616),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.inTime} • ${entry.outTime}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF737373),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              entry.statusLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error view ────────────────────────────────────────────────────────────

class _AttendanceErrorView extends StatelessWidget {
  const _AttendanceErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.defaultHorizontalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 46,
              color: Color(0xFFC24040),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF161616),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
// ─── Professional monthly calendar sheet (blue #2249DC theme) ───────────────

class _AttendanceCalendarSheet extends StatefulWidget {
  const _AttendanceCalendarSheet({this.initialDate});

  final DateTime? initialDate;

  @override
  State<_AttendanceCalendarSheet> createState() =>
      _AttendanceCalendarSheetState();
}

class _AttendanceCalendarSheetState extends State<_AttendanceCalendarSheet> {
  static const List<String> _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  late DateTime _visibleMonth;
  late DateTime _selected;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    final base = widget.initialDate ?? DateTime.now();
    _selected = base;
    _visibleMonth = DateTime(base.year, base.month);
  }

  void _confirmDay(DateTime date) {
    Navigator.of(context).pop(date);
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int get _totalRows {
    final days = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final offset = _visibleMonth.weekday % 7;
    return ((offset + days) / 7).ceil();
  }
@override
  Widget build(BuildContext context) {
    final days = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final offset = _visibleMonth.weekday % 7;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left_rounded,
                    size: 24, color: Color(0xFF3B5BDB)),
              ),
              Column(
                children: [
                  Text(
                    '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B5BDB),
                    ),
                  ),
                  if (_selected.month == _visibleMonth.month &&
                      _selected.year == _visibleMonth.year)
                    Text(
                      'Selected: ${_selectedLabel()}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF737373),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: Color(0xFF777777)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Weekday header
          Row(
            children: [
              for (final w in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Day grid
          for (var row = 0; row < _totalRows; row++) ...[
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(child: _dayCell(row, col, offset)),
              ],
            ),
            if (row < _totalRows - 1) const SizedBox(height: 4),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: days == 0 ? null : () => _confirmDay(_selected),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2249DC),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              child: Text(
                'Apply Date',
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
    );
  }

  Widget _dayCell(int row, int col, int offset) {
    final dayNum = row * 7 + col - offset + 1;
    final days = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    if (dayNum < 1 || dayNum > days) return const SizedBox.shrink();

    final date = DateTime(_visibleMonth.year, _visibleMonth.month, dayNum);
    final isToday = _isSameDay(date, _today);
    final isSelected = _isSameDay(date, _selected);

    return InkWell(
      onTap: () => _confirmDay(date),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2249DC) : null,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$dayNum',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: (isSelected || isToday) ? FontWeight.w700 : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : isToday
                    ? const Color(0xFF2249DC)
                    : const Color(0xFF1A1A2E),
          ),
        ),
      ),
    );
  }

  String _selectedLabel() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${_selected.day} ${months[_selected.month - 1]} ${_selected.year}';
  }
}