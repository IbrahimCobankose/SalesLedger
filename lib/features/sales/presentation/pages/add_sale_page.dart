import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/gen/app_localizations.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/core/widgets/custom_button.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product.dart';
import 'package:sales_ledger/features/inventory/domain/entities/product_query.dart';
import 'package:sales_ledger/features/inventory/presentation/providers/product_provider.dart';
import 'package:sales_ledger/features/sales/domain/entities/cargo_status.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_item_draft.dart';
import 'package:sales_ledger/features/sales/presentation/providers/sale_provider.dart';

class _ItemRow {
  _ItemRow()
      : nameController = TextEditingController(),
        priceController = TextEditingController(),
        quantityController = TextEditingController(text: '1'),
        focusNode = FocusNode();

  _ItemRow.withValues({
    required String name,
    required double price,
    required int quantity,
    this.productId,
  })  : nameController = TextEditingController(text: name),
        priceController = TextEditingController(text: price.toStringAsFixed(2)),
        quantityController = TextEditingController(text: '$quantity'),
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

const _months = [
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')} ${_months[date.month - 1]} ${date.year}';

/// 5 kargo durumunun tamamı için etiket. Bilinen üçü yerelleştirilir;
/// "Geciken Kargo" ve "İptal Edildi" için [CargoStatus.label] kullanılır.
String _cargoStatusLabel(AppLocalizations l10n, CargoStatus status) {
  switch (status) {
    case CargoStatus.packaging:
      return l10n.addSaleStatusPreparing;
    case CargoStatus.shipped:
      return l10n.addSaleStatusShipped;
    case CargoStatus.completed:
      return l10n.addSaleStatusDelivered;
    case CargoStatus.delayed:
    case CargoStatus.canceled:
      return status.label;
  }
}

/// satış_ekle.html taslağına karşılık gelen satış ekleme/düzenleme formu.
/// [saleId] verilirse mevcut satış yüklenip düzenleme modunda açılır.
class AddSalePage extends ConsumerStatefulWidget {
  const AddSalePage({super.key, this.saleId});

  final String? saleId;

  bool get isEditing => saleId != null;

  @override
  ConsumerState<AddSalePage> createState() => _AddSalePageState();
}

class _AddSalePageState extends ConsumerState<AddSalePage> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _platformController = TextEditingController();
  final _trackingNumberController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _saleDate = DateTime.now();
  CargoStatus _cargoStatus = CargoStatus.packaging;
  final List<_ItemRow> _items = [_ItemRow()];
  bool _isLoadingExisting = false;

  @override
  void initState() {
    super.initState();
    if (widget.saleId != null) {
      _isLoadingExisting = true;
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    try {
      final sale = await ref.read(getSaleByIdUseCaseProvider)(widget.saleId!);
      final items = await ref.read(getSaleItemsUseCaseProvider)(widget.saleId!);
      if (!mounted) return;
      setState(() {
        _customerNameController.text = sale.customerName ?? '';
        _platformController.text = sale.platform ?? '';
        _trackingNumberController.text = sale.trackingNumber ?? '';
        _notesController.text = sale.notes ?? '';
        _saleDate = sale.saleDate;
        _cargoStatus = sale.status;
        for (final row in _items) {
          row.dispose();
        }
        _items
          ..clear()
          ..addAll(
            items.isEmpty
                ? [_ItemRow()]
                : items.map(
                    (it) => _ItemRow.withValues(
                      name: it.name,
                      price: it.customSalePrice,
                      quantity: it.quantity,
                      productId: it.productId,
                    ),
                  ),
          );
        _isLoadingExisting = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingExisting = false);
        CustomSnackbar.show(context, message: context.l10n.saleDetailsLoadFailed, isError: true);
      }
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _platformController.dispose();
    _trackingNumberController.dispose();
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
      initialDate: _saleDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _saleDate = picked);
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
          (item) => SaleItemDraft(
            name: item.nameController.text.trim(),
            unitPrice: double.parse(item.priceController.text.trim()),
            quantity: int.parse(item.quantityController.text.trim()),
            productId: item.productId,
          ),
        )
        .toList();

    final controller = ref.read(addSaleControllerProvider.notifier);
    final customerName =
        _customerNameController.text.trim().isEmpty ? null : _customerNameController.text.trim();
    final platform = _platformController.text.trim().isEmpty ? null : _platformController.text.trim();
    final trackingNumber =
        _trackingNumberController.text.trim().isEmpty ? null : _trackingNumberController.text.trim();
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    final success = widget.saleId == null
        ? await controller.addSale(
            customerName: customerName,
            saleDate: _saleDate,
            platform: platform,
            items: drafts,
            status: _cargoStatus,
            trackingNumber: trackingNumber,
            notes: notes,
          )
        : await controller.updateSale(
            saleId: widget.saleId!,
            customerName: customerName,
            saleDate: _saleDate,
            platform: platform,
            items: drafts,
            status: _cargoStatus,
            trackingNumber: trackingNumber,
            notes: notes,
          );

    if (!mounted) return;

    if (success) {
      context.pop();
    } else {
      final error = ref.read(addSaleControllerProvider).error;
      CustomSnackbar.show(
        context,
        message: error is AppException ? error.message : context.l10n.addSaleSaveFailed,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = ref.watch(addSaleControllerProvider).isLoading;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Satışı Düzenle' : l10n.addSaleTitle),
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
                    _buildSection(
                      title: l10n.addSaleCustomerInfo,
                      icon: Icons.person_outline,
                      children: [
                        TextFormField(
                          controller: _customerNameController,
                          decoration: InputDecoration(labelText: l10n.addSaleCustomerName),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: l10n.addSaleOrderDetails,
                      icon: Icons.receipt_long_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: InputDecoration(labelText: l10n.commonDate),
                                  child: Text(_formatDate(_saleDate)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _platformController,
                                decoration: InputDecoration(
                                  labelText: l10n.addSalePlatform,
                                  hintText: l10n.addSalePlatformHint,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.addSaleProducts, style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 8),
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
                      title: l10n.addSaleLogisticsAndFinance,
                      icon: Icons.local_shipping_outlined,
                      children: [
                        DropdownButtonFormField<CargoStatus>(
                          initialValue: _cargoStatus,
                          decoration: InputDecoration(labelText: l10n.addSaleCargoStatus),
                          items: [
                            for (final status in CargoStatus.values)
                              DropdownMenuItem(
                                value: status,
                                child: Text(_cargoStatusLabel(l10n, status)),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _cargoStatus = value);
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Yalnızca "Satış Tamamlandı" durumundaki satışlar kasaya gelir olarak işlenir.',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _trackingNumberController,
                          decoration: InputDecoration(labelText: l10n.addSaleTrackingNumber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: l10n.commonNotes,
                      icon: Icons.notes_outlined,
                      children: [
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(labelText: l10n.addSaleNotesHint),
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
                            label: l10n.addSaleSubmit,
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
                IconButton(icon: const Icon(Icons.close), onPressed: () => _removeItemRow(index)),
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
                  decoration: InputDecoration(labelText: l10n.addProductSalePrice, hintText: '0.00'),
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

  /// Envanterden ürün arayıp seçmeyi sağlayan alan. Seçilince ürün adı, satış
  /// fiyatı ve [_ItemRow.productId] otomatik dolar; elle yazılırsa serbest
  /// metin olarak (envanter bağlantısız) kabul edilir.
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
        item.priceController.text = product.salePrice.toStringAsFixed(2);
        setState(() {});
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: l10n.commonProduct,
            hintText: l10n.addSaleProductHint,
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

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
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
