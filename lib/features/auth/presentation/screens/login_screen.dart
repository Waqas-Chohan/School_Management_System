import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';

/// Login page reproduced 1:1 from the Figma "Login Page" frame (65:7655).
///
/// Screen: 390 x 844 · Background image fill · Centered 350px login card.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    // Prefill the demo credentials so the login screen is instantly usable.
    _emailController = TextEditingController(text: 'mariam.khan0@school.edu');
    _passwordController = TextEditingController(text: 'teacher123');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = ref.read(loginControllerProvider.notifier);
    final success = await controller.signIn(
      username: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      final error = ref.read(loginControllerProvider.notifier).errorOrNull;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error?.message ?? 'Unable to log in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(
      loginControllerProvider.select((s) => s.isLoading),
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed background image from the Figma frame.
          Image.asset('assets/images/login_background.png', fit: BoxFit.cover),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Scrollable, keyboard-safe layout. Matches the Figma top
                // spacing: 136px gap to the login card (status bar removed).
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 136),
                        Form(
                          key: _formKey,
                          child: _LoginCardGroup(
                            emailController: _emailController,
                            passwordController: _passwordController,
                            submitting: submitting,
                            onSubmit: _submit,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Login card group 350x484 (Figma "Frame 2147224603" 117:2114) ──────────

class _LoginCardGroup extends StatelessWidget {
  const _LoginCardGroup({
    required this.emailController,
    required this.passwordController,
    required this.submitting,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LoginCard(
                emailController: emailController,
                passwordController: passwordController,
                submitting: submitting,
                onSubmit: onSubmit,
              ),
              const SizedBox(height: 12),
              const _SupportInfo(),
            ],
          ),
        ),
      ),
    );
  }
}
// ─── White login card (Figma 65:7666) ──────────────────────────────────────

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.submitting,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const _SchoolCrest(),
          const SizedBox(height: 28),
          _FrameOne(
            emailController: emailController,
            passwordController: passwordController,
            submitting: submitting,
            onSubmit: onSubmit,
          ),
        ],
      ),
    );
  }
}

// ─── School crest (Fig 65:7667): circle 56 + "Teacher Portal Login" ────────

class _SchoolCrest extends StatelessWidget {
  const _SchoolCrest();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppTheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 28,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Teacher Portal Login',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkText,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─── Form area (Fig "Frame 1" 65:7672) ─────────────────────────────────────

class _FrameOne extends StatelessWidget {
  const _FrameOne({
    required this.emailController,
    required this.passwordController,
    required this.submitting,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LoginField(
          label: 'School Email Address',
          controller: emailController,
          hintText: 'e.g john.doe@school.com',
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final email = value?.trim() ?? '';
            if (email.isEmpty) return 'Email address is required.';
            if (!email.contains('@')) return 'Enter a valid email address.';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _LoginField(
          label: 'Password',
          controller: passwordController,
          hintText: 'Enter your password',
          obscure: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmit(),
          validator: (value) {
            if ((value ?? '').isEmpty) return 'Password is required.';
            return null;
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 45,
          child: FilledButton(
            onPressed: submitting ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.primary,
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
                    'Sign In',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: submitting ? null : () {},
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primary,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 21),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot Password?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
// ─── Label + pill field (Figma "Full name" 117:2099 / 117:2103) ─────────────

class _LoginField extends StatefulWidget {
  const _LoginField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  State<_LoginField> createState() => _LoginFieldState();
}

class _LoginFieldState extends State<_LoginField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.greyText,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 45,
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscure,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            validator: widget.validator,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.darkText,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.greyText,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                borderSide: BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                borderSide: BorderSide(
                  color: AppTheme.primary.withValues(alpha: 0.7),
                ),
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                borderSide: BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                borderSide: BorderSide(color: Colors.redAccent),
              ),
              suffixIcon: widget.obscure
                  ? IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 18,
                        color: AppTheme.greyText,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Support info (Figma 65:7686) ───────────────────────────────────────────

class _SupportInfo extends StatelessWidget {
  const _SupportInfo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Trouble logging in? Contact IT Support Desk',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF737373),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'support@stxaviers.edu',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6E706F),
          ),
        ),
      ],
    );
  }
}
