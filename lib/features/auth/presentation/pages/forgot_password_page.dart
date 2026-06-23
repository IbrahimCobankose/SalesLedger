import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/core/widgets/custom_button.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/auth/presentation/providers/auth_provider.dart';
import 'package:sales_ledger/features/auth/presentation/widgets/auth_text_field.dart';

/// "Şifremi Unuttum" ekranı: kullanıcı e-postasını girer, Supabase şifre
/// sıfırlama bağlantısını o adrese gönderir.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSending = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    try {
      await ref.read(sendPasswordResetUseCaseProvider)(
        email: _emailController.text.trim(),
      );
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: e is AppException ? e.message : 'Bir hata oluştu. Lütfen tekrar deneyin.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
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
                  padding: const EdgeInsets.all(32),
                  child: _sent ? _buildSentState(colorScheme, textTheme) : _buildFormState(textTheme),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState(TextTheme textTheme) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.lock_reset, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Şifrenizi mi unuttunuz?',
            style: textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Hesabınıza kayıtlı e-posta adresini girin, şifre sıfırlama bağlantısı gönderelim.',
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AuthTextField(
            label: 'E-posta',
            hint: 'ornek@sirket.com',
            icon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'E-posta gerekli';
              }
              if (!value.contains('@')) {
                return 'Geçerli bir e-posta girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Sıfırlama Bağlantısı Gönder',
            isLoading: _isSending,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildSentState(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read_outlined, size: 40, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(height: 24),
        Text(
          'Bağlantı Gönderildi',
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '${_emailController.text.trim()} adresine şifre sıfırlama bağlantısı gönderdik. '
          'Gelen kutunuzu kontrol edin.',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Giriş Sayfasına Dön',
          icon: Icons.login,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
