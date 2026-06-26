import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_ledger/core/constants/app_limits.dart';
import 'package:sales_ledger/core/l10n/gen/app_localizations.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/storage/storage_buckets.dart';
import 'package:sales_ledger/core/storage/storage_image.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/core/widgets/custom_button.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product_query.dart';
import 'package:sales_ledger/features/inventory/presentation/providers/product_provider.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_item_draft.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_status.dart';
import 'package:sales_ledger/features/purchases/presentation/providers/purchase_provider.dart';

/// Ödeme tipi veritabanında her zaman Türkçe saklanır (kategori adları
/// gibi); ekranda gösterilen etiket [_paymentTypeLabel] ile yerelleştirilir.
const _paymentTypes = ['Nakit', 'Kredi Kartı', 'Havale/EFT'];

String _paymentTypeLabel(AppLocalizations l10n, String type) {
  switch (type) {
    case 'Nakit':
      return l10n.paymentCash;
    case 'Kredi Kartı':
      return l10n.paymentCard;
    default:
      return l10n.paymentTransfer;
  }
}

class _ItemRow {
  _ItemRow()
      : nameController = TextEditingController(),
        priceController = TextEditingController(),
        quantityController = TextEditingController(text: '1'),
        focusNode = FocusNode();

  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final FocusNode focusNode;

  /// Envanterden seçilen ürünün kimliği; elle yazılmışsa null.
  String? productId;

  double get lineTotal {
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    return price * quantity;
  }

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    focusNode.dispose();
  }
}

/// alış_ekle.html taslağına karşılık gelen alış ekleme/düzenleme formu.
/// [purchaseId] verilirse mevcut alış yüklenip düzenleme modunda açılır.
class AddPurchasePage extends ConsumerStatefulWidget {
  const AddPurchasePage({super.key, this.purchaseId});

  final String? purchaseId;

  @override
  ConsumerState<AddPurchasePage> createState() => _AddPurchasePageState();
}

class _AddPurchasePageState extends ConsumerState<AddPurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final _supplierNameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  String _paymentType = _paymentTypes.first;
  PurchaseStatus _status = PurchaseStatus.completed;
  final List<_ItemRow> _items = [_ItemRow()];
  final List<Uint8List> _photos = [];
  final List<String> _existingPhotoUrls = [];
  bool _isPickingPhotos = false;
  bool _loadingExisting = false;

  bool get _isEditing => widget.purchaseId != null;

  int get _totalPhotoCount => _existingPhotoUrls.length + _photos.length;

  /// Alımlarda yalnızca 3 durum anlamlı: Tamamlandı / Bekliyor / İptal.
  /// Ham bekleyen alt durumları (packaging/delayed/shipped) tek "Bekliyor"a indir.
  static PurchaseStatus _normalizeStatus(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.completed:
        return PurchaseStatus.completed;
      case PurchaseStatus.canceled:
        return PurchaseStatus.canceled;
      case PurchaseStatus.packaging:
      case PurchaseStatus.delayed:
      case PurchaseStatus.shipped:
        return PurchaseStatus.packaging;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.purchaseId != null) {
      _loadingExisting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  Future<void> _loadExisting() async {
    try {
      final purchase = await ref.read(getPurchaseByIdUseCaseProvider)(widget.purchaseId!);
      final items = await ref.read(getPurchaseItemsUseCaseProvider)(widget.purchaseId!);
      if (!mounted) return;
      setState(() {
        _supplierNameController.text = purchase.supplierName ?? '';
        _notesController.text = purchase.notes ?? '';
        _purchaseDate = purchase.purchaseDate;
        _paymentType =
            _paymentTypes.contains(purchase.paymentType) ? purchase.paymentType! : _paymentTypes.first;
        _status = _normalizeStatus(purchase.status);
        _existingPhotoUrls
          ..clear()
          ..addAll(purchase.photos);
        for (final item in _items) {
          item.dispose();
        }
        _items.clear();
        if (items.isEmpty) {
          _items.add(_ItemRow());
        } else {
          for (final it in items) {
            final row = _ItemRow();
            row.nameController.text = it.name;
            row.priceController.text = it.customPurchasePrice.toStringAsFixed(2);
            row.quantityController.text = it.quantity.toString();
            row.productId = it.productId;
            _items.add(row);
          }
        }
        _loadingExisting = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loadingExisting = false);
        CustomSnackbar.show(context, message: context.l10n.addPurchaseLoadFailed, isError: true);
      }
    }
  }

  @override
  void dispose() {
    _supplierNameController.dispose();
    _notesController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  double get _totalAmount => _items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _pickPhotos() async {
    final remaining = AppLimits.maxProductPhotos - _totalPhotoCount;
    if (remaining <= 0) return;
    if (_isPickingPhotos) return;
    _isPickingPhotos = true;
    try {
      final picked = await ImagePicker().pickMultiImage(
        maxWidth: AppLimits.photoMaxDimension,
        maxHeight: AppLimits.photoMaxDimension,
        imageQuality: AppLimits.photoQuality,
      );
      var skippedForSize = false;
      for (final file in picked.take(remaining)) {
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
        CustomSnackbar.show(context, message: context.l10n.commonPhotoPickFailed, isError: true);
      }
    } finally {
      _isPickingPhotos = false;
    }
  }

  void _addItemRow() => setState(() => _items.add(_ItemRow()));

  void _removeItemRow(int index) {
    if (_items.length <= 1) return;
    setState(() {
      _items.removeAt(index).dispose();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final drafts = _items
        .map(
          (item) => PurchaseItemDraft(
            name: item.nameController.text.trim(),
            unitPrice: double.parse(item.priceController.text.trim()),
            quantity: int.parse(item.quantityController.text.trim()),
            productId: item.productId,
          ),
        )
        .toList();

    final supplierName =
        _supplierNameController.text.trim().isEmpty ? null : _supplierNameController.text.trim();
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
    final controller = ref.read(addPurchaseControllerProvider.notifier);

    final success = _isEditing
        ? await controller.updatePurchase(
            purchaseId: widget.purchaseId!,
            supplierName: supplierName,
            purchaseDate: _purchaseDate,
            items: drafts,
            paymentType: _paymentType,
            notes: notes,
            status: _status,
            keptPhotos: _existingPhotoUrls,
            newPhotos: _photos,
          )
        : await controller.addPurchase(
            supplierName: supplierName,
            purchaseDate: _purchaseDate,
            items: drafts,
            paymentType: _paymentType,
            notes: notes,
            status: _status,
            photos: _photos,
          );

    if (!mounted) return;

    if (success) {
      context.pop();
    } else {
      final error = ref.read(addPurchaseControllerProvider).error;
      CustomSnackbar.show(
        context,
        message: error is AppException ? error.message : context.l10n.addPurchaseSaveFailed,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = ref.watch(addPurchaseControllerProvider).isLoading;
    final l10n = context.l10n;

    if (_loadingExisting) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(title: Text(l10n.addPurchaseEditTitle), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(_isEditing ? l10n.addPurchaseEditTitle : l10n.addPurchaseTitle),
        centerTitle: true,
      ),
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
                    _buildSection(
                      title: l10n.addPurchaseSupplierInfo,
                      children: [
                        TextFormField(
                          controller: _supplierNameController,
                          decoration: InputDecoration(
                            labelText: l10n.addPurchaseSupplierName,
                            hintText: l10n.addPurchaseSupplierHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: InputDecoration(labelText: l10n.addPurchaseDate),
                            child: Text(formatTurkishDateLong(_purchaseDate)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: l10n.addPurchaseStatusLabel,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(l10n.purchaseStatusCompleted),
                              selected: _status == PurchaseStatus.completed,
                              onSelected: (_) =>
                                  setState(() => _status = PurchaseStatus.completed),
                            ),
                            ChoiceChip(
                              label: Text(l10n.purchaseStatusPending),
                              selected: _status == PurchaseStatus.packaging,
                              onSelected: (_) =>
                                  setState(() => _status = PurchaseStatus.packaging),
                            ),
                            ChoiceChip(
                              label: Text(l10n.purchaseStatusCanceled),
                              selected: _status == PurchaseStatus.canceled,
                              onSelected: (_) =>
                                  setState(() => _status = PurchaseStatus.canceled),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: l10n.addPurchaseProductDetails,
                      children: [
                        for (var i = 0; i < _items.length; i++) _buildItemRow(i, l10n),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colorScheme.outlineVariant),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.commonTotalAmountColon, style: Theme.of(context).textTheme.bodyMedium),
                              Text(
                                '₺${_totalAmount.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _addItemRow,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.commonAddAnotherProduct),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: l10n.addPurchasePhotosOptional,
                      children: [_buildPhotoGrid(colorScheme)],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: l10n.addPurchasePaymentAndNotes,
                      children: [
                        Text(l10n.addPurchasePaymentMethod, style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _paymentTypes
                              .map(
                                (type) => ChoiceChip(
                                  label: Text(_paymentTypeLabel(l10n, type)),
                                  selected: _paymentType == type,
                                  onSelected: (_) => setState(() => _paymentType = type),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: l10n.addPurchaseNotesLabel,
                            hintText: l10n.addPurchaseNotesHint,
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
                            label: _isEditing ? l10n.addPurchaseUpdate : l10n.addPurchaseSubmit,
                            icon: Icons.check,
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

  Widget _buildItemRow(int index, AppLocalizations l10n) {
    final item = _items[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildProductPicker(item, l10n)),
              if (_items.length > 1)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _removeItemRow(index),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: item.priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(labelText: l10n.commonUnitPrice, hintText: '0.00'),
                  validator: (value) {
                    final parsed = double.tryParse((value ?? '').trim());
                    return (parsed == null || parsed <= 0) ? l10n.commonValidPrice : null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: item.quantityController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(labelText: l10n.commonQuantity, hintText: '1'),
                  validator: (value) {
                    final parsed = int.tryParse((value ?? '').trim());
                    return (parsed == null || parsed <= 0) ? l10n.commonValidQuantity : null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Envanterden ürün arayıp seçmeyi sağlayan alan (satış formundaki ile
  /// aynı davranış). Seçilince ürün adı ve [_ItemRow.productId] otomatik
  /// dolar; varsa üretim maliyeti alış fiyatına ön-doldurulur. Elle
  /// yazılırsa serbest metin (envanter bağlantısız) kabul edilir.
  Widget _buildProductPicker(_ItemRow item, AppLocalizations l10n) {
    return RawAutocomplete<Product>(
      textEditingController: item.nameController,
      focusNode: item.focusNode,
      optionsBuilder: (TextEditingValue value) async {
        final query = value.text.trim();
        if (query.isEmpty) return const Iterable<Product>.empty();
        try {
          return await ref.read(productRepositoryProvider).getProducts(
                ProductQuery(search: query, pageSize: 8),
              );
        } catch (_) {
          return const Iterable<Product>.empty();
        }
      },
      displayStringForOption: (product) => product.name,
      onSelected: (product) {
        item.productId = product.id;
        if (item.priceController.text.trim().isEmpty && product.productionCost != null) {
          item.priceController.text = product.productionCost!.toStringAsFixed(2);
        }
        setState(() {});
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: l10n.commonProduct,
            hintText: l10n.addPurchaseProductHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: item.productId != null
                ? Icon(Icons.link, size: 18, color: Theme.of(context).colorScheme.primary)
                : null,
          ),
          validator: (value) =>
              (value == null || value.trim().isEmpty) ? l10n.commonProductNameRequired : null,
          onChanged: (_) {
            // Kullanıcı adı elle değiştirdiyse envanter bağlantısını kaldır.
            if (item.productId != null) item.productId = null;
            setState(() {});
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final colorScheme = Theme.of(context).colorScheme;
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 400),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, i) {
                  final product = options.elementAt(i);
                  return ListTile(
                    leading: Icon(Icons.inventory_2_outlined, color: colorScheme.primary),
                    title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '₺${product.salePrice.toStringAsFixed(2)} · ${l10n.commonUnitsCount(product.stockQuantity)}',
                    ),
                    onTap: () => onSelected(product),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _removableThumb(ColorScheme colorScheme, Widget image, VoidCallback onRemove) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: image),
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

  Widget _buildPhotoGrid(ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < _existingPhotoUrls.length; i++)
          _removableThumb(
            colorScheme,
            StorageImage(
              bucket: StorageBuckets.purchasePhotos,
              path: _existingPhotoUrls[i],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            () => setState(() => _existingPhotoUrls.removeAt(i)),
          ),
        for (var i = 0; i < _photos.length; i++)
          _removableThumb(
            colorScheme,
            Image.memory(_photos[i], width: 80, height: 80, fit: BoxFit.cover),
            () => setState(() => _photos.removeAt(i)),
          ),
        if (_totalPhotoCount < AppLimits.maxProductPhotos)
          GestureDetector(
            onTap: _pickPhotos,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.primary, width: 2),
              ),
              child: Icon(Icons.add_a_photo_outlined, color: colorScheme.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
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
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }
}

const _months = [
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

String formatTurkishDateLong(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} ${_months[date.month - 1]} ${date.year}';
}
