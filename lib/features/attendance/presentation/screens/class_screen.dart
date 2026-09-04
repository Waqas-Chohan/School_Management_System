import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/avatar_resolver.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/entities/class_attendance.dart';
import '../providers/class_attendance_providers.dart';

/// "My Classes" screen shown when the teacher taps the Class tab in the bottom
/// navigation (Figma frame 65:7156). Displays the dashboard-style header with
/// a greeting, the current date and avatar, then the list of the teacher's
/// classes. Tapping a class navigates to the Mark Attendance screen.
class ClassScreen extends ConsumerWidget {
  const ClassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(teacherClassesProvider);
    final profileAsync = ref.watch(profileProvider);
    final session = ref.watch(authSessionProvider);
    final teacherName = session?.employeeName.isNotEmpty == true
        ? session!.employeeName
        : 'Teacher';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: classes.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
          error: (error, _) => _ClassesErrorView(
            message: error is AppFailure
                ? error.message
                : 'Unable to load your classes.',
            onRetry: () => ref.invalidate(teacherClassesProvider),
          ),
          data: (data) {
            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () => ref.refresh(teacherClassesProvider.future),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _MyClassesHeader(
                    teacherName: teacherName,
                    avatarUrl: profileAsync.value?.avatar,
                  ),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: 'My Classes'),
                  const SizedBox(height: 16),
                  for (var i = 0; i < data.length; i++) ...[
                    _ClassCard(cls: data[i]),
                    if (i != data.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Greeting header matching the Figma dashboard header (frame 75:8903):
/// "Hy, [name]" + date on the left, avatar with a green active dot.
class _MyClassesHeader extends StatelessWidget {
  const _MyClassesHeader({required this.teacherName, this.avatarUrl});

  final String teacherName;
  final String? avatarUrl;

  static String _todayLabel() {
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
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hy, $teacherName',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF161616),
              ),
            ),
            const SizedBox(height: 4),
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
        GestureDetector(
          onTap: () => context.push('/profile-view'),
          child: SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: avatarDecoration(avatarUrl),
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
          ),
        ),
      ],
    );
  }
}

/// "My Classes" SemiBold 20 section header.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF161616),
      ),
    );
  }
}

/// A selectable class row (Figma 65:7160 / 65:7248): white card with
/// `#E8ECF0` border, radius 12, class name Medium 14, "32 Students" Regular 12
/// in `#94A3B8`, and a pill on the right. Before attendance is saved the pill
/// is the green "Mark" (`#DCFCE7` / `#15803D`); once saved it becomes the
/// purple "View" pill (`#EBE8F7` / `#563CE0`) and opens the Attendance Details
/// screen for that class.
class _ClassCard extends ConsumerWidget {
  const _ClassCard({required this.cls});

  final TeacherClass cls;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A class counts as already marked when the server says so, or when its
    // attendance was submitted during this session (the dashboard aggregation
    // can lag behind a successful POST). This keeps the card on the purple
    // "View" pill / Attendance Details route right after marking.
    final submittedToday = ref.watch(submittedClassIdsProvider);
    final submitted =
        cls.attendanceSubmitted || submittedToday.contains(cls.id);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
          submitted
              ? '/class/details/${cls.id}'
              : '/class/attendance/${cls.id}',
          extra: cls,
        ),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8ECF0), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cls.displayName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF161616),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cls.studentCount} Students',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              if (submitted) _ViewPill() else _MarkPill(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Green "Mark" pill — attendance not yet saved (Figma 65:7164).
class _MarkPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(1000),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: Color(0xFF15803D),
          ),
          const SizedBox(width: 4),
          Text(
            'Mark',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF15803D),
            ),
          ),
        ],
      ),
    );
  }
}

/// Purple "View" pill — attendance already saved (Figma 65:7173).
class _ViewPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE8F7),
        borderRadius: BorderRadius.circular(1000),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.visibility_rounded,
            size: 16,
            color: Color(0xFF563CE0),
          ),
          const SizedBox(width: 4),
          Text(
            'View',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF563CE0),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple error view with a retry button.
class _ClassesErrorView extends StatelessWidget {
  const _ClassesErrorView({required this.message, required this.onRetry});

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
