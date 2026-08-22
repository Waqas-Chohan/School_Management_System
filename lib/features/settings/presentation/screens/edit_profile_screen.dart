import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

/// Edit Profile screen reproduced from the Figma "Edit Profile" design
/// (65:5931): avatar + "Change Profile Picture", pill input fields for Full
/// Name / Email / Phone / Date of Birth / Gender, and the bottom Save bar.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late DateTime _dob;
  String _gender = 'Male';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;
    _nameController = TextEditingController(
        text: profile?.fullName ?? 'Abdullah Mubashir');
    _emailController = TextEditingController(
        text: profile?.email ?? 'abdullah.m@teachdesk.edu');
    _phoneController = TextEditingController(
        text: profile?.phone ?? '+1 (555) 019-2834');
    _dob = profile?.dateJoined ?? DateTime(1998, 10, 14);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully.')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: Text(
          'Edit Profile',
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
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                children: [
                  // Avatar + "Change Profile Picture" (Figma 65:5941)
                  Column(
                    children: [
                      Stack(
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
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2249DC),
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(
                                  BorderSide(color: Colors.white, width: 2),
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Change Profile Picture',
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
                  _inputPill(_nameController),
                  const SizedBox(height: 16),
                  _pillLabel('Email Address'),
                  const SizedBox(height: 8),
                  _inputPill(_emailController,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _pillLabel('Phone Number'),
                  const SizedBox(height: 8),
                  _inputPill(_phoneController,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _pillLabel('Date of Birth'),
                  const SizedBox(height: 8),
                  _tapPill(
                    value: 'October ${_dob.day}, ${_dob.year}',
                    onTap: _pickDob,
                  ),
                  const SizedBox(height: 16),
                  _pillLabel('Gender'),
                  const SizedBox(height: 8),
                  _tapPill(
                    value: _gender,
                    onTap: () => _pickGender(),
                    showChevron: true,
                  ),
                ],
              ),
            ),
            // Bottom Save bar (Figma "Frame 1321317747" 65:5955)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF7F7F7))),
              ),
              child: SizedBox(
                height: 45,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppTheme.primary.withValues(alpha: 0.5),
                    shape: const StadiumBorder(),
                  ),
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save Changes',
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
      ),
    );
  }

  Future<void> _pickGender() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final g in ['Male', 'Female', 'Other'])
              ListTile(
                title: Text(
                  g,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF161616),
                  ),
                ),
                trailing: g == _gender
                    ? const Icon(Icons.check_rounded,
                        color: Color(0xFF2249DC))
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(g),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _gender = picked);
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

  Widget _inputPill(
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: 45,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF737373),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide(color: Color(0xFFD9D9D9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(100)),
            borderSide:
                BorderSide(color: AppTheme.primary.withValues(alpha: 0.7)),
          ),
        ),
      ),
    );
  }

  Widget _tapPill({
    required String value,
    required VoidCallback onTap,
    bool showChevron = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFFD9D9D9)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF737373),
                ),
              ),
            ),
            if (showChevron)
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: Color(0xFF737373)),
          ],
        ),
      ),
    );
  }
}