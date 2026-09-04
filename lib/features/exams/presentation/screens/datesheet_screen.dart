import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../domain/entities/exam.dart';
import '../providers/exam_providers.dart';

/// Datesheet screen backed by `GET /teacher-portal/datesheets`. Shows the exam
/// schedule timeline for the teacher's class, or a friendly empty state when
/// nothing has been released yet.
class DatesheetScreen extends ConsumerWidget {
  const DatesheetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datesheetsAsync = ref.watch(dateSheetsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: Text(
          'Datesheet',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF161616),
          ),
        ),
      ),
      body: SafeArea(
        child: datesheetsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load datesheet',
            subtitle: error.toString(),
          ),
          data: (sheets) {
            if (sheets.isEmpty) {
              return const AppEmptyState(
                icon: Icons.event_available_rounded,
                title: 'Datesheet will be available soon',
                subtitle: 'The exam committee is finalizing the schedule.\n'
                    'Please check back later.',
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                for (final sheet in sheets) _DateSheetCard(sheet: sheet),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DateSheetCard extends StatelessWidget {
  const _DateSheetCard({required this.sheet});

  final DateSheet sheet;

  @override
  Widget build(BuildContext context) {
    final subject = sheet.subjectName ?? 'Subject';
    final meta = <String>[
      if (sheet.className != null && sheet.className!.isNotEmpty)
        sheet.className!,
      if (sheet.room != null && sheet.room!.isNotEmpty) sheet.room!,
      if (sheet.startTime != null && sheet.endTime != null)
        '${sheet.startTime} - ${sheet.endTime}',
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF0F4)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF4E6CF0),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sheet.examName ?? 'Examination',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subject,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF161616),
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
                if (sheet.date != null && sheet.date!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _friendlyDate(sheet.date!),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4E6CF0),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}