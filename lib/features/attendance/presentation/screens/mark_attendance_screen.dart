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

/// "Mark Attendance" screen (Figma "Class Attendance" variation-01 frame
/// 65:5984). Displays the class header with a subtitle, the P/A/L/LA legend,
/// and one row per student with 4 radio buttons for their attendance status.
/// Submitting opens the exact "Submitted Successfully!" dialog from the Figma
/// (frame 65:6949). After Done the sheet automatically becomes the saved
/// Attendance Details screen for that class.
class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({super.key, required this.classId});

  final String classId;

  @override
  ConsumerState<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  final Map<String, StudentAttendanceStatus> _statusByStudent = {};

  @override
  Widget build(BuildContext context) {
    final roster = ref.watch(classAttendanceProvider(widget.classId));

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
      body: roster.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error, _) => _MarkAttendanceError(
          message: error is AppFailure
              ? error.message
              : 'Unable to load the class.',
          onRetry: () =>
              ref.invalidate(classAttendanceProvider(widget.classId)),
        ),
        data: (data) => _MarkAttendanceBody(
          className: data.teacherClass.bulletName,
          students: data.students,
          statusByStudent: _statusByStudent,
          onStatusChanged: _setStatus,
        ),
      ),
      bottomNavigationBar: roster.maybeWhen(
        data: (data) => _SubmitBar(
          enabled: data.students.isNotEmpty,
          onPressed: () => _submit(data),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  void _setStatus(Student student, StudentAttendanceStatus status) {
    setState(() => _statusByStudent[student.id] = status);
  }

  Future<void> _submit(ClassAttendance data) async {
    final controller = ref.read(
      submitClassAttendanceControllerProvider.notifier,
    );
    final result = await controller.submit(
      classId: widget.classId,
      statusByStudent: _statusByStudent,
    );
    if (!mounted) return;
    if (result) {
      // Count the submitted statuses to render the success dialog counts.
      var present = 0, absent = 0, leave = 0, late = 0;
      for (final s in _statusByStudent.values) {
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
        title: 'Submitted Successfully!',
        message:
            'Attendance for ${data.teacherClass.bulletName} has been '
            'submitted successfully.',
        present: present,
        absent: absent,
        leave: leave,
        late: late,
      );
      // After the success dialog, the sheet becomes the saved Attendance
      // Details screen for that class (Figma last screens).
      if (mounted) {
        context.pushReplacement('/class/details/${widget.classId}');
      }
    }
  }
}

/// Scrollable body: screen header (title + subtitle/legend) and student rows.
class _MarkAttendanceBody extends StatelessWidget {
  const _MarkAttendanceBody({
    required this.className,
    required this.students,
    required this.statusByStudent,
    required this.onStatusChanged,
  });

  final String className;
  final List<Student> students;
  final Map<String, StudentAttendanceStatus> statusByStudent;
  final void Function(Student, StudentAttendanceStatus) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _MarkAttendanceHeader(
            className: className,
            statusByStudent: statusByStudent,
          ),
          const SizedBox(height: 20),
          _StudentsSection(
            students: students,
            statusByStudent: statusByStudent,
            onStatusChanged: onStatusChanged,
          ),
        ],
      ),
    );
  }
}

/// "Mark Attendance" + "Class B • Grade 6" subtitle + "Today, 10:15 AM"
/// (Figma 65:5986-65:5990).
class _MarkAttendanceHeader extends StatelessWidget {
  const _MarkAttendanceHeader({
    required this.className,
    required this.statusByStudent,
  });

  final String className;
  final Map<String, StudentAttendanceStatus> statusByStudent;

  static String _todayLabel() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour < 12 ? 'AM' : 'PM';
    return 'Today, $h:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mark Attendance',
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
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Students',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF161616),
              ),
            ),
            // Legend P / A / L / LA in the Figma's small round buttons.
            Row(
              children: const [
                _LegendDot(letter: 'P', color: Color(0xFF15803D)),
                SizedBox(width: 9),
                _LegendDot(letter: 'A', color: Color(0xFFC24040)),
                SizedBox(width: 9),
                _LegendDot(letter: 'L', color: Color(0xFF987200)),
                SizedBox(width: 9),
                _LegendDot(letter: 'LA', color: Color(0xFF563CE0)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Small round label used in the legend row (Figma 126:985-126:992).
class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.letter, required this.color});

  final String letter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// The "Students" section with one card per student.
class _StudentsSection extends StatelessWidget {
  const _StudentsSection({
    required this.students,
    required this.statusByStudent,
    required this.onStatusChanged,
  });

  final List<Student> students;
  final Map<String, StudentAttendanceStatus> statusByStudent;
  final void Function(Student, StudentAttendanceStatus) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < students.length; i++) ...[
          _StudentRow(
            student: students[i],
            status:
                statusByStudent[students[i].id] ??
                StudentAttendanceStatus.present,
            onStatusChanged: onStatusChanged,
          ),
          if (i != students.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// A single student card (Figma 126:994): white background, `#E8ECF0` stroke,
/// radius 12, avatar + name + Roll No on the left, 4 status radio buttons on
/// the right.
class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.student,
    required this.status,
    required this.onStatusChanged,
  });

  final Student student;
  final StudentAttendanceStatus status;
  final void Function(Student, StudentAttendanceStatus) onStatusChanged;

  String get _initials {
    final parts = student.name.split(' ');
    if (parts.isEmpty) return '?';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

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
          // Left block: avatar + name / roll no.
          Row(
            children: [
              Container(
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
              ),
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
          // 4 radio buttons: P A L LA (Figma 126:1134-126:1145).
          Row(
            children: [
              AttendanceStatusRadio(
                status: StudentAttendanceStatus.present,
                selected: status == StudentAttendanceStatus.present,
                onTap: () =>
                    onStatusChanged(student, StudentAttendanceStatus.present),
              ),
              const SizedBox(width: 5),
              AttendanceStatusRadio(
                status: StudentAttendanceStatus.absent,
                selected: status == StudentAttendanceStatus.absent,
                onTap: () =>
                    onStatusChanged(student, StudentAttendanceStatus.absent),
              ),
              const SizedBox(width: 5),
              AttendanceStatusRadio(
                status: StudentAttendanceStatus.leave,
                selected: status == StudentAttendanceStatus.leave,
                onTap: () =>
                    onStatusChanged(student, StudentAttendanceStatus.leave),
              ),
              const SizedBox(width: 5),
              AttendanceStatusRadio(
                status: StudentAttendanceStatus.late,
                selected: status == StudentAttendanceStatus.late,
                onTap: () =>
                    onStatusChanged(student, StudentAttendanceStatus.late),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The bottom submission bar (Figma 65:7131): white bar with a `#F7F7F7` top
/// border and upward drop shadow holding the full-width **Submit Attendance**
/// blue stadium button.
class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

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
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: enabled ? onPressed : null,
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
                    'Submit Attendance',
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
      ),
    );
  }
}

/// Error state for the Mark Attendance screen.
class _MarkAttendanceError extends StatelessWidget {
  const _MarkAttendanceError({required this.message, required this.onRetry});

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
