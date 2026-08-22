import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

/// Change Password screen reached from Settings (Figma settings row).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;

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
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully.')),
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
          'Change Password',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF161616),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  children: [
                    _pillLabel('Current Password'),
                    const SizedBox(height: 8),
                    _PasswordPill(
                      controller: _currentController,
                      validator: (v) => (v ?? '').isEmpty
                          ? 'Current password is required.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _pillLabel('New Password'),
                    const SizedBox(height: 8),
                    _PasswordPill(
                      controller: _newController,
                      validator: (v) => _passwordError(v),
                    ),
                    const SizedBox(height: 16),
                    // Figma 65:5970-65:5975 — password requirements block.
                    Text(
                      'Password must include:',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF777777),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const _PasswordRule(text: '8 or more characters'),
                    const SizedBox(height: 4),
                    const _PasswordRule(text: '1 uppercase Letter'),
                    const SizedBox(height: 4),
                    const _PasswordRule(text: '1 number'),
                    const SizedBox(height: 4),
                    const _PasswordRule(text: '1 special character'),
                    const SizedBox(height: 16),
                    _pillLabel('Confirm New Password'),
                    const SizedBox(height: 8),
                    _PasswordPill(
                      controller: _confirmController,
                      validator: (v) => v != _newController.text
                          ? 'Passwords do not match.'
                          : null,
                    ),
                  ],
                ),
              ),
              // Bottom button bar (Figma style)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(top: BorderSide(color: Color(0xFFF7F7F7))),
                ),
                child: SizedBox(
                  height: 45,
                  child: FilledButton(
                    onPressed: _saving ? null : _submit,
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
                            'Change Password',
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
      ),
    );
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

  String? _passwordError(String? value) {
    final v = value ?? '';
    if (v.length < 8) return 'Must be at least 8 characters.';
    if (!v.contains(RegExp(r'[A-Z]'))) {
      return 'Must include 1 uppercase letter.';
    }
    if (!v.contains(RegExp(r'[0-9]'))) return 'Must include 1 number.';
    if (!v.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return 'Must include 1 special character.';
    }
    return null;
  }
}

/// Pill password field matching Figma (white fill, #D9D9D9 stroke, radius
/// full, obscured with a visibility_off eye icon at right).
class _PasswordPill extends StatefulWidget {
  const _PasswordPill({required this.controller, this.validator});

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  @override
  State<_PasswordPill> createState() => _PasswordPillState();
}

class _PasswordPillState extends State<_PasswordPill> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscured,
        validator: widget.validator,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF161616),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: InkWell(
            onTap: () => setState(() => _obscured = !_obscured),
            child: Icon(
              _obscured
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 20,
              color: const Color(0xFF777777),
            ),
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
}

/// Single password requirement line (Figma 65:5972-65:5975).
class _PasswordRule extends StatelessWidget {
  const _PasswordRule({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Icon(
            Icons.circle,
            size: 3,
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF777777),
            ),
          ),
        ),
      ],
    );
  }
}