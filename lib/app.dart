import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/main_navigation_shell.dart';
import 'features/auth/presentation/screens/auth_gate_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/attendance/presentation/screens/class_screen.dart';
import 'features/attendance/presentation/screens/teacher_attendance_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/exams/presentation/screens/exams_screen.dart';
import 'features/features/domain/entities/feature.dart';
import 'features/features/presentation/screens/create_feature_screen.dart';
import 'features/features/presentation/screens/feature_detail_screen.dart';
import 'features/features/presentation/screens/feature_screen.dart';
import 'features/leave/presentation/screens/create_leave_screen.dart';
import 'features/leave/presentation/screens/leave_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/settings/presentation/screens/about_app_screen.dart';
import 'features/settings/presentation/screens/change_password_screen.dart';
import 'features/settings/presentation/screens/edit_profile_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

/// Root [MaterialApp.router] and [GoRouter] configuration.
class App extends StatelessWidget {
  const App({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthGateScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/class',
                builder: (context, state) => const ClassScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leave',
                builder: (context, state) => const LeaveScreen(),
              ),
              GoRoute(
                path: '/leave/create',
                builder: (context, state) => const CreateLeaveScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/exams',
                builder: (context, state) => const ExamsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Top-level detail routes (outside shell)
      GoRoute(
        path: '/profile-view',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings/attendance',
        builder: (context, state) => const TeacherAttendanceScreen(),
      ),
      GoRoute(
        path: '/settings/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        builder: (context, state) => const AboutAppScreen(),
      ),
      GoRoute(
        path: '/features',
        builder: (context, state) => const FeatureScreen(),
      ),
      GoRoute(
        path: '/features/create',
        builder: (context, state) => const CreateFeatureScreen(),
      ),
      GoRoute(
        path: '/features/detail',
        builder: (context, state) {
          final feature = state.extra is Feature ? state.extra! as Feature : null;
          if (feature == null) return const FeatureScreen();
          return FeatureDetailScreen(feature: feature);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'School Management',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}