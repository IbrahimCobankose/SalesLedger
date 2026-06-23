import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/router/app_router.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/core/widgets/custom_button.dart' show PrimaryButton;
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/auth/presentation/providers/auth_provider.dart';

/// Kayıt sonrası e-posta doğrulama bekleme ekranı.
///
/// Kullanıcıya doğrulama e-postası gönderildiği bildirilir.
/// E-postasını doğruladıktan sonra giriş sayfasına yönlendirilir.
class EmailVerificationPage extends ConsumerStatefulWidget {
  /// Doğrulama e-postasının gönderildiği adres.
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState
    extends ConsumerState<EmailVerificationPage> {
  bool _resending = false;

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await ref
          .read(resendVerificationEmailProvider)
          .resendVerificationEmail(email: widget.email);
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Doğrulama e-postası yeniden gönderildi.',
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: e is AppException
              ? e.message
              : 'E-posta gönderilemedi. Lütfen tekrar deneyin.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // İkon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mark_email_unread_outlined,
                          size: 40,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Başlık
                      Text(
                        'E-postanızı Doğrulayın',
                        style: textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Açıklama
                      Text(
                        'Şu adrese doğrulama bağlantısı gönderdik:',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // E-posta adresi
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.email,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Bağlantıya tıkladıktan sonra aşağıdaki "Giriş Yap" butonuna basın.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Giriş Yap butonu
                      PrimaryButton(
                        label: 'Giriş Yap',
                        icon: Icons.login,
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                      const SizedBox(height: 12),

                      // Tekrar Gönder butonu
                      OutlinedButton(
                        onPressed: _resending ? null : _resend,
                        child: _resending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Tekrar Gönder'),
                      ),
                      const SizedBox(height: 16),

                      // Spam uyarısı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'E-posta gelmezse spam/gereksiz klasörünü kontrol edin.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
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
