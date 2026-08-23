import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_dimensions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_calendar_sheet.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../domain/entities/leave.dart';
import '../providers/leave_providers.dart';

/// Leaves history screen reproduced from the Figma "Leave" design
/// (section 76:6156): header with back arrow + add button, "Leaves History"
/// title, status filter pills (All / Pending / Approved / Cancelled) and
/// leave history cards with status badges.
class LeaveScreen extends ConsumerStatefulWidget {
  const LeaveScreen({super.key});

  @override
  ConsumerState<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends ConsumerState<LeaveScreen> {
  static const List<LeaveStatus?> _filters = [
    null,
    LeaveStatus.pending,
    LeaveStatus.approved,
    LeaveStatus.cancelled,
  ];

  static String _filterLabel(LeaveStatus? status) => switch (status) {
    null => 'All',
    LeaveStatus.pending => 'Pending',
    LeaveStatus.approved => 'Approved',
    LeaveStatus.cancelled => 'Cancelled',
    LeaveStatus.rejected => 'Rejected',
  };

  DateTime? _selectedDate;

  Future<void> _openCalendar() async {
    final picked = await showCalendarSheet(context, initialDate: _selectedDate);
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _clearDate() {
    setState(() => _selectedDate = null);
  }

  bool _matchesFilter(LeaveRequest leave, LeaveStatus? status) =>
      status == null || leave.status == status;

  bool _matchesDate(LeaveRequest leave, DateTime? date) {
    if (date == null) return true;
    final start = DateTime(
      leave.startDate.year,
      leave.startDate.month,
      leave.startDate.day,
    );
    final end = DateTime(
      leave.endDate.year,
      leave.endDate.month,
      leave.endDate.day,
    );
    return !date.isBefore(start) && !date.isAfter(end);
  }

  @override
  Widget build(BuildContext context) {
    final leaves = ref.watch(leavesProvider);
    final filter = ref.watch(leaveFilterProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Leaves',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF161616),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Leave',
            onPressed: () => context.push('/leave/create'),
            icon: const Icon(Icons.add_rounded, color: Color(0xFF1C1B1F)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Leaves History',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF777777),
                    ),
                  ),
                  _DateFilterChip(
                    selectedDate: _selectedDate,
                    onTap: _openCalendar,
                    onClear: _clearDate,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final status = _filters[index];
                  return _FilterPill(
                    label: _filterLabel(status),
                    selected: filter == status,
                    onTap: () =>
                        ref.read(leaveFilterProvider.notifier).set(status),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: leaves.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
                error: (error, _) => _ErrorView(
                  message: error is AppFailure
                      ? error.message
                      : 'Unable to load leaves.',
                  onRetry: () => ref.invalidate(leavesProvider),
                ),
                data: (items) {
                  final filtered = items
                      .where((e) => _matchesFilter(e, filter))
                      .where((e) => _matchesDate(e, _selectedDate))
                      .toList();
                  return filtered.isEmpty
                      ? const AppEmptyState(
                          title: 'No leaves found',
                          subtitle: 'Apply for leave to see it here.',
                          scrollable: true,
                        )
                      : RefreshIndicator(
                          color: AppTheme.primary,
                          onRefresh: () => ref.refresh(leavesProvider.future),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            itemCount: filtered.length,
                            separatorBuilder: (_, index) =>
                                const SizedBox(height: 20),
                            itemBuilder: (context, index) =>
                                LeaveCard(leave: filtered[index]),
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Leave history card (Figma "history-card" 76:6188) ─────────────────────

class LeaveCard extends StatelessWidget {
  const LeaveCard({super.key, required this.leave});

  final LeaveRequest leave;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.typeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            leave.dateRangeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6E706F),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '•',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        Text(
                          leave.daysLabel,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: leave.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Reason: ${leave.reason}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF737373),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status badge (Figma "badge" 76:6196) ──────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final LeaveStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      LeaveStatus.pending => (const Color(0xFFFFF8E3), const Color(0xFF987200)),
      LeaveStatus.approved => (
        const Color(0xFFDCFCE7),
        const Color(0xFF15803D),
      ),
      LeaveStatus.rejected => (
        const Color(0xFFFEE2E2),
        const Color(0xFFC24040),
      ),
      LeaveStatus.cancelled => (
        const Color(0xFFE2E8F0),
        const Color(0xFF6E706F),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: foreground,
          height: 1.5,
        ),
      ),
    );
  }
}
// ─── Filter pills (Figma 76:6178) ──────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDDEBFD) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: selected ? null : Border.all(color: const Color(0xFFD9D9D9)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppTheme.primary : const Color(0xFF777777),
          ),
        ),
      ),
    );
  }
}

// ─── Date tag chip (Figma "Tag" 76:6172) ───────────────────────────────────

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({
    required this.selectedDate,
    required this.onTap,
    required this.onClear,
  });

  final DateTime? selectedDate;
  final VoidCallback onTap;
  final VoidCallback onClear;

  static String _label(DateTime? date) {
    if (date == null) return 'Date';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = selectedDate != null;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasDate)
          GestureDetector(
            onTap: onClear,
            behavior: HitTestBehavior.opaque,
            child: Icon(Icons.close_rounded, size: 14, color: AppTheme.primary),
          ),
        if (hasDate) const SizedBox(width: 8),
        Text(
          _label(selectedDate),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
            color: hasDate ? AppTheme.primary : const Color(0xFF777777),
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          Icons.calendar_today_rounded,
          size: 14,
          color: hasDate ? AppTheme.primary : const Color(0xFF777777),
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasDate ? const Color(0xFFDDEBFD) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: hasDate ? AppTheme.primary : const Color(0xFFD9D9D9),
          ),
        ),
        child: child,
      ),
    );
  }
}

// ─── Error view ────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

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
