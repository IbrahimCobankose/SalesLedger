import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/constants/app_limits.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/core/widgets/custom_button.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/auth/presentation/providers/auth_provider.dart';
import 'package:sales_ledger/features/auth/presentation/widgets/auth_text_field.dart';

/// hesap_oluştur.html taslağına karşılık gelen kayıt ekranı.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).signUp(
          companyName: _companyNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!success && mounted) {
      final error = ref.read(authControllerProvider).error;
      CustomSnackbar.show(
        context,
        message: error is AppException ? error.message : context.l10n.registerFailed,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                margin: EdgeInsets.zero,
                color: colorScheme.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.surfaceContainerHighest),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.storefront, color: colorScheme.primary, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          l10n.registerTitle,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.registerWelcome,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        AuthTextField(
                          label: l10n.registerCompanyName,
                          hint: l10n.registerCompanyNameHint,
                          icon: Icons.business_outlined,
                          controller: _companyNameController,
                          maxLength: AppLimits.maxProfileNameLength,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.registerCompanyNameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          label: l10n.registerEmail,
                          hint: l10n.loginEmailHint,
                          icon: Icons.mail_outline,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.loginEmailRequired;
                            }
                            if (!value.contains('@')) {
                              return l10n.loginEmailInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          label: l10n.registerPassword,
                          hint: l10n.loginPasswordHint,
                          icon: Icons.lock_outline,
                          controller: _passwordController,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < AppLimits.minPasswordLength) {
                              return l10n.registerPasswordTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: l10n.registerSubmit,
                          icon: Icons.how_to_reg,
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Wrap(
                            children: [
                              Text(
                                l10n.registerHaveAccount,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: Text(
                                  l10n.registerLogin,
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: colorScheme.primary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
