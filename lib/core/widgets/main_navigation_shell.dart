import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom navigation shell matching the Figma bottom nav bar (frames 15:688
/// and 3:130 "bottom-navigation"): a glassy very-light-blue (#DEE4FA) pill with
/// a translucent frosted tint, an #E2E8F0 edge, and a soft diffuse shadow. The
/// active tab keeps the blue gradient circle (#2249DC → #122776) with white
/// icon + label; inactive tabs use #0B1F3A.
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  // Glassy very-light-blue tint (RGB 222, 228, 250) with a subtle top-light
  // sheen. Painted as a plain translucent gradient so the pill costs nothing
  // per frame — the previous BackdropFilter(sigma 20) + extendBody was
  // re-blurring the whole backdrop every frame and caused the hang.
  static const List<Color> _glassColors = [
    Color(0xE6F2F5FD), // subtle top-light sheen
    Color(0xE6DEE4FA), // requested primary tint (RGB 222, 228, 250)
  ];
  static const Color _barBorder = Color(0xFFE2E8F0);
  static const Color _inactiveColor = Color(0xFF0B1F3A);

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: Colors.white,
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        // Soft glass pill — no backdrop blur, so it costs nothing per frame:
        // a translucent #DEE4FA gradient, a thin #E2E8F0 edge, and two soft
        // diffuse shadows. Content still reads through the tint (extendBody).
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1000),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2679A0FF), // soft light-blue ambient glow
                blurRadius: 20,
                offset: Offset(0, 14),
              ),
              BoxShadow(
                color: Color(0x1A000000), // soft diffuse grounding shadow
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            height: 76,
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _glassColors,
              ),
              borderRadius: BorderRadius.circular(1000),
              border: Border.all(color: _barBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _NavItem(
                  active: currentIndex == 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  onTap: () => _onDestinationSelected(0),
                ),
                _NavItem(
                  active: currentIndex == 1,
                  icon: Icons.local_library_rounded,
                  label: 'Class',
                  onTap: () => _onDestinationSelected(1),
                ),
                _NavItem(
                  active: currentIndex == 2,
                  icon: Icons.calendar_month_rounded,
                  label: 'Leave',
                  onTap: () => _onDestinationSelected(2),
                ),
                _NavItem(
                  active: currentIndex == 3,
                  icon: Icons.fact_check_rounded,
                  label: 'Exams',
                  onTap: () => _onDestinationSelected(3),
                ),
                _NavItem(
                  active: currentIndex == 4,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  onTap: () => _onDestinationSelected(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = active
        ? Colors.white
        : MainNavigationShell._inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2249DC), Color(0xFF122776)],
                )
              : null,
          borderRadius: BorderRadius.circular(1000),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: foreground),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: foreground,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
