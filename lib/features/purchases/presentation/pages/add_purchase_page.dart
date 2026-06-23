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
import 'package:sales_ledger/features/purchases/domain/entities/purchase_item_draft.dart';
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
        quantityController = TextEditingController(text: '1');

  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController quantityController;

  double get lineTotal {
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    return price * quantity;
  }

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
  }
}

/// alış_ekle.html taslağına karşılık gelen alış ekleme formu.
class AddPurchasePage extends ConsumerStatefulWidget {
  const AddPurchasePage({super.key});

  @override
  ConsumerState<AddPurchasePage> createState() => _AddPurchasePageState();
}

class _AddPurchasePageState extends ConsumerState<AddPurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final _supplierNameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  String _paymentType = _paymentTypes.first;
  final List<_ItemRow> _items = [_ItemRow()];
  final List<Uint8List> _photos = [];
  bool _isPickingPhotos = false;

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
    final remaining = AppLimits.maxProductPhotos - _photos.length;
    if (remaining <= 0) return;
    if (_isPickingPhotos) return;
    _isPickingPhotos = true;
    try {
      final picked = await ImagePicker().pickMultiImage(maxWidth: 1600, imageQuality: 85);
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
        CustomSnackbar.show(context, message: 'Fotoğraf seçilemedi. Lütfen tekrar deneyin.', isError: true);
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
          ),
        )
        .toList();

    final success = await ref.read(addPurchaseControllerProvider.notifier).addPurchase(
          supplierName:
              _supplierNameController.text.trim().isEmpty ? null : _supplierNameController.text.trim(),
          purchaseDate: _purchaseDate,
          items: drafts,
          paymentType: _paymentType,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: Text(l10n.addPurchaseTitle), centerTitle: true),
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
                      title: 'Fotoğraflar (opsiyonel)',
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
                            label: l10n.addPurchaseSubmit,
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
              Expanded(
                child: TextFormField(
                  controller: item.nameController,
                  decoration: InputDecoration(
                    labelText: l10n.commonProduct,
                    hintText: l10n.addPurchaseProductHint,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? l10n.commonProductNameRequired : null,
                  onChanged: (_) => setState(() {}),
                ),
              ),
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

  Widget _buildPhotoGrid(ColorScheme colorScheme) {
    return Wrap(
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
        if (_photos.length < AppLimits.maxProductPhotos)
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
