import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom navigation shell matching the Figma bottom nav bar (frames 15:688
/// and 3:130 "bottom-navigation"): a white (#FFFFFF) bar with a #E2E8F0 border.
/// The active tab gets the blue gradient circle (#2249DC → #122776) with white
/// icon + label; inactive tabs use #0B1F3A.
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const Color _barColor = Colors.white;
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
        child: Container(
          height: 76,
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
          decoration: BoxDecoration(
            color: _barColor,
            borderRadius: BorderRadius.circular(1000),
            border: Border.all(color: _barBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
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
    final foreground = active ? Colors.white : MainNavigationShell._inactiveColor;

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