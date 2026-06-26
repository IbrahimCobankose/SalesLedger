import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_ledger/core/backup/backup_service.dart';
import 'package:sales_ledger/core/constants/app_limits.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/l10n/locale_provider.dart';
import 'package:sales_ledger/core/network/supabase_client.dart';
import 'package:sales_ledger/core/storage/storage_image.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/core/widgets/custom_button.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/auth/presentation/providers/profile_provider.dart';

/// Ayarlar ekranı: aktif profilin adını/fotoğrafını düzenleme, dil seçimi
/// (TR/EN) ve hesap/uygulama bilgileri.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const _appVersion = '1.0.0';

  final _nameController = TextEditingController();
  Uint8List? _newAvatarBytes;
  String _avatarExtension = 'jpg';
  bool _isSaving = false;
  bool _isPickingPhoto = false;
  bool _isBackingUp = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_isPickingPhoto) return;
    _isPickingPhoto = true;
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final name = picked.name.toLowerCase();
      final ext = name.contains('.') ? name.split('.').last : 'jpg';
      setState(() {
        _newAvatarBytes = bytes;
        _avatarExtension = ext;
      });
    } on PlatformException {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: context.l10n.commonPhotoPickFailed,
          isError: true,
        );
      }
    } finally {
      _isPickingPhoto = false;
    }
  }

  Future<void> _saveProfile() async {
    final current = ref.read(selectedProfileProvider);
    if (current == null) return;

    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      CustomSnackbar.show(context, message: context.l10n.settingsProfileNameEmpty, isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updated = await ref.read(profileRepositoryProvider).updateProfile(
            current.copyWith(name: newName),
            newAvatarBytes: _newAvatarBytes,
            avatarExtension: _avatarExtension,
          );
      // Aktif profili güncelle ki üst çubuk/menü anında yansısın.
      ref.read(selectedProfileProvider.notifier).select(updated);
      if (mounted) {
        setState(() => _newAvatarBytes = null);
        CustomSnackbar.show(context, message: context.l10n.settingsProfileUpdated, isError: false);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: e is AppException ? e.message : context.l10n.settingsProfileUpdateFailed,
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _exportBackup() async {
    if (_isBackingUp) return;
    setState(() => _isBackingUp = true);
    try {
      final path = await BackupService.exportAll();
      if (mounted) {
        CustomSnackbar.show(context, message: context.l10n.settingsBackupSuccess(path), isError: false);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: e is AppException ? e.message : context.l10n.settingsBackupFailed,
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final profile = ref.watch(selectedProfileProvider);
    final locale = ref.watch(localeProvider);
    final email = supabase.auth.currentUser?.email ?? '';

    // Ad alanını ilk açılışta aktif profil adıyla doldur.
    if (!_initialized && profile != null) {
      _nameController.text = profile.name;
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: Text(l10n.settingsTitle), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Profil düzenleme ---
                  _Section(
                    title: l10n.settingsProfileSection,
                    icon: Icons.account_circle_outlined,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickPhoto,
                          child: Stack(
                            children: [
                              StorageAvatar(
                                radius: 44,
                                path: profile?.avatarUrl,
                                overrideImage: _newAvatarBytes != null
                                    ? MemoryImage(_newAvatarBytes!)
                                    : null,
                                backgroundColor: colorScheme.surfaceContainer,
                                fallback: Text(
                                  profile?.name.isNotEmpty == true
                                      ? profile!.name[0].toUpperCase()
                                      : '?',
                                  style: textTheme.headlineSmall
                                      ?.copyWith(color: colorScheme.primary),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: colorScheme.primary,
                                  child: Icon(Icons.edit, size: 14, color: colorScheme.onPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        maxLength: AppLimits.maxProfileNameLength,
                        decoration: InputDecoration(
                          labelText: l10n.settingsProfileNameLabel,
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: l10n.commonSave,
                        isLoading: _isSaving,
                        onPressed: _saveProfile,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Dil seçimi ---
                  _Section(
                    title: l10n.settingsLanguageSection,
                    icon: Icons.language,
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'tr', label: Text('Türkçe')),
                          ButtonSegment(value: 'en', label: Text('English')),
                        ],
                        selected: {locale.languageCode},
                        onSelectionChanged: (selection) {
                          ref.read(localeProvider.notifier).setLocale(Locale(selection.first));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Yedekleme (salt dışa aktarma) ---
                  _Section(
                    title: l10n.settingsBackupSection,
                    icon: Icons.backup_outlined,
                    children: [
                      Text(
                        l10n.settingsBackupDescription,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: l10n.settingsBackupExport,
                        isLoading: _isBackingUp,
                        onPressed: _exportBackup,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Hesap / Uygulama bilgisi ---
                  _Section(
                    title: l10n.settingsAccountSection,
                    icon: Icons.info_outline,
                    children: [
                      _InfoRow(label: l10n.settingsEmailLabel, value: email),
                      const Divider(height: 24),
                      _InfoRow(label: l10n.settingsAppVersion, value: _appVersion),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.children});

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
