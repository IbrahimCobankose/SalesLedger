import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';

/// Yeni profil ekleme veya mevcut profili düzenleme sayfası.
///
/// [editProfile] null ise yeni profil oluşturulur,
/// dolu geçilirse düzenleme modu aktif olur.
class AddProfilePage extends StatefulWidget {
  final Map<String, dynamic>? editProfile;

  const AddProfilePage({super.key, this.editProfile});

  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _selectedImageFile;
  String? _existingAvatarUrl;
  bool _isLoading = false;

  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  bool get _isEditMode => widget.editProfile != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final p = widget.editProfile!;
      _nameController.text = p['name'] ?? '';
      _existingAvatarUrl = p['avatar_url'] as String?;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // FOTOĞRAF SEÇ
  // ---------------------------------------------------------------------------
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (pickedFile != null && mounted) {
      setState(() => _selectedImageFile = File(pickedFile.path));
    }
  }

  // ---------------------------------------------------------------------------
  // KAYDET
  // ---------------------------------------------------------------------------
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;
      String? avatarUrl = _existingAvatarUrl;

      // Yeni fotoğraf seçildiyse Supabase Storage'a yükle
      if (_selectedImageFile != null) {
        final fileName =
            'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _supabase.storage.from('profiles').upload(
              fileName,
              _selectedImageFile!,
              fileOptions: const FileOptions(upsert: true),
            );
        avatarUrl = _supabase.storage.from('profiles').getPublicUrl(fileName);
      }

      final payload = {
        'name': _nameController.text.trim(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      if (_isEditMode) {
        await _supabase
            .from('profiles')
            .update(payload)
            .eq('id', widget.editProfile!['id']);
      } else {
        await _supabase.from('profiles').insert({
          ...payload,
          'user_id': userId,
        });
      }

      if (!mounted) return;

      CustomSnackbar.show(
        context,
        message: _isEditMode ? 'Profil güncellendi.' : 'Profil oluşturuldu.',
        isError: false,
      );
      Navigator.of(context).pop();
    } on StorageException catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Fotoğraf yüklenemedi: ${e.message}',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Profil kaydedilemedi. Lütfen tekrar deneyin.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── FORM KARTI ──────────────────────────────────────────
                  _buildFormCard(colorScheme),
                  const SizedBox(height: 32),

                  // ── KAYDET BUTONU ───────────────────────────────────────
                  _buildSaveButton(colorScheme),
                  const SizedBox(height: 12),

                  // ── İPTAL BUTONU ────────────────────────────────────────
                  _buildCancelButton(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        color: colorScheme.onSurfaceVariant,
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Geri',
      ),
      title: Text(
        _isEditMode ? 'Profili Düzenle' : 'Profil Ekle',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
      centerTitle: true,
      actions: const [SizedBox(width: 48)], // Başlığı ortalar
    );
  }

  // ── FORM KARTI ──────────────────────────────────────────────────────────
  Widget _buildFormCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fotoğraf seçici
          _buildAvatarPicker(colorScheme),
          const SizedBox(height: 28),

          // Profil Adı
          _buildLabel('Profil Adı', colorScheme),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _save(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Profil adı boş bırakılamaz.';
              }
              if (v.trim().length < 2) {
                return 'Profil adı en az 2 karakter olmalıdır.';
              }
              return null;
            },
            decoration: _inputDecoration(
              colorScheme: colorScheme,
              hintText: 'Örn: Saha Satış',
            ),
          ),
        ],
      ),
    );
  }

  // ── AVATAR PİCKER ───────────────────────────────────────────────────────
  Widget _buildAvatarPicker(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          // Avatar dairesi
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainer,
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildAvatarContent(colorScheme),
          ),
          // Düzenle butonu (sağ alt)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.edit_rounded,
                size: 16,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent(ColorScheme colorScheme) {
    if (_selectedImageFile != null) {
      return Image.file(_selectedImageFile!, fit: BoxFit.cover);
    }
    if (_existingAvatarUrl != null) {
      return Image.network(
        _existingAvatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderIcon(colorScheme),
      );
    }
    return _placeholderIcon(colorScheme);
  }

  Widget _placeholderIcon(ColorScheme colorScheme) {
    return Icon(
      Icons.add_a_photo_rounded,
      size: 36,
      color: colorScheme.outlineVariant,
    );
  }

  // ── LABEL ───────────────────────────────────────────────────────────────
  Widget _buildLabel(String text, ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
      ),
    );
  }

  // ── INPUT DECORATION ────────────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required ColorScheme colorScheme,
    required String hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: colorScheme.outline),
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: UnderlineInputBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    );
  }

  // ── KAYDET BUTONU ───────────────────────────────────────────────────────
  Widget _buildSaveButton(ColorScheme colorScheme) {
    return FilledButton.icon(
      onPressed: _isLoading ? null : _save,
      icon: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.save_rounded),
      label: Text(_isLoading ? 'Kaydediliyor...' : 'Kaydet'),
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── İPTAL BUTONU ────────────────────────────────────────────────────────
  Widget _buildCancelButton(ColorScheme colorScheme) {
    return OutlinedButton(
      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: const Text('İptal'),
    );
  }
}