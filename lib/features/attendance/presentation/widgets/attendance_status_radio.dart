import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/class_attendance.dart';

/// A single P / A / L / LA status radio button used on the Mark Attendance and
/// Attendance Details (edit) screens. Matches the Figma radio circles
/// (checked = filled with the status color + white letters, unchecked = grey
/// outline).
class AttendanceStatusRadio extends StatelessWidget {
  const AttendanceStatusRadio({
    super.key,
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final StudentAttendanceStatus status;
  final bool selected;
  final VoidCallback onTap;

  static Color colorOf(StudentAttendanceStatus status) {
    return switch (status) {
      StudentAttendanceStatus.present => const Color(0xFF15803D),
      StudentAttendanceStatus.absent => const Color(0xFFC24040),
      StudentAttendanceStatus.leave => const Color(0xFF987200),
      StudentAttendanceStatus.late => const Color(0xFF563CE0),
    };
  }

  static String letterOf(StudentAttendanceStatus status) {
    return switch (status) {
      StudentAttendanceStatus.present => 'P',
      StudentAttendanceStatus.absent => 'A',
      StudentAttendanceStatus.leave => 'L',
      StudentAttendanceStatus.late => 'LA',
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = colorOf(status);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? color : Colors.white,
          border: Border.all(
            color: selected ? color : const Color(0xFFD9D9D9),
            width: 1.4,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          letterOf(status),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
