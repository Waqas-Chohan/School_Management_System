import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_dimensions.dart';
import '../../../../core/error/failures.dart';
import '../providers/profile_providers.dart';

/// Read-only profile view reached from the Settings dark profile card. It
/// mirrors the fields of the Edit Profile screen (Full Name / Email / Phone /
/// Date of Birth / Gender) but with no edit affordances — no pencil, no input
/// fields, and no Save bar. To make changes the user backs out and opens
/// Settings → Edit Profile.
class ProfileViewScreen extends ConsumerWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF161616),
          ),
        ),
      ),
      body: SafeArea(
        child: profile.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF2249DC)),
          ),
          error: (error, _) => _ProfileErrorView(
            message: error is AppFailure
                ? error.message
                : 'Unable to load profile.',
            onRetry: () => ref.invalidate(profileProvider),
          ),
          data: (data) => RefreshIndicator(
            color: const Color(0xFF2249DC),
            onRefresh: () => ref.refresh(profileProvider.future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              children: [
                // Avatar (plain — no pencil overlay / no "Change picture").
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/avatar.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Profile is view-only. To edit, open Settings → Edit Profile.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF737373),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _pillLabel('Full Name'),
                const SizedBox(height: 8),
                _readonlyPill(data.fullName),
                const SizedBox(height: 16),
                _pillLabel('Email Address'),
                const SizedBox(height: 8),
                _readonlyPill(data.email),
                const SizedBox(height: 16),
                _pillLabel('Phone Number'),
                const SizedBox(height: 8),
                _readonlyPill(data.phone),
                const SizedBox(height: 16),
                _pillLabel('Date of Birth'),
                const SizedBox(height: 8),
                _readonlyPill(_dobLabel(data.dateJoined)),
                const SizedBox(height: 16),
                _pillLabel('Gender'),
                const SizedBox(height: 8),
                _readonlyPill(data.gender),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _dobLabel(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _pillLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF737373),
      ),
    );
  }

  Widget _readonlyPill(String value) {
    return Container(
      width: double.infinity,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF161616),
        ),
      ),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({required this.message, required this.onRetry});

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
