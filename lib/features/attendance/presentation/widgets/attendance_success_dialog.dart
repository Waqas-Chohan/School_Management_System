import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

/// Success dialog shared by the Mark Attendance submit flow and the
/// Attendance Details update flow. Matches the Figma success-card (frames
/// 65:6950 "Submitted Successfully!" and 65:7135 "Updated Successfully!"):
/// black overlay, white card radius 20, green check icon, title, description,
/// summary counts with colored dots, and a Done button.
class AttendanceSuccessDialog extends StatelessWidget {
  const AttendanceSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    required this.present,
    required this.absent,
    required this.leave,
    required this.late,
  });

  final String title;
  final String message;
  final int present;
  final int absent;
  final int leave;
  final int late;

  /// Shows a non-dismissible [AttendanceSuccessDialog] and resolves when the
  /// user taps Done.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required int present,
    required int absent,
    required int leave,
    required int late,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AttendanceSuccessDialog(
        title: title,
        message: message,
        present: present,
        absent: absent,
        leave: leave,
        late: late,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 45, vertical: 24),
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
            // Green check icon in a soft-green circle (Figma 65:6951).
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
                  border: Border.all(color: const Color(0xFF15803D), width: 2),
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
            const SizedBox(height: 16),
            // Summary: N Present / N Absent / N Leave dots.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SummaryPill(
                  count: present,
                  label: 'Present',
                  color: const Color(0xFF15803D),
                ),
                const SizedBox(width: 16),
                _SummaryPill(
                  count: absent,
                  label: 'Absent',
                  color: const Color(0xFFC24040),
                ),
                const SizedBox(width: 16),
                _SummaryPill(
                  count: leave,
                  label: 'Leave',
                  color: const Color(0xFF987200),
                ),
              ],
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
    );
  }
}

/// A "N Present" pill with a colored dot.
class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$count $label',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
