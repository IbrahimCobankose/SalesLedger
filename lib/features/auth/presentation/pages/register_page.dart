import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_ledger/core/theme/app_theme.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/auth/presentation/pages/login_page.dart';
import 'package:sales_ledger/features/auth/presentation/pages/profile_selection_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // KAYIT İŞLEMİ
  // ---------------------------------------------------------------------------
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Supabase Auth ile kullanıcı oluştur
      final response = await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'company_name': _companyNameController.text.trim(),
        },
      );

      if (!mounted) return;

      final user = response.user;

      // Supabase e-posta doğrulama aktifse kullanıcı henüz null gelmez;
      // session null olur. İkisini birden kontrol ediyoruz.
      if (user == null) {
        CustomSnackbar.show(
          context,
          message: 'Kayıt oluşturulamadı. Lütfen tekrar deneyin.',
          isError: true,
        );
        return;
      }

      // 2. profiles tablosuna varsayılan profil ekle (şirket adıyla)
      await _supabase.from('profiles').insert({
        'user_id': user.id,
        'name': _companyNameController.text.trim(),
      });

      if (!mounted) return;

      CustomSnackbar.show(
        context,
        message: 'Hesap başarıyla oluşturuldu!',
        isError: false,
      );

      // 3. Profil seçim sayfasına yönlendir
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProfileSelectionPage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      final message = _mapAuthError(e.message);
      CustomSnackbar.show(context, message: message, isError: true);
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: 'Beklenmedik bir hata oluştu. Lütfen tekrar deneyin.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // HATA MESAJLARINI TÜRKÇE'YE ÇEVİR
  // ---------------------------------------------------------------------------
  String _mapAuthError(String message) {
    if (message.contains('already registered') ||
        message.contains('User already registered')) {
      return 'Bu e-posta adresi zaten kayıtlı.';
    }
    if (message.contains('invalid email') ||
        message.contains('Invalid email')) {
      return 'Geçersiz e-posta adresi.';
    }
    if (message.contains('Password should be at least')) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    if (message.contains('rate limit')) {
      return 'Çok fazla istek gönderildi. Lütfen bir süre bekleyin.';
    }
    return 'Kayıt sırasında bir hata oluştu: $message';
  }

  // ---------------------------------------------------------------------------
  // DOĞRULAMA KURALLARI
  // ---------------------------------------------------------------------------
  String? _validateCompanyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Şirket adı boş bırakılamaz.';
    }
    if (value.trim().length < 2) {
      return 'Şirket adı en az 2 karakter olmalıdır.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta boş bırakılamaz.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi girin.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş bırakılamaz.';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı boş bırakılamaz.';
    }
    if (value != _passwordController.text) {
      return 'Şifreler eşleşmiyor.';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── LOGO & BAŞLIK ──────────────────────────────────────────
                  _buildHeader(colorScheme),
                  const SizedBox(height: 32),

                  // ── FORM KARTI ─────────────────────────────────────────────
                  _buildFormCard(colorScheme),
                  const SizedBox(height: 24),

                  // ── GİRİŞ BAĞLANTISI ──────────────────────────────────────
                  _buildLoginLink(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.storefront_rounded,
            size: 40,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Hesap Oluştur',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Satış Defteri\'ne hoş geldiniz.\nLütfen bilgilerinizi girin.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── FORM KARTI ─────────────────────────────────────────────────────────────
  Widget _buildFormCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Şirket Adı
              _buildTextField(
                controller: _companyNameController,
                label: 'Şirket Adı',
                hint: 'Örn: Yılmaz Ticaret',
                prefixIcon: Icons.business_rounded,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: _validateCompanyName,
              ),
              const SizedBox(height: 16),

              // E-posta
              _buildTextField(
                controller: _emailController,
                label: 'E-posta',
                hint: 'ornek@sirket.com',
                prefixIcon: Icons.mail_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),

              // Şifre
              _buildTextField(
                controller: _passwordController,
                label: 'Şifre',
                hint: '••••••••',
                prefixIcon: Icons.lock_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                validator: _validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),

              // Şifre Tekrar
              _buildTextField(
                controller: _confirmPasswordController,
                label: 'Şifre Tekrar',
                hint: '••••••••',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                validator: _validateConfirmPassword,
                onFieldSubmitted: (_) => _register(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 24),

              // Kayıt Ol Butonu
              _buildSubmitButton(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  // ── TEXT FIELD ─────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: colorScheme.onSurfaceVariant),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // ── SUBMIT BUTONU ──────────────────────────────────────────────────────────
  Widget _buildSubmitButton(ColorScheme colorScheme) {
    return FilledButton.icon(
      onPressed: _isLoading ? null : _register,
      icon: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.how_to_reg_rounded),
      label: Text(_isLoading ? 'Kayıt Oluşturuluyor...' : 'Kayıt Ol'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── GİRİŞ BAĞLANTISI ───────────────────────────────────────────────────────
  Widget _buildLoginLink(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Zaten bir hesabınız var mı? ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          ),
          child: Text(
            'Giriş Yap',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: colorScheme.primary,
                ),
          ),
        ),
      ],
    );
  }
}