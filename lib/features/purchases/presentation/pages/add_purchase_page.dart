import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';

class AddPurchasePage extends StatefulWidget {
  const AddPurchasePage({super.key});

  @override
  State<AddPurchasePage> createState() => _AddPurchasePageState();
}

class _AddPurchasePageState extends State<AddPurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  
  final _supplierController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _paymentMethod = 'Nakit';
  
  List<Map<String, dynamic>> _selectedItems = [];
  bool _isLoading = false;

  final _tempItemNameController = TextEditingController();
  final _tempItemPriceController = TextEditingController();
  final _tempItemQuantityController = TextEditingController(text: '1');
  
  // Toplam Tutar Hesaplayıcı (Getter)
  double get _totalAmount {
    double total = 0;
    for (var item in _selectedItems) {
      total += (item['price'] as double) * (item['quantity'] as int);
    }
    return total;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addItemToPurchase() {
    if (_tempItemNameController.text.trim().isEmpty || _tempItemPriceController.text.isEmpty) return;
    
    setState(() {
      _selectedItems.add({
        'name': _tempItemNameController.text.trim(),
        'price': double.tryParse(_tempItemPriceController.text.replaceAll(',', '.')) ?? 0.0,
        'quantity': int.tryParse(_tempItemQuantityController.text) ?? 1,
        'product_id': null, // Opsiyonel: Eğer mevcut bir ürün seçilmişse doldurulur (stok takibi için)
      });
      
      _tempItemNameController.clear();
      _tempItemPriceController.clear();
      _tempItemQuantityController.text = '1';
    });
    Navigator.pop(context);
  }

  void _showAddItemBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Alıma Ürün Ekle', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _tempItemNameController,
                decoration: const InputDecoration(labelText: 'Ürün Adı', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tempItemPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Birim Alış Fiyatı (₺)', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _tempItemQuantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Adet', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _addItemToPurchase,
                  child: const Text('Ekle'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItems.isEmpty) {
      CustomSnackbar.show(context, message: 'Lütfen alıma en az bir ürün ekleyin.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // 1. Purchases tablosuna kayıt
      final purchaseData = {
        'user_id': userId,
        'purchase_date': _selectedDate.toIso8601String(),
        'description': 'Tedarikçi: ${_supplierController.text.trim()}',
        'notes': 'Ödeme Yöntemi: $_paymentMethod\n${_notesController.text.trim()}',
        'status': 'completed', // Varsayılan olarak tamamlandı atıyoruz
        'total_amount': _totalAmount,
      };

      final purchaseResponse = await _supabase.from('purchases').insert(purchaseData).select().single();
      final purchaseId = purchaseResponse['id'];

      // 2. Purchase_items tablosuna kayıt (Bu işlem DB'deki trigger'ı tetikleyip stokları güncelleyecektir)
      List<Map<String, dynamic>> itemsData = _selectedItems.map((item) => {
        'purchase_id': purchaseId,
        'product_id': item['product_id'],
        'name': item['name'],
        'custom_purchase_price': item['price'],
        'quantity': item['quantity'],
      }).toList();

      await _supabase.from('purchase_items').insert(itemsData);

      if (!mounted) return;
      CustomSnackbar.show(context, message: 'Alım işlemi başarıyla kaydedildi!', isError: false);
      Navigator.pop(context, true);

    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(context, message: 'Kayıt sırasında hata oluştu.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Alış Ekle', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tedarikçi Bilgileri
                    _buildSectionContainer(
                      title: 'Tedarikçi Bilgileri',
                      colorScheme: colorScheme,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _supplierController,
                            decoration: const InputDecoration(labelText: 'Tedarikçi Adı / Unvanı', filled: true),
                            validator: (v) => v == null || v.isEmpty ? 'Tedarikçi adı gereklidir' : null,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Alış Tarihi', filled: true),
                              child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Ürün Detayları
                    _buildSectionContainer(
                      title: 'Ürün Detayları',
                      colorScheme: colorScheme,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._selectedItems.asMap().entries.map((entry) {
                            int idx = entry.key;
                            var item = entry.value;
                            return Card(
                              elevation: 0,
                              color: colorScheme.surfaceContainerLow,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(item['name']),
                                subtitle: Text('${item['quantity']} Adet x ₺${item['price']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => setState(() => _selectedItems.removeAt(idx)),
                                ),
                              ),
                            );
                          }),
                          if (_selectedItems.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Toplam Tutar:', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16)),
                                  Text('₺${_totalAmount.toStringAsFixed(2)}', style: TextStyle(color: colorScheme.primary, fontSize: 20, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          OutlinedButton.icon(
                            onPressed: _showAddItemBottomSheet,
                            icon: const Icon(Icons.add),
                            label: const Text('Ürün Ekle'),
                            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Ödeme ve Notlar
                    _buildSectionContainer(
                      title: 'Ödeme ve Notlar',
                      colorScheme: colorScheme,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ödeme Yöntemi', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'Nakit', label: Text('Nakit'), icon: Icon(Icons.account_balance_wallet)),
                              ButtonSegment(value: 'Kredi Kartı', label: Text('Kart'), icon: Icon(Icons.credit_card)),
                              ButtonSegment(value: 'Havale', label: Text('Havale'), icon: Icon(Icons.account_balance)),
                            ],
                            selected: {_paymentMethod},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() => _paymentMethod = newSelection.first);
                            },
                            style: ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(labelText: 'Açıklama / Not (Opsiyonel)', filled: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Butonlar
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _savePurchase,
                        icon: const Icon(Icons.check),
                        label: const Text('Alışı Kaydet'),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionContainer({required String title, required ColorScheme colorScheme, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }
}