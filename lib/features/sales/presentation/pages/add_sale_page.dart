import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_ledger/core/l10n/gen/app_localizations.dart';
import 'package:sales_ledger/core/l10n/l10n_extensions.dart';
import 'package:sales_ledger/core/utils/app_exception.dart';
import 'package:sales_ledger/core/widgets/custom_button.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/sales/domain/entities/cargo_status.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale_item_draft.dart';
import 'package:sales_ledger/features/sales/presentation/providers/sale_provider.dart';

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

const _months = [
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')} ${_months[date.month - 1]} ${date.year}';

/// satış_ekle.html taslağına karşılık gelen satış ekleme formu.
class AddSalePage extends ConsumerStatefulWidget {
  const AddSalePage({super.key});

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
          ),
        )
        .toList();

    final success = await ref.read(addSaleControllerProvider.notifier).addSale(
          customerName:
              _customerNameController.text.trim().isEmpty ? null : _customerNameController.text.trim(),
          saleDate: _saleDate,
          platform: _platformController.text.trim().isEmpty ? null : _platformController.text.trim(),
          items: drafts,
          status: _cargoStatus,
          trackingNumber:
              _trackingNumberController.text.trim().isEmpty ? null : _trackingNumberController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
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
      appBar: AppBar(title: Text(l10n.addSaleTitle), centerTitle: true),
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
                            DropdownMenuItem(
                              value: CargoStatus.packaging,
                              child: Text(l10n.addSaleStatusPreparing),
                            ),
                            DropdownMenuItem(
                              value: CargoStatus.shipped,
                              child: Text(l10n.addSaleStatusShipped),
                            ),
                            DropdownMenuItem(
                              value: CargoStatus.completed,
                              child: Text(l10n.addSaleStatusDelivered),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _cargoStatus = value);
                          },
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
              Expanded(
                child: TextFormField(
                  controller: item.nameController,
                  decoration: InputDecoration(
                    labelText: l10n.commonProduct,
                    hintText: l10n.addSaleProductHint,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? l10n.commonProductNameRequired : null,
                  onChanged: (_) => setState(() {}),
                ),
              ),
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
