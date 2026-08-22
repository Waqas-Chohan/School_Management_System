import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_dimensions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/teacher_profile.dart';
import '../providers/profile_providers.dart';

/// Profile screen reproduced 1:1 from the Figma "profile" design (3:147).
/// Background #F8FAFC · bordered hero with mint "AS" avatar · teacher identity
/// · ID badge · white details card with 8 rows (#94A3B8 labels, #0F172A
/// semi-bold values) · Change Portal Password pill.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: Text(
          'My Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
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
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _ProfileHero(profile: data),
                _DetailSection(profile: data),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _ChangePasswordButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hero (Figma 3:155): avatar + identity + id badge ─────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final TeacherProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar circle (Figma "avatar-frame" 3:156)
          Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFCCFBF1),
              shape: BoxShape.circle,
            ),
            child: Text(
              profile.initials,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F766E),
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Teacher identity
          Text(
            profile.fullName,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.role,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 10),
          // ID badge (Figma "id-badge" 3:161)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              profile.id,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ─── Details card (Figma "details-card" 3:164) ─────────────────────────────

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.profile});

  final TeacherProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            _DetailRow(
              label: 'Email Address',
              value: profile.email,
            ),
            _DetailRow(
              label: 'Phone Number',
              value: profile.phone,
              showPencil: true,
              onPencil: () => _showEditPhoneSheet(context, profile.phone),
            ),
            _DetailRow(
              label: 'Subject(s) Taught',
              value: profile.subjectsLabel,
            ),
            _DetailRow(
              label: 'Qualification',
              value: profile.qualification,
            ),
            _DetailRow(
              label: 'Gender',
              value: profile.gender,
            ),
            _DetailRow(
              label: 'Date Joined',
              value: profile.dateJoinedLabel,
            ),
            _DetailRow(
              label: 'Employment Status',
              value: profile.employmentStatus,
            ),
            _DetailRow(
              label: 'Assigned Branch',
              value: profile.assignedBranch,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── A single detail row (Figma "detail-row-*" 3:165..) ───────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.showPencil = false,
    this.onPencil,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool showPencil;
  final VoidCallback? onPencil;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              if (showPencil)
                GestureDetector(
                  onTap: onPencil,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: Color(0xFF2249DC),
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
// ─── Change Portal Password button (Figma "button-container" 40:1416) ──────

class _ChangePasswordButton extends StatelessWidget {
  const _ChangePasswordButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const _ChangePasswordSheet(),
          ),
          borderRadius: BorderRadius.circular(100),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 18, color: Color(0xFF1A1A2E)),
              SizedBox(width: 8),
              Text(
                'Change Portal Password',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Edit phone bottom sheet (pencil on phone row) ─────────────────────────

Future<void> _showEditPhoneSheet(BuildContext context, String current) async {
  final controller = TextEditingController(text: current);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update Phone Number',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'Enter phone number',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                    color: const Color(0xFF2249DC).withValues(alpha: 0.7)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SavePhoneButton(controller: controller),
        ],
      ),
    ),
  );
}
class _SavePhoneButton extends ConsumerWidget {
  const _SavePhoneButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitting = ref.watch(
      updatePhoneControllerProvider.select((s) => s.isLoading),
    );
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: submitting
            ? null
            : () async {
                final phone = controller.text.trim();
                if (phone.isEmpty) return;
                final ok = await ref
                    .read(updatePhoneControllerProvider.notifier)
                    .updatePhone(phone);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Phone number updated.'
                          : 'Unable to update phone number.',
                    ),
                  ),
                );
              },
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2249DC),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF2249DC).withValues(alpha: 0.5),
          shape: const StadiumBorder(),
        ),
        child: submitting
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Save',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

// ─── Change password bottom sheet ──────────────────────────────────────────

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}
class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Portal password updated successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Portal Password',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: _currentController,
              label: 'Current Password',
              hint: 'Enter current password',
            ),
            const SizedBox(height: 12),
            _PasswordField(
              controller: _newController,
              label: 'New Password',
              hint: 'Enter new password',
            ),
            const SizedBox(height: 12),
            _PasswordField(
              controller: _confirmController,
              label: 'Confirm New Password',
              hint: 'Re-enter new password',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2249DC),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF2249DC).withValues(alpha: 0.5),
                  shape: const StadiumBorder(),
                ),
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Update Password',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF94A3B8),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(
              color: const Color(0xFF2249DC).withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

// ─── Error view ────────────────────────────────────────────────────────────

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