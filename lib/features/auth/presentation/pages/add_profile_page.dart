import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_ledger/core/constants/app_limits.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/core/widgets/custom_button.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/auth/presentation/providers/profile_provider.dart';

/// profil_ekle.html taslağına karşılık gelen profil oluşturma ekranı.
class AddProfilePage extends ConsumerStatefulWidget {
  const AddProfilePage({super.key});

  @override
  ConsumerState<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends ConsumerState<AddProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();

  Uint8List? _avatarBytes;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() => _avatarBytes = bytes);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(profilesProvider.notifier).addProfile(
            name: _nameController.text.trim(),
            role: _roleController.text.trim().isEmpty ? null : _roleController.text.trim(),
            avatarBytes: _avatarBytes,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: e is AppException ? e.message : context.l10n.addProfileSaveFailed,
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.addProfileTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickPhoto,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 48,
                                  backgroundColor: colorScheme.surfaceContainer,
                                  backgroundImage:
                                      _avatarBytes != null ? MemoryImage(_avatarBytes!) : null,
                                  child: _avatarBytes == null
                                      ? Icon(
                                          Icons.add_a_photo_outlined,
                                          color: colorScheme.outlineVariant,
                                          size: 32,
                                        )
                                      : null,
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
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nameController,
                            maxLength: AppLimits.maxProfileNameLength,
                            decoration: InputDecoration(
                              labelText: l10n.addProfileNameLabel,
                              hintText: l10n.addProfileNameHint,
                              counterText: '',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.addProfileNameRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _roleController,
                            maxLength: AppLimits.maxProfileRoleLength,
                            decoration: InputDecoration(
                              labelText: l10n.addProfileRoleLabel,
                              hintText: l10n.addProfileRoleHint,
                              counterText: '',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: l10n.commonSave,
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                    const SizedBox(height: 16),
                    SecondaryButton(
                      label: l10n.commonCancel,
                      onPressed: () => context.pop(),
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
