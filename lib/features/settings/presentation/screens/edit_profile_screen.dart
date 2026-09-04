import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_calendar_sheet.dart';
import '../../../profile/domain/entities/teacher_profile.dart';
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
  bool _initializedFromProfile = false;

  /// Whether the avatar uses a server path (relative) or a picked local file.
  String? _avatarPath;
  bool _avatarUploading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;
    _nameController = TextEditingController(
      text: profile?.fullName ?? 'Abdullah Mubashir',
    );
    _emailController = TextEditingController(
      text: profile?.email ?? 'abdullah.m@teachdesk.edu',
    );
    _phoneController = TextEditingController(
      text: profile?.phone ?? '+1 (555) 019-2834',
    );
    _dob = profile?.dob ?? profile?.dateJoined ?? DateTime(1998, 10, 14);
    _avatarPath = profile?.avatar;
    if (profile != null) {
      _initializedFromProfile = true;
      _gender = profile.gender.isNotEmpty ? profile.gender : 'Male';
    }
  }

  /// Applies the live profile to the form the first time it becomes available
  /// (covers the deep-link case where the profile is still loading when this
  /// screen opens).
  void _initializeFromProfile(TeacherProfile profile) {
    setState(() {
      _initializedFromProfile = true;
      _gender = profile.gender.isNotEmpty ? profile.gender : _gender;
      _nameController.text = profile.fullName.isNotEmpty
          ? profile.fullName
          : _nameController.text;
      _emailController.text = profile.email.isNotEmpty
          ? profile.email
          : _emailController.text;
      _phoneController.text = profile.phone.isNotEmpty
          ? profile.phone
          : _phoneController.text;
      if (profile.dob != null) _dob = profile.dob!;
      _avatarPath = profile.avatar;
    });
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    setState(() => _avatarUploading = true);
    // Preview the picked file immediately.
    final avatar = await ref
        .read(avatarUploadControllerProvider.notifier)
        .uploadAndSet(file.path);
    if (!mounted) return;
    setState(() {
      _avatarUploading = false;
      if (avatar != null) _avatarPath = avatar;
    });
    if (avatar == null) {
      final error = ref
          .read(avatarUploadControllerProvider.notifier)
          .errorOrNull;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error?.message ?? 'Unable to upload picture.')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showCalendarSheet(context, initialDate: _dob);
    if (picked != null) setState(() => _dob = picked);
  }

  String get _dobLabel {
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
    return '${months[_dob.month - 1]} ${_dob.day}, ${_dob.year}';
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final controller = ref.read(editProfileControllerProvider.notifier);
    setState(() => _saving = true);
    final ok = await controller.save(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      dob: _dob,
      phone: _phoneController.text.trim(),
      qualification: null,
      gender: _gender,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      context.pop();
    } else {
      final error = controller.errorOrNull;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error?.message ?? 'Unable to update profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Back-fill the form from the live profile if it arrives after this screen
    // opened (e.g. direct navigation while the profile was still loading).
    ref.listen(profileProvider, (prev, next) {
      final profile = next.value;
      if (profile != null && !_initializedFromProfile && mounted) {
        _initializeFromProfile(profile);
      }
    });

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
                      GestureDetector(
                        onTap: _pickAndUploadAvatar,
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: _avatarImage(),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: _avatarUploading
                                  ? Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2249DC),
                                        shape: BoxShape.circle,
                                        border: Border.fromBorderSide(
                                          BorderSide(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2249DC),
                                        shape: BoxShape.circle,
                                        border: Border.fromBorderSide(
                                          BorderSide(
                                            color: Colors.white,
                                            width: 2,
                                          ),
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
                  _inputPill(
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _pillLabel('Phone Number'),
                  const SizedBox(height: 8),
                  _inputPill(
                    _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _pillLabel('Date of Birth'),
                  const SizedBox(height: 8),
                  _tapPill(
                    value: _dobLabel,
                    onTap: _pickDob,
                    showCalendarIcon: true,
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
                    disabledBackgroundColor: AppTheme.primary.withValues(
                      alpha: 0.5,
                    ),
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
                    ? const Icon(Icons.check_rounded, color: Color(0xFF2249DC))
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(g),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _gender = picked);
  }

  /// Resolves the avatar to display: a picked local file, a server avatar URL
  /// (which can be a relative `/uploads/...` path), or the bundled fallback.
  DecorationImage? _avatarImage() {
    final raw = _avatarPath;
    if (raw == null || raw.isEmpty) {
      return const DecorationImage(
        image: AssetImage('assets/images/avatar.png'),
        fit: BoxFit.cover,
      );
    }
    if (raw.startsWith('/')) {
      // Server-relative path -> resolve against the host of the API base.
      final uri = Uri.parse(ApiEndpoints.baseUrl);
      final host = '${uri.scheme}://${uri.host}$raw';
      return DecorationImage(image: NetworkImage(host), fit: BoxFit.cover);
    }
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return DecorationImage(image: NetworkImage(raw), fit: BoxFit.cover);
    }
    // Local file preview from the image picker.
    final file = File(raw);
    if (file.existsSync()) {
      return DecorationImage(image: FileImage(file), fit: BoxFit.cover);
    }
    return null;
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
            borderSide: BorderSide(
              color: AppTheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tapPill({
    required String value,
    required VoidCallback onTap,
    bool showChevron = false,
    bool showCalendarIcon = false,
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
            if (showCalendarIcon)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Color(0xFF737373),
                ),
              ),
            if (showChevron)
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Color(0xFF737373),
              ),
          ],
        ),
      ),
    );
  }
}
