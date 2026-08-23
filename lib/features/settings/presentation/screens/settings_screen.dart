import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/settings_providers.dart';

/// Settings screen reproduced from the Figma "settings" design (65:5573):
/// dark user-profile card, Features / Notifications / Legal sections with
/// colored icon rows, Push Notifications toggle, and the red Log out button.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushEnabled = true;

  Future<void> _handleLogout() async {
    // Figma "Logout" sheet (65:5921): dim overlay + white top-rounded sheet.
    await showModalBottomSheet<void>(
      context: context,
      // Push on the root navigator so the sheet renders ABOVE the bottom
      // navigation shell (StatefulShellRoute) instead of behind it.
      useRootNavigator: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xCC080808),
      builder: (sheetContext) => _LogoutSheet(
        onCancel: () => Navigator.of(sheetContext).pop(),
        onLogout: () async {
          final ok = await ref.read(logoutControllerProvider.notifier).logout();
          if (!sheetContext.mounted) return;
          Navigator.of(sheetContext).pop();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ok ? 'Logged out successfully.' : 'Unable to log out.',
              ),
            ),
          );
          if (ok && mounted) {
            context.go('/login');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    // When this screen is the Profile tab root, there is no back stack.
    final isTabRoot = GoRouterState.of(context).uri.path == '/profile';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: isTabRoot
            ? null
            : IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
        title: Text(
          'User Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF161616),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () => ref.refresh(profileProvider.future),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  children: [
                    profileAsync.maybeWhen(
                      data: (profile) => _UserProfileCard(
                        name: profile.fullName,
                        subtitle: 'ID: ${profile.id}  •  ${profile.role}',
                        onTap: () => context.push('/profile-view'),
                      ),
                      orElse: () => const _UserProfileCard(
                        name: 'Abdullah Mubashir',
                        subtitle: 'ID: M2024001  •  Mathematics',
                        onTap: null,
                      ),
                    ),
                    _sectionLabel('Features'),
                    _SettingsRow(
                      label: 'Edit Profile',
                      icon: Icons.person_outline_rounded,
                      circleColor: const Color(0xFFDCE3FB),
                      iconColor: const Color(0xFF2249DC),
                      onTap: () => context.push('/settings/edit-profile'),
                    ),
                    _SettingsRow(
                      label: 'Attendance',
                      icon: Icons.assignment_outlined,
                      circleColor: const Color(0xFFFFF1D9),
                      iconColor: const Color(0xFFBF7900),
                      onTap: () => context.push('/settings/attendance'),
                    ),
                    _SettingsRow(
                      label: 'Change Password',
                      icon: Icons.lock_outline_rounded,
                      circleColor: const Color(0xFFD9F3FF),
                      iconColor: const Color(0xFF0074A9),
                      onTap: () => context.push('/settings/change-password'),
                    ),
                    _sectionLabel('Notifications'),
                    _NotificationRow(
                      enabled: _pushEnabled,
                      onChanged: (v) => setState(() => _pushEnabled = v),
                    ),
                    _sectionLabel('Legal'),
                    _SettingsRow(
                      label: 'About App',
                      icon: Icons.info_outline_rounded,
                      circleColor: const Color(0xFFF0FFDE),
                      iconColor: const Color(0xFF569D00),
                      onTap: () => context.push('/settings/about'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: _LogoutButton(onTap: _handleLogout),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'TeachDesk Enterprise v2.4.10',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF737373),
        ),
      ),
    );
  }
}
// ─── Dark user profile card (Figma "User_Profile_Card" 65:5585) ────────────

class _UserProfileCard extends StatelessWidget {
  const _UserProfileCard({
    required this.name,
    required this.subtitle,
    this.onTap,
  });

  final String name;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // Avatar (Figma "Avatar_Wrap" 65:5586)
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/avatar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFC2C2C2),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFC2C2C2)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── A settings navigation row (Figma "student-row" 65:5595) ───────────────

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.icon,
    required this.circleColor,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color circleColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 62,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD9D9D9)),
        ),
        child: Row(
          children: [
            // Colored icon circle (Figma "avatar" 65:5597)
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF161616),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF737373),
            ),
          ],
        ),
      ),
    );
  }
}
// ─── Push Notifications row with toggle (Figma 65:5629) ────────────────────

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFFDCD9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              size: 20,
              color: Color(0xFFA60D00),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Push Notifications',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF161616),
              ),
            ),
          ),
          _PushToggle(enabled: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Figma toggle (65:5636): a 44.4x24.2 pill, radius 14.4. When ON the pill is
/// #2249DC and holds a 19.2px white circle on the right; when OFF it is white
/// with a #D9D9D9 border and the circle sits on the left.
class _PushToggle extends StatelessWidget {
  const _PushToggle({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!enabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44.4,
        height: 24.2,
        padding: const EdgeInsets.all(2.4),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF2249DC) : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(14.4),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 19.2,
            height: 19.2,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Log out button (Figma "Frame 2147223834" 65:5650) ─────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFD7A8A),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFBC3429)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 18, color: Color(0xFFBC3429)),
              SizedBox(width: 8),
              Text(
                'Log out',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBC3429),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ─── Logout confirmation bottom sheet (Figma 65:5921) ──────────────────────

class _LogoutSheet extends StatelessWidget {
  const _LogoutSheet({required this.onCancel, required this.onLogout});

  final VoidCallback onCancel;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row: "Do you want to logout" + close X (Figma 65:5923)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Do you want to logout',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF000000),
                  ),
                ),
              ),
              InkWell(
                onTap: onCancel,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 29.3,
                  height: 29.3,
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 13.3,
                    color: Color(0xFF777777),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Subtitle (Figma 65:5927)
          Text(
            'Do you really want to logout from this app?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF777777),
            ),
          ),
          const SizedBox(height: 28),
          // Cancel + Logout buttons (Figma 65:5928)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7F7F7),
                      foregroundColor: const Color(0xFF737373),
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF737373),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: FilledButton(
                    onPressed: onLogout,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2249DC),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'Logout',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
