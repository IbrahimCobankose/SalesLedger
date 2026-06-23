import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_ledger/core/constants/app_limits.dart';
import 'package:sales_ledger/core/l10n/gen/app_localizations.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/core/widgets/custom_button.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/inventory/presentation/providers/product_provider.dart';

const _categories = ['Elektronik', 'Giyim & Aksesuar', 'Kırtasiye', 'Diğer'];
const _maxPhotos = AppLimits.maxProductPhotos;

/// ürün_ekle.html taslağına karşılık gelen ürün ekleme formu.
class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _initialStockController = TextEditingController();
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();

  String? _category;
  final List<Uint8List> _photos = [];
  bool _isPickingPhotos = false;

  @override
  void dispose() {
    _nameController.dispose();
    _salePriceController.dispose();
    _costPriceController.dispose();
    _initialStockController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final remaining = _maxPhotos - _photos.length;
    if (remaining <= 0) return;

    // image_picker, önceki çağrı tamamlanmadan tekrar tetiklenirse
    // PlatformException(already_active) fırlatır; bu koruma art üst üste
    // dokunmalarda çökmeyi önler.
    if (_isPickingPhotos) return;
    _isPickingPhotos = true;
    try {
      final picked = await ImagePicker().pickMultiImage(maxWidth: 1600, imageQuality: 85);
      final selected = picked.take(remaining);
      var skippedForSize = false;

      for (final file in selected) {
        final bytes = await file.readAsBytes();
        if (bytes.length > AppLimits.maxPhotoSizeBytes) {
          skippedForSize = true;
          continue;
        }
        _photos.add(bytes);
      }

      if (skippedForSize && mounted) {
        CustomSnackbar.show(
          context,
          message: context.l10n.addProductPhotoSizeExceeded(AppLimits.maxPhotoSizeMb),
          isError: true,
        );
      }
      if (mounted) setState(() {});
    } on PlatformException {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Fotoğraf seçilemedi. Lütfen tekrar deneyin.',
          isError: true,
        );
      }
    } finally {
      _isPickingPhotos = false;
    }
  }

  double? _parseDouble(String text) => text.trim().isEmpty ? null : double.tryParse(text.trim());

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_photos.isEmpty) {
      CustomSnackbar.show(context, message: context.l10n.addProductPhotoRequired, isError: true);
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final success = await ref.read(addProductControllerProvider.notifier).addProduct(
          name: _nameController.text.trim(),
          salePrice: double.parse(_salePriceController.text.trim()),
          photos: _photos,
          productionCost: _parseDouble(_costPriceController.text),
          category: _category,
          initialStock: int.tryParse(_initialStockController.text.trim()) ?? 0,
          length: _parseDouble(_lengthController.text),
          width: _parseDouble(_widthController.text),
          height: _parseDouble(_heightController.text),
          weight: _parseDouble(_weightController.text),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          tags: tags,
        );

    if (!mounted) return;

    if (success) {
      context.pop();
    } else {
      final error = ref.read(addProductControllerProvider).error;
      CustomSnackbar.show(
        context,
        message: error is AppException ? error.message : context.l10n.addProductSaveFailed,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = ref.watch(addProductControllerProvider).isLoading;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: Text(l10n.addProductTitle), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPhotoSection(colorScheme, l10n),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: l10n.addProductBasicInfo,
                      icon: Icons.info_outline,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          maxLength: AppLimits.maxProductNameLength,
                          decoration: InputDecoration(
                            labelText: l10n.addProductNameLabel,
                            hintText: l10n.addProductNameHint,
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty) ? l10n.commonProductNameRequired : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _salePriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: l10n.addProductSalePrice,
                            prefixText: '₺ ',
                          ),
                          validator: (value) {
                            final parsed = double.tryParse((value ?? '').trim());
                            if (parsed == null || parsed <= 0) {
                              return l10n.commonValidPrice;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: l10n.addProductOptionalDetails,
                      icon: Icons.tune,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: InputDecoration(labelText: l10n.addProductCategory),
                          items: _categories
                              .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                              .toList(),
                          onChanged: (value) => setState(() => _category = value),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _costPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: l10n.addProductCostPrice,
                            prefixText: '₺ ',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _initialStockController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l10n.addProductInitialStock),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: l10n.addProductWeight),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.addProductDimensions, style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _lengthController,
                                textAlign: TextAlign.center,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(hintText: l10n.addProductDimensionLength),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _widthController,
                                textAlign: TextAlign.center,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(hintText: l10n.addProductDimensionWidth),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _heightController,
                                textAlign: TextAlign.center,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(hintText: l10n.addProductDimensionHeight),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLength: AppLimits.maxProductDescriptionLength,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: l10n.addProductDescription,
                            hintText: l10n.addProductDescriptionHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: l10n.addProductInternalNotes,
                            hintText: l10n.addProductInternalNotesHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _tagsController,
                          decoration: InputDecoration(
                            labelText: l10n.addProductTags,
                            hintText: l10n.addProductTagsHint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(label: l10n.commonCancel, onPressed: () => context.pop()),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PrimaryButton(
                            label: l10n.addProductSubmit,
                            icon: Icons.save_outlined,
                            isLoading: isLoading,
                            onPressed: _submit,
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
    );
  }

  Widget _buildPhotoSection(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _photos.length; i++)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(_photos[i], width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.removeAt(i)),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: colorScheme.error,
                          child: Icon(Icons.close, size: 14, color: colorScheme.onError),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_photos.length < _maxPhotos)
                GestureDetector(
                  onTap: _pickPhotos,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.primary, style: BorderStyle.solid, width: 2),
                    ),
                    child: Icon(Icons.add_a_photo_outlined, color: colorScheme.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addProductPhotoCounter(_photos.length, _maxPhotos),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
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
