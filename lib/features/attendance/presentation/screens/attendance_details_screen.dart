import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/class_attendance.dart';
import '../providers/class_attendance_providers.dart';
import '../widgets/attendance_status_radio.dart';
import '../widgets/attendance_success_dialog.dart';

/// "Attendance Details" screen (Figma frames 65:7291 / 65:7469). Shows the
/// saved attendance sheet for a class: the title header with a pencil
/// (edit_square) button, the 2x2 summary stats bar (Presents / Absents /
/// Leaves / Late Arrivals), and one row per student with a status pill.
///
/// Tapping the pencil switches to edit mode: each row becomes the P/A/L/LA
/// radio buttons pre-filled with the saved statuses, and a bottom bar with
/// **Discard** + **Submit Changes** appears. Submitting shows the
/// "Updated Successfully!" dialog and returns to the read-only sheet.
class AttendanceDetailsScreen extends ConsumerStatefulWidget {
  const AttendanceDetailsScreen({super.key, required this.classId});

  final String classId;

  @override
  ConsumerState<AttendanceDetailsScreen> createState() =>
      _AttendanceDetailsScreenState();
}

class _AttendanceDetailsScreenState
    extends ConsumerState<AttendanceDetailsScreen> {
  bool _isEditing = false;
  Map<String, StudentAttendanceStatus> _editStatuses = {};

  void _enterEditMode(ClassAttendance data) {
    final seeded = Map<String, StudentAttendanceStatus>.of(data.savedStatuses);
    for (final s in data.students) {
      seeded.putIfAbsent(s.id, () => StudentAttendanceStatus.present);
    }
    setState(() {
      _isEditing = true;
      _editStatuses = seeded;
    });
  }

  void _leaveEditMode() => setState(() => _isEditing = false);

  void _setStatus(String studentId, StudentAttendanceStatus status) {
    setState(() => _editStatuses[studentId] = status);
  }

  Future<void> _submitUpdate(ClassAttendance data) async {
    final controller = ref.read(
      submitClassAttendanceControllerProvider.notifier,
    );
    final result = await controller.submit(
      classId: widget.classId,
      statusByStudent: _editStatuses,
    );
    if (!mounted) return;
    if (!result) {
      final error = controller.errorOrNull;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.message ?? 'Unable to update attendance.'),
        ),
      );
      return;
    }
    // Live counts for the success dialog.
    var present = 0, absent = 0, leave = 0, late = 0;
    for (final s in _editStatuses.values) {
      switch (s) {
        case StudentAttendanceStatus.present:
          present++;
        case StudentAttendanceStatus.absent:
          absent++;
        case StudentAttendanceStatus.leave:
          leave++;
        case StudentAttendanceStatus.late:
          late++;
      }
    }
    await AttendanceSuccessDialog.show(
      context,
      title: 'Updated Successfully!',
      message:
          'Attendance for ${data.teacherClass.bulletName} has been '
          'updated successfully.',
      present: present,
      absent: absent,
      leave: leave,
      late: late,
    );
    if (!mounted) return;
    setState(() => _isEditing = false);
    ref.invalidate(savedClassAttendanceProvider(widget.classId));
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(savedClassAttendanceProvider(widget.classId));

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
      body: saved.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, _) => _DetailsErrorView(
          message: error is AppFailure
              ? error.message
              : 'Unable to load attendance.',
          onRetry: () =>
              ref.invalidate(savedClassAttendanceProvider(widget.classId)),
        ),
        data: (data) => _AttendanceDetailsBody(
          data: data,
          isEditing: _isEditing,
          editStatuses: _editStatuses,
          onEditTap: _isEditing
              ? () => _leaveEditMode()
              : () => _enterEditMode(data),
          onStatusChanged: _setStatus,
        ),
      ),
      bottomNavigationBar: saved.maybeWhen(
        data: (data) => _isEditing
            ? _EditActionsBar(
                onDiscard: _leaveEditMode,
                onSubmit: () => _submitUpdate(data),
              )
            : const SizedBox.shrink(),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

/// Scrollable body: details header (title + pencil + subtitle), stats bar and
/// the student list rendered as status pills (view) or P/A/L/LA radios (edit).
class _AttendanceDetailsBody extends StatelessWidget {
  const _AttendanceDetailsBody({
    required this.data,
    required this.isEditing,
    required this.editStatuses,
    required this.onEditTap,
    required this.onStatusChanged,
  });

  final ClassAttendance data;
  final bool isEditing;
  final Map<String, StudentAttendanceStatus> editStatuses;
  final VoidCallback onEditTap;
  final void Function(String, StudentAttendanceStatus) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _DetailsHeader(
            className: data.teacherClass.bulletName,
            onEditTap: onEditTap,
          ),
          const SizedBox(height: 20),
          _StatsBar(stats: data.savedStatuses),
          const SizedBox(height: 20),
          for (var i = 0; i < data.students.length; i++) ...[
            if (isEditing)
              _StudentEditRow(
                student: data.students[i],
                status:
                    editStatuses[data.students[i].id] ??
                    StudentAttendanceStatus.present,
                onStatusChanged: onStatusChanged,
              )
            else
              _StudentViewRow(
                student: data.students[i],
                status:
                    data.savedStatuses[data.students[i].id] ??
                    StudentAttendanceStatus.present,
              ),
            if (i != data.students.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// "Attendance Details" title + subtitle + pencil button (Figma 65:7471).
class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({required this.className, required this.onEditTap});

  final String className;
  final VoidCallback onEditTap;

  static String _todayLabel() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour < 12 ? 'AM' : 'PM';
    return 'Today, $h:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attendance Details',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF161616),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    className,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _todayLabel(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF737373),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Pencil edit button (Figma edit_square 65:7477).
        InkWell(
          onTap: onEditTap,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.edit_rounded, size: 24, color: Color(0xFF161616)),
          ),
        ),
      ],
    );
  }
}

/// 2x2 summary bar: Presents / Absents / Leaves / Late Arrivals (Figma
/// 128:1481). Each pill is `#F7F7F7` with a `#D3E4FD` count circle.
class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.stats});

  final Map<String, StudentAttendanceStatus> stats;

  int get _present => _countOf(StudentAttendanceStatus.present);
  int get _absent => _countOf(StudentAttendanceStatus.absent);
  int get _leave => _countOf(StudentAttendanceStatus.leave);
  int get _late => _countOf(StudentAttendanceStatus.late);

  int _countOf(StudentAttendanceStatus status) {
    return stats.values.where((s) => s == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _StatPill(label: 'Presents', count: _present),
            const SizedBox(width: 10),
            _StatPill(label: 'Absents', count: _absent),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StatPill(label: 'Leaves', count: _leave),
            const SizedBox(width: 10),
            _StatPill(label: 'Late Arrivals', count: _late),
          ],
        ),
      ],
    );
  }
}

/// A single summary stat pill (Figma 128:1483).
class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 12, right: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(1000),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF737373),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFD3E4FD),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2249DC),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A shared avatar used by both the view and edit rows (Figma avatar r19).
class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.name});

  final String name;

  String get _initials {
    final parts = name.split(' ');
    if (parts.isEmpty) return '?';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE9EDFB),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}

/// Read-only student row showing the saved status pill (Figma tail of
/// 65:7291 / 65:7469).
class _StudentViewRow extends StatelessWidget {
  const _StudentViewRow({required this.student, required this.status});

  final Student student;
  final StudentAttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _StudentAvatar(name: student.name),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    student.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF161616),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.rollNo,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF737373),
                    ),
                  ),
                ],
              ),
            ],
          ),
          _StatusPill(status: status),
        ],
      ),
    );
  }
}

/// Edit-mode student row with the P/A/L/LA radio buttons (same as the Mark
/// Attendance screen).
class _StudentEditRow extends StatelessWidget {
  const _StudentEditRow({
    required this.student,
    required this.status,
    required this.onStatusChanged,
  });

  final Student student;
  final StudentAttendanceStatus status;
  final void Function(String, StudentAttendanceStatus) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _StudentAvatar(name: student.name),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    student.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF161616),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.rollNo,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF737373),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              AttendanceStatusRadio(
                status: StudentAttendanceStatus.present,
                selected: status == StudentAttendanceStatus.present,
                onTap: () => onStatusChanged(
                  student.id,
                  StudentAttendanceStatus.present,
                ),
              ),
              const SizedBox(width: 5),
              AttendanceStatusRadio(
                status: StudentAttendanceStatus.absent,
                selected: status == StudentAttendanceStatus.absent,
                onTap: () =>
                    onStatusChanged(student.id, StudentAttendanceStatus.absent),
              ),
              const SizedBox(width: 5),
              AttendanceStatusRadio(
                status: StudentAttendanceStatus.leave,
                selected: status == StudentAttendanceStatus.leave,
                onTap: () =>
                    onStatusChanged(student.id, StudentAttendanceStatus.leave),
              ),
              const SizedBox(width: 5),
              AttendanceStatusRadio(
                status: StudentAttendanceStatus.late,
                selected: status == StudentAttendanceStatus.late,
                onTap: () =>
                    onStatusChanged(student.id, StudentAttendanceStatus.late),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The status pill shown on the read-only details rows. Colours match the
/// Figma: Present `#DCFCE7`/`#15803D`, Absent red, Leave `#FFF8E3`/`#987200`,
/// Late In `#EBE8F7`/`#563CE0`.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final StudentAttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon, label) = switch (status) {
      StudentAttendanceStatus.present => (
        const Color(0xFFDCFCE7),
        const Color(0xFF15803D),
        Icons.how_to_reg_rounded,
        'Present',
      ),
      StudentAttendanceStatus.absent => (
        const Color(0xFFFEE2E2),
        const Color(0xFFC24040),
        Icons.person_off_rounded,
        'Absent',
      ),
      StudentAttendanceStatus.leave => (
        const Color(0xFFFFF8E3),
        const Color(0xFF987200),
        Icons.person_remove_rounded,
        'Leave',
      ),
      StudentAttendanceStatus.late => (
        const Color(0xFFEBE8F7),
        const Color(0xFF563CE0),
        Icons.hourglass_top_rounded,
        'Late In',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(1000),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: status == StudentAttendanceStatus.present
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom bar shown only in edit mode: **Discard** (outlined) + **Submit
/// Changes** (filled), matching the Figma action bar (65:6409 / 65:6410).
class _EditActionsBar extends StatelessWidget {
  const _EditActionsBar({required this.onDiscard, required this.onSubmit});

  final VoidCallback onDiscard;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF7F7F7), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onDiscard,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  minimumSize: const Size.fromHeight(45),
                  side: const BorderSide(color: AppTheme.primary, width: 1),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  'Discard',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(45),
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Submit Changes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state for the Attendance Details screen.
class _DetailsErrorView extends StatelessWidget {
  const _DetailsErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: Color(0xFFC24040),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF737373),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
