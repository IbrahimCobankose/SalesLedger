import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/auth/presentation/pages/add_profile_page.dart';
import 'package:sales_ledger/features/auth/presentation/pages/login_page.dart';

/// Bir hesaba bağlı profillerin listelendiği ve seçildiği sayfa.
/// Giriş yapıldıktan sonra bu sayfa gösterilir.
class ProfileSelectionPage extends StatefulWidget {
  const ProfileSelectionPage({super.key});

  @override
  State<ProfileSelectionPage> createState() => _ProfileSelectionPageState();
}

class _ProfileSelectionPageState extends State<ProfileSelectionPage> {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  // ---------------------------------------------------------------------------
  // VERİ
  // ---------------------------------------------------------------------------
  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('profiles')
          .select('id, name, avatar_url, created_at')
          .order('created_at', ascending: true);

      if (mounted) setState(() => _profiles = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Profiller yüklenirken hata oluştu.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _selectProfile(Map<String, dynamic> profile) {
    // Seçilen profili uygulama state'ine kaydet ve ana sayfaya geç.
    // Şimdilik sadece snackbar gösteriyoruz; ilerleyen adımda
    // state management (Provider / Riverpod) eklenecek.
    CustomSnackbar.show(
      context,
      message: '${profile['name']} profiliyle devam ediliyor.',
      isError: false,
    );

    // TODO: Ana sayfaya (SalesPage / Dashboard) yönlendir
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (_) => HomePage(profileId: profile['id'])),
    //   (route) => false,
    // );
  }

  void _goToAddProfile() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddProfilePage()))
        .then((_) => _loadProfiles()); // Geri dönünce listeyi yenile
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(colorScheme),
            ),
            _buildFooter(colorScheme),
          ],
        ),
      ),
    );
  }

  // ── ANA İÇERİK ─────────────────────────────────────────────────────────────
  Widget _buildContent(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          _buildHeader(colorScheme),
          const SizedBox(height: 32),
          _buildProfileGrid(colorScheme),
        ],
      ),
    );
  }

  // ── BAŞLIK ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.menu_book_rounded,
            color: colorScheme.onPrimaryContainer,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Profil Seçiniz',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Satış Defteri\'ne giriş yapmak için\nkullanmak istediğiniz profili seçin.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  // ── PROFİL GRİDİ ───────────────────────────────────────────────────────────
  Widget _buildProfileGrid(ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobil: 1 sütun | sm: 2 sütun | md+: 3 sütun
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 600) crossAxisCount = 2;
        if (constraints.maxWidth >= 900) crossAxisCount = 3;

        final allItems = [
          ..._profiles.asMap().entries.map(
                (entry) => _ProfileCardItem.profile(
                  index: entry.key,
                  profile: entry.value,
                ),
              ),
          _ProfileCardItem.addNew(),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: allItems.length,
          itemBuilder: (context, index) {
            final item = allItems[index];
            if (item.isAddNew) {
              return _AddNewProfileCard(
                animationIndex: index,
                onTap: _goToAddProfile,
              );
            }
            return _ProfileCard(
              animationIndex: index,
              profile: item.profile!,
              onTap: () => _selectProfile(item.profile!),
              onLongPress: () => _showProfileOptions(item.profile!),
            );
          },
        );
      },
    );
  }

  // ── ALT ÇUBUK ──────────────────────────────────────────────────────────────
  Widget _buildFooter(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.surfaceContainerHigh),
        ),
      ),
      child: TextButton.icon(
        onPressed: _signOut,
        icon: Icon(Icons.logout_rounded,
            size: 18, color: colorScheme.onSurfaceVariant),
        label: Text(
          'Hesap Yönetimi',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  // ── PROFİL SEÇENEKLER BOTTOM SHEET ────────────────────────────────────────
  void _showProfileOptions(Map<String, dynamic> profile) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: colorScheme.surfaceContainerLowest,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit_rounded, color: colorScheme.primary),
                title: const Text('Profili Düzenle'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (_) =>
                              AddProfilePage(editProfile: profile)))
                      .then((_) => _loadProfiles());
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.delete_rounded, color: colorScheme.error),
                title: Text('Profili Sil',
                    style: TextStyle(color: colorScheme.error)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteProfile(profile);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PROFİL SİL ONAY DİYALOĞU ──────────────────────────────────────────────
  Future<void> _confirmDeleteProfile(Map<String, dynamic> profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profili Sil'),
        content: Text(
            '"${profile['name']}" profilini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _supabase.from('profiles').delete().eq('id', profile['id']);
      if (mounted) {
        CustomSnackbar.show(context,
            message: 'Profil silindi.', isError: false);
        _loadProfiles();
      }
    } catch (_) {
      if (mounted) {
        CustomSnackbar.show(context,
            message: 'Profil silinirken hata oluştu.', isError: true);
      }
    }
  }
}

// ── VERİ SINIFI ────────────────────────────────────────────────────────────
class _ProfileCardItem {
  final Map<String, dynamic>? profile;
  final int index;
  final bool isAddNew;

  _ProfileCardItem.profile({required this.index, required this.profile})
      : isAddNew = false;

  _ProfileCardItem.addNew()
      : profile = null,
        index = -1,
        isAddNew = true;
}

// ── PROFİL KARTI ───────────────────────────────────────────────────────────
class _ProfileCard extends StatefulWidget {
  final int animationIndex;
  final Map<String, dynamic> profile;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ProfileCard({
    required this.animationIndex,
    required this.profile,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Staggered delay: her kart biraz sonra açılır
    Future.delayed(
      Duration(milliseconds: 100 * (widget.animationIndex + 1)),
      () { if (mounted) _ctrl.forward(); },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _initials {
    final name = widget.profile['name'] as String? ?? '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarUrl = widget.profile['avatar_url'] as String?;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()
              ..translate(0.0, _hovered ? -4.0 : 0.0),
            child: GestureDetector(
              onLongPress: widget.onLongPress,
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _hovered
                        ? colorScheme.primaryFixed
                        : colorScheme.outlineVariant,
                    width: _hovered ? 1.5 : 1,
                  ),
                ),
                elevation: _hovered ? 4 : 0,
                shadowColor: colorScheme.primary.withOpacity(0.15),
                child: InkWell(
                  onTap: widget.onTap,
                  child: Stack(
                    children: [
                      // Hover overlay
                      if (_hovered)
                        Positioned.fill(
                          child: Container(
                            color: colorScheme.primary.withOpacity(0.04),
                          ),
                        ),
                      // İçerik
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Avatar
                            _buildAvatar(colorScheme, avatarUrl),
                            const SizedBox(height: 16),
                            // İsim
                            Text(
                              widget.profile['name'] ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme, String? avatarUrl) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _hovered
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerLow,
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 44,
            backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    _initials,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

// ── YENİ PROFİL EKLE KARTI ─────────────────────────────────────────────────
class _AddNewProfileCard extends StatefulWidget {
  final int animationIndex;
  final VoidCallback onTap;

  const _AddNewProfileCard({
    required this.animationIndex,
    required this.onTap,
  });

  @override
  State<_AddNewProfileCard> createState() => _AddNewProfileCardState();
}

class _AddNewProfileCardState extends State<_AddNewProfileCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(
      Duration(milliseconds: 100 * (widget.animationIndex + 1)),
      () { if (mounted) _ctrl.forward(); },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()
              ..translate(0.0, _hovered ? -4.0 : 0.0),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _hovered
                      ? colorScheme.surfaceContainerLow
                      : colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hovered
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    width: _hovered ? 1.5 : 1,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _hovered
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainer,
                        shape: BoxShape.circle,
                        boxShadow: _hovered
                            ? [
                                BoxShadow(
                                  color:
                                      colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 36,
                        color: _hovered
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Yeni Profil Ekle',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Farklı bir hesapla giriş yapın',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
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