import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_dimensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_progress_button.dart';
import '../providers/feature_providers.dart';

class CreateFeatureScreen extends ConsumerStatefulWidget {
  const CreateFeatureScreen({super.key});

  @override
  ConsumerState<CreateFeatureScreen> createState() => _CreateFeatureScreenState();
}

class _CreateFeatureScreenState extends ConsumerState<CreateFeatureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await ref.read(createFeatureControllerProvider.notifier).createFeature(
          name: _nameController.text.trim(),
        );
    if (!mounted) return;
    if (ok) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create the feature.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting =
        ref.watch(createFeatureControllerProvider.select((s) => s.isLoading));

    return Scaffold(
      appBar: AppBar(title: const Text('New Feature')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.defaultHorizontalPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Feature name',
                    hintText: 'e.g. Expense module',
                  ),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Name is required.' : null,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryProgressButton(
                  onPressed: _submit,
                  label: 'Create',
                  isLoading: submitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}