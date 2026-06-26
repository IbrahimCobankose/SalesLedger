import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_ledger/core/constants/app_limits.dart';
import 'package:sales_ledger/core/storage/storage_buckets.dart';
import 'package:sales_ledger/core/storage/storage_image.dart';
import 'package:sales_ledger/core/l10n/gen/app_localizations.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/core/widgets/custom_button.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product.dart';
import 'package:sales_ledger/features/inventory/presentation/providers/product_provider.dart';

const _categories = ['Elektronik', 'Giyim & Aksesuar', 'Kırtasiye', 'Diğer'];
const _maxPhotos = AppLimits.maxProductPhotos;

/// ürün_ekle.html taslağına karşılık gelen ürün ekleme/düzenleme formu.
/// [productId] verilirse mevcut ürün yüklenip düzenleme modunda açılır
/// (gereksinim 4.2.3).
class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key, this.productId});

  final String? productId;

  bool get isEditing => productId != null;

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

  /// Düzenleme modunda korunan mevcut fotoğrafların URL'leri.
  final List<String> _existingPhotoUrls = [];
  Product? _original;
  bool _isLoadingExisting = false;
  bool _isPickingPhotos = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _isLoadingExisting = true;
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    try {
      final product = await ref.read(getProductByIdUseCaseProvider)(widget.productId!);
      if (!mounted) return;
      setState(() {
        _original = product;
        _nameController.text = product.name;
        _salePriceController.text = _numText(product.salePrice);
        if (product.productionCost != null) {
          _costPriceController.text = _numText(product.productionCost!);
        }
        _initialStockController.text = product.stockQuantity.toString();
        if (product.weight != null) _weightController.text = _numText(product.weight!);
        if (product.length != null) _lengthController.text = _numText(product.length!);
        if (product.width != null) _widthController.text = _numText(product.width!);
        if (product.height != null) _heightController.text = _numText(product.height!);
        _descriptionController.text = product.description ?? '';
        _notesController.text = product.notes ?? '';
        _tagsController.text = product.tags.join(', ');
        _category = _categories.contains(product.category) ? product.category : null;
        _existingPhotoUrls
          ..clear()
          ..addAll(product.photos);
        _isLoadingExisting = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingExisting = false);
        CustomSnackbar.show(context, message: context.l10n.productDetailsLoadFailed, isError: true);
      }
    }
  }

  /// Gereksiz ondalık sıfırları gizler: 12.0 → "12", 12.5 → "12.5".
  static String _numText(num value) {
    final text = value.toString();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  int get _totalPhotoCount => _existingPhotoUrls.length + _photos.length;

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
    final remaining = _maxPhotos - _totalPhotoCount;
    if (remaining <= 0) return;

    // image_picker, önceki çağrı tamamlanmadan tekrar tetiklenirse
    // PlatformException(already_active) fırlatır; bu koruma art üst üste
    // dokunmalarda çökmeyi önler.
    if (_isPickingPhotos) return;
    _isPickingPhotos = true;
    try {
      final picked = await ImagePicker().pickMultiImage(
        maxWidth: AppLimits.photoMaxDimension,
        maxHeight: AppLimits.photoMaxDimension,
        imageQuality: AppLimits.photoQuality,
      );
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
          message: context.l10n.commonPhotoPickFailed,
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

    if (_totalPhotoCount == 0) {
      CustomSnackbar.show(context, message: context.l10n.addProductPhotoRequired, isError: true);
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final description =
        _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
    final controller = ref.read(addProductControllerProvider.notifier);

    final success = widget.productId == null
        ? await controller.addProduct(
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
            description: description,
            notes: notes,
            tags: tags,
          )
        : await controller.updateProduct(
            original: _original!,
            name: _nameController.text.trim(),
            salePrice: double.parse(_salePriceController.text.trim()),
            keptPhotoUrls: _existingPhotoUrls,
            newPhotos: _photos,
            productionCost: _parseDouble(_costPriceController.text),
            category: _category,
            stockQuantity: int.tryParse(_initialStockController.text.trim()),
            length: _parseDouble(_lengthController.text),
            width: _parseDouble(_widthController.text),
            height: _parseDouble(_heightController.text),
            weight: _parseDouble(_weightController.text),
            description: description,
            notes: notes,
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
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Ürünü Düzenle' : l10n.addProductTitle),
        centerTitle: true,
      ),
      body: _isLoadingExisting
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                          decoration: InputDecoration(
                            labelText:
                                widget.isEditing ? 'Stok Adedi' : l10n.addProductInitialStock,
                          ),
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
                            label: widget.isEditing
                                ? 'Değişiklikleri Kaydet'
                                : l10n.addProductSubmit,
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
              for (var i = 0; i < _existingPhotoUrls.length; i++)
                _PhotoThumb(
                  colorScheme: colorScheme,
                  onRemove: () => setState(() => _existingPhotoUrls.removeAt(i)),
                  child: StorageImage(
                    bucket: StorageBuckets.productPhotos,
                    path: _existingPhotoUrls[i],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              for (var i = 0; i < _photos.length; i++)
                _PhotoThumb(
                  colorScheme: colorScheme,
                  onRemove: () => setState(() => _photos.removeAt(i)),
                  child: Image.memory(_photos[i], width: 80, height: 80, fit: BoxFit.cover),
                ),
              if (_totalPhotoCount < _maxPhotos)
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
            l10n.addProductPhotoCounter(_totalPhotoCount, _maxPhotos),
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

/// 80x80 fotoğraf küçük resmi; sağ üstte silme düğmesi içerir.
class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({
    required this.child,
    required this.onRemove,
    required this.colorScheme,
  });

  final Widget child;
  final VoidCallback onRemove;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: colorScheme.error,
              child: Icon(Icons.close, size: 14, color: colorScheme.onError),
            ),
          ),
        ),
      ],
    );
  }
}
