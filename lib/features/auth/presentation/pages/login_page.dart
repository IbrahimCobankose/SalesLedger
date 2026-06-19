import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/auth/presentation/pages/register_page.dart';
import 'package:sales_ledger/features/auth/presentation/pages/profile_selection_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // GİRİŞ İŞLEMİ
  // ---------------------------------------------------------------------------
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProfileSelectionPage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(context, message: _mapAuthError(e.message), isError: true);
    } catch (_) {
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
  // ŞİFRE SIFIRLAMA
  // ---------------------------------------------------------------------------
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Lütfen önce e-posta adresinizi girin.',
        isError: true,
      );
      return;
    }

    try {
      await _supabase.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: 'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.',
        isError: false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(context, message: _mapAuthError(e.message), isError: true);
    }
  }

  // ---------------------------------------------------------------------------
  // HATA MESAJLARI
  // ---------------------------------------------------------------------------
  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials') ||
        message.contains('invalid_credentials')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (message.contains('Email not confirmed')) {
      return 'E-posta adresiniz doğrulanmamış. Lütfen gelen kutunuzu kontrol edin.';
    }
    if (message.contains('rate limit')) {
      return 'Çok fazla deneme yapıldı. Lütfen bir süre bekleyin.';
    }
    return 'Giriş sırasında bir hata oluştu.';
  }

  // ---------------------------------------------------------------------------
  // DOĞRULAMA KURALLARI
  // ---------------------------------------------------------------------------
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-posta boş bırakılamaz.';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Geçerli bir e-posta girin.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Şifre boş bırakılamaz.';
    return null;
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
    );
  }

  // ── TABLET / DESKTOP: İKİ PANEL ────────────────────────────────────────────
  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(child: _buildBrandPanel()),
        Expanded(child: _buildFormPanel()),
      ],
    );
  }

  // ── MOBİL: SADECE FORM ─────────────────────────────────────────────────────
  Widget _buildNarrowLayout() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: _buildFormContent(maxWidth: 420),
        ),
      ),
    );
  }

  // ── SOL PANEL: MARKA ───────────────────────────────────────────────────────
  Widget _buildBrandPanel() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primary,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Nokta deseni
          Positioned.fill(
            child: CustomPaint(painter: _DotPatternPainter()),
          ),
          // İçerik
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Görsel kutu
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 360),
                        
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: colorScheme.surfaceContainerHighest,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.surfaceContainerLow,
                                    colorScheme.surfaceContainer,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.bar_chart_rounded,
                                size: 120,
                                color: colorScheme.primary.withOpacity(0.15),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Slogan
                      Text(
                        'Satışlarınızı\nKontrol Altına Alın',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Güvenilir, verimli ve hassas raporlama\naraçlarıyla işinizi her yerden kolayca yönetin.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer
                                  .withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SAĞ PANEL: FORM WRAPPER ─────────────────────────────────────────────────
  Widget _buildFormPanel() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: _buildFormContent(maxWidth: 420),
        ),
      ),
    );
  }

  // ── FORM İÇERİĞİ (her iki layoutta da kullanılır) ──────────────────────────
  Widget _buildFormContent({required double maxWidth}) {
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fadeAnim,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── BAŞLIK ───────────────────────────────────────────────────────
            _buildBrandHeader(colorScheme),
            const SizedBox(height: 32),

            // ── FORM ─────────────────────────────────────────────────────────
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // E-posta
                  _buildLabel('E-posta Adresi'),
                  const SizedBox(height: 8),
                  _buildEmailField(colorScheme),
                  const SizedBox(height: 20),

                  // Şifre başlık satırı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Şifre'),
                      GestureDetector(
                        onTap: _forgotPassword,
                        child: Text(
                          'Şifremi Unuttum',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildPasswordField(colorScheme),
                  const SizedBox(height: 28),

                  // Giriş Yap Butonu
                  _buildSubmitButton(colorScheme),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── HESAP OLUŞTUR BAĞLANTISI ─────────────────────────────────────
            _buildRegisterLink(colorScheme),
          ],
        ),
      ),
    );
  }

  // ── MARKA BAŞLIĞI ──────────────────────────────────────────────────────────
  Widget _buildBrandHeader(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: colorScheme.onPrimaryContainer,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Satış Defteri',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hesabınıza giriş yapın ve yönetime başlayın.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  // ── LABEL ──────────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: 0.8,
          ),
    );
  }

  // ── E-POSTA ALANI ──────────────────────────────────────────────────────────
  Widget _buildEmailField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: _validateEmail,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
      decoration: _inputDecoration(
        colorScheme: colorScheme,
        hintText: 'ornek@sirket.com',
        prefixIcon: Icons.mail_rounded,
      ),
    );
  }

  // ── ŞİFRE ALANI ────────────────────────────────────────────────────────────
  Widget _buildPasswordField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      validator: _validatePassword,
      onFieldSubmitted: (_) => _login(),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
      decoration: _inputDecoration(
        colorScheme: colorScheme,
        hintText: '••••••••',
        prefixIcon: Icons.lock_rounded,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: colorScheme.outline,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    );
  }

  // ── INPUT DECORATION ───────────────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required ColorScheme colorScheme,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: colorScheme.outline),
      prefixIcon: Icon(prefixIcon, color: colorScheme.outline),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
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
    );
  }

  // ── GİRİŞ YAP BUTONU ───────────────────────────────────────────────────────
  Widget _buildSubmitButton(ColorScheme colorScheme) {
    return _HoverButton(
      onPressed: _isLoading ? null : _login,
      isLoading: _isLoading,
      colorScheme: colorScheme,
    );
  }

  // ── KAYIT BAĞLANTISI ───────────────────────────────────────────────────────
  Widget _buildRegisterLink(ColorScheme colorScheme) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hesabınız yok mu? ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            ),
            child: Text(
              'Hesap Oluştur',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: colorScheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── HOVER EFFECTLİ GİRİŞ BUTONU ────────────────────────────────────────────
class _HoverButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final ColorScheme colorScheme;

  const _HoverButton({
    required this.onPressed,
    required this.isLoading,
    required this.colorScheme,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered && widget.onPressed != null ? 1.01 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _hovered && widget.onPressed != null
                ? const Color(0xFF1A9FFF)
                : cs.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hovered && widget.onPressed != null
                ? [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimaryContainer,
                        ),
                      )
                    else ...[
                      Text(
                        'Giriş Yap',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: cs.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      AnimatedSlide(
                        offset: _hovered ? Offset.zero : const Offset(-0.3, 0),
                        duration: const Duration(milliseconds: 250),
                        child: AnimatedOpacity(
                          opacity: _hovered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: cs.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── NOKTELİ ARKA PLAN DESENİ ────────────────────────────────────────────────
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    const spacing = 60.0;
    const radius = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter oldDelegate) => false;
}