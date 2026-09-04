import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../domain/entities/exam.dart';
import '../providers/exam_providers.dart';

/// Exams tab backed by `GET /teacher-portal/exams`. Shows active / upcoming /
/// completed examination lists, falling back to a friendly empty state when the
/// portal has no exams or the request fails.
class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(examsOverviewProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Exams',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF161616),
          ),
        ),
      ),
      body: examsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Could not load exams',
          subtitle: error.toString(),
        ),
        data: (overview) {
          if (overview.isEmpty) {
            return const AppEmptyState(
              icon: Icons.assignment_rounded,
              title: 'No exams yet',
              subtitle: 'When examinations are scheduled\n'
                  'they will appear here.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              if (overview.active.isNotEmpty) ...[
                _SectionHeader(label: 'Active'),
                ...overview.active.map(_ExamCard.new),
                const SizedBox(height: 16),
              ],
              if (overview.upcoming.isNotEmpty) ...[
                _SectionHeader(label: 'Upcoming'),
                ...overview.upcoming.map(_ExamCard.new),
                const SizedBox(height: 16),
              ],
              if (overview.completed.isNotEmpty) ...[
                _SectionHeader(label: 'Completed'),
                ...overview.completed.map(_ExamCard.new),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF4B5563),
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard(this.exam);

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final range = _rangeLabel();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              Icons.description_rounded,
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
                  exam.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF161616),
                  ),
                ),
                if (range != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    range,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF737373),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (exam.status != null && exam.status!.isNotEmpty)
            _StatusPill(status: exam.status!),
        ],
      ),
    );
  }

  String? _rangeLabel() {
    if (exam.startsOn == null && exam.endsOn == null) return null;
    final start = exam.startsOn ?? '…';
    final end = exam.endsOn ?? exam.startsOn ?? '';
    return start == end ? start : '$start → $end';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final Color color;
    if (normalized.contains('active') || normalized.contains('ongoing')) {
      color = const Color(0xFF16A34A);
    } else if (normalized.contains('upcoming')) {
      color = const Color(0xFF4E6CF0);
    } else if (normalized.contains('complete')) {
      color = const Color(0xFF9CA3AF);
    } else {
      color = const Color(0xFF4B5563);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}