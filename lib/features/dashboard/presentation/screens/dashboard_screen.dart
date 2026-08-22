import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_dimensions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/dashboard.dart';
import '../providers/dashboard_providers.dart';

/// Dashboard home screen reproduced 1:1 from the Figma "Dashboard" frame
/// (118:1665). Header + Quick Actions + Today's Timetable + Class
/// Attendance Records + Upcoming Schedule.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: summary.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF2249DC)),
          ),
          error: (error, _) => _DashboardErrorView(
            message: error is AppFailure ? error.message : 'Unable to load dashboard.',
            onRetry: () => ref.invalidate(dashboardSummaryProvider),
          ),
          data: (data) => RefreshIndicator(
            color: const Color(0xFF2249DC),
            onRefresh: () => ref.refresh(dashboardSummaryProvider.future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                _DashboardHeader(summary: data),
                const SizedBox(height: 28),
                _QuickActionsSection(actions: data.quickActions),
                const SizedBox(height: 28),
                _TimetableSection(periods: data.timetable),
                const SizedBox(height: 28),
                _ClassAttendanceSection(statuses: data.classStatuses),
                const SizedBox(height: 28),
                _UpcomingSection(events: data.upcoming),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header: greeting + date + avatar (Figma "dashboard-header" 118:1666) ──

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.greeting,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF161616),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.dateLabel,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF737373),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const _HeaderAvatar(),
        ],
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ─── Quick Actions: 3 colored action cards (Figma 118:1676) ─────────────────

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF161616),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _QuickActionCard(action: actions[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final QuickAction action;

  static const Map<QuickActionType, Color> _bg = {
    QuickActionType.myAttendance: Color(0xFFF5FFE6),
    QuickActionType.applyLeave: Color(0xFFE3F7FE),
    QuickActionType.viewDatesheet: Color(0xFFFFE0F7),
  };
static const Map<QuickActionType, IconData> _icons = {
    QuickActionType.myAttendance: Icons.eco_rounded,
    QuickActionType.applyLeave: Icons.calendar_month_rounded,
    QuickActionType.viewDatesheet: Icons.assignment_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final background = _bg[action.type] ?? const Color(0xFFF5FFE6);
    final iconColor = background == const Color(0xFFF5FFE6)
        ? const Color(0xFF93BA59)
        : background == const Color(0xFFE3F7FE)
            ? const Color(0xFF53AAC9)
            : const Color(0xFFC37BB0);

    return Container(
      height: 106,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  child: Icon(_icons[action.type], size: 26, color: iconColor),
                ),
                Icon(Icons.arrow_outward, size: 16, color: iconColor),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: Text(
                  action.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF161616),
                    height: 1.2,
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

// ─── Today's Timetable with timeline (Figma 118:1722) ───────────────────────

class _TimetableSection extends StatelessWidget {
  const _TimetableSection({required this.periods});

  final List<TimetablePeriod> periods;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Timetable",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF161616),
                  height: 1.5,
                ),
              ),
              Text(
                '${periods.length} Classes',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2249DC),
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < periods.length; i++)
            _TimetableRow(
              period: periods[i],
              isLast: i == periods.length - 1,
            ),
        ],
      ),
    );
  }
}
class _TimetableRow extends StatelessWidget {
  const _TimetableRow({required this.period, required this.isLast});

  final TimetablePeriod period;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline: dot + connecting line (#4C40BF).
          SizedBox(
            width: 14,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C40BF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4C40BF).withValues(alpha: 0.35),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Expanded(
                    child: SizedBox(
                      width: 1,
                      child: ColoredBox(color: Color(0xFF4C40BF)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Spacer so the bottom meta row separator sits under the dot.
          Expanded(child: _TimetableCard(period: period)),
        ],
      ),
    );
  }
}

class _TimetableCard extends StatelessWidget {
  const _TimetableCard({required this.period});

  final TimetablePeriod period;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
            children: [
              Expanded(
                child: Text(
                  period.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF161616),
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _RoleBadge(role: period.role),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                period.room,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF737373),
                  height: 1.5,
                ),
              ),
              Text(
                period.className,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF737373),
                  height: 1.5,
                ),
              ),
              Text(
                period.timeRange,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF737373),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final TimetableRole role;

  @override
  Widget build(BuildContext context) {
    final isSubjectTeacher = role == TimetableRole.subjectTeacher;
    final background = isSubjectTeacher ? const Color(0xFFFFF8E3) : const Color(0xFFDCFCE7);
    final foreground = isSubjectTeacher ? const Color(0xFF987200) : const Color(0xFF15803D);
    final label = isSubjectTeacher ? 'Subject Teacher' : 'Class Incharge';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(1000),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: foreground,
          height: 1.5,
        ),
      ),
    );
  }
}
// ─── Class Attendance Records (Figma 118:1767) ──────────────────────────────

class _ClassAttendanceSection extends StatelessWidget {
  const _ClassAttendanceSection({required this.statuses});

  final List<ClassAttendanceStatus> statuses;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Class Attendance Records',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF161616),
                  height: 1.5,
                ),
              ),
              Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2249DC),
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < statuses.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _ClassStatusCard(status: statuses[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ClassStatusCard extends StatelessWidget {
  const _ClassStatusCard({required this.status});

  final ClassAttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.className,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF161616),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status.subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF737373),
                  height: 1.5,
                ),
              ),
            ],
          ),
          _MarkedPill(status: status),
        ],
      ),
    );
  }
}

class _MarkedPill extends StatelessWidget {
  const _MarkedPill({required this.status});

  final ClassAttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final isMarked = status.status == AttendanceMarkStatus.marked;
    final background = isMarked
        ? const Color(0xFFDDEBFD)
        : const Color(0xFFC24040).withValues(alpha: 0.12);
    final foreground = isMarked ? const Color(0xFF1D4EDF) : const Color(0xFFC24040);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: foreground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
// ─── Upcoming Schedule (Figma 118:1793) ─────────────────────────────────────

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection({required this.events});

  final List<UpcomingEvent> events;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Schedule',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF161616),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD9D9D9)),
            ),
            child: Column(
              children: [
                for (var i = 0; i < events.length; i++) ...[
                  _UpcomingRow(event: events[i]),
                  if (i < events.length - 1) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE8ECF0)),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.event});

  final UpcomingEvent event;

  (IconData, Color) get _icon => switch (event.kind) {
        UpcomingEventKind.holiday => (
            Icons.celebration_outlined,
            const Color(0xFF93BA59),
          ),
        UpcomingEventKind.meeting => (
            Icons.groups_rounded,
            const Color(0xFF53AAC9),
          ),
        UpcomingEventKind.leave => (
            Icons.event_busy_outlined,
            const Color(0xFFC37BB0),
          ),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _icon;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF737373),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          event.date,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF161616),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─── Error view ─────────────────────────────────────────────────────────────

class _DashboardErrorView extends StatelessWidget {
  const _DashboardErrorView({required this.message, required this.onRetry});

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