import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';

class AddSalePage extends StatefulWidget {
  const AddSalePage({super.key});

  @override
  State<AddSalePage> createState() => _AddSalePageState();
}

class _AddSalePageState extends State<AddSalePage> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  
  final _customerController = TextEditingController();
  final _platformController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String? _cargoStatus;
  
  // Eklenen ürünlerin listesi
  List<Map<String, dynamic>> _selectedItems = [];
  bool _isLoading = false;

  // Yeni ürün eklemek için geçici controller
  final _tempItemNameController = TextEditingController();
  final _tempItemPriceController = TextEditingController();
  final _tempItemQuantityController = TextEditingController(text: '1');

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

  void _addItemToSale() {
    if (_tempItemNameController.text.trim().isEmpty || _tempItemPriceController.text.isEmpty) return;
    
    setState(() {
      _selectedItems.add({
        'name': _tempItemNameController.text.trim(),
        'price': double.tryParse(_tempItemPriceController.text.replaceAll(',', '.')) ?? 0.0,
        'quantity': int.tryParse(_tempItemQuantityController.text) ?? 1,
        'product_id': null, // Eğer envanterden seçilseydi ID dolu olacaktı
      });
      
      _recalculateTotal();
      _tempItemNameController.clear();
      _tempItemPriceController.clear();
      _tempItemQuantityController.text = '1';
    });
    Navigator.pop(context); // BottomSheet'i kapat
  }

  void _recalculateTotal() {
    double total = 0;
    for (var item in _selectedItems) {
      total += (item['price'] as double) * (item['quantity'] as int);
    }
    _totalPriceController.text = total.toStringAsFixed(2);
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
              Text('Satışa Ürün Ekle', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _tempItemNameController,
                decoration: const InputDecoration(labelText: 'Ürün Adı (Serbest Metin)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tempItemPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Birim Fiyat (₺)', border: OutlineInputBorder()),
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
                  onPressed: _addItemToSale,
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

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItems.isEmpty) {
      CustomSnackbar.show(context, message: 'Lütfen satışa en az bir ürün ekleyin.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _supabase.auth.currentUser!.id;
      
      // 1. Sale tablosuna kayıt
      final saleData = {
        'user_id': userId,
        'sale_date': _selectedDate.toIso8601String(),
        'platform': _platformController.text.trim(),
        'description': 'Müşteri: ${_customerController.text.trim()}', // Şimdilik description içinde tutuluyor
        'notes': _notesController.text.trim(),
        'status': _cargoStatus ?? 'packaging',
        'total_amount': double.tryParse(_totalPriceController.text.replaceAll(',', '.')) ?? 0.0,
      };

      final saleResponse = await _supabase.from('sales').insert(saleData).select().single();
      final saleId = saleResponse['id'];

      // 2. Sale_items tablosuna kayıt
      List<Map<String, dynamic>> itemsData = _selectedItems.map((item) => {
        'sale_id': saleId,
        'product_id': item['product_id'],
        'name': item['name'],
        'custom_sale_price': item['price'],
        'quantity': item['quantity'],
      }).toList();

      await _supabase.from('sale_items').insert(itemsData);

      if (!mounted) return;
      CustomSnackbar.show(context, message: 'Satış başarıyla kaydedildi!', isError: false);
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
        title: Text('Yeni Satış Ekle', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
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
                    _buildSectionContainer(
                      title: 'Müşteri Bilgileri',
                      icon: Icons.person,
                      colorScheme: colorScheme,
                      child: TextFormField(
                        controller: _customerController,
                        decoration: const InputDecoration(labelText: 'Müşteri Adı / Unvanı', filled: true),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionContainer(
                      title: 'Sipariş Detayları',
                      icon: Icons.receipt_long,
                      colorScheme: colorScheme,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectDate(context),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(labelText: 'Tarih', filled: true),
                                    child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _platformController,
                                  decoration: const InputDecoration(labelText: 'Platform (Örn: Trendyol)', filled: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text('Ürünler', style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          
                          // Eklenen Ürünler Listesi
                          ..._selectedItems.asMap().entries.map((entry) {
                            int idx = entry.key;
                            var item = entry.value;
                            return Card(
                              elevation: 0,
                              color: colorScheme.surfaceContainerLow,
                              child: ListTile(
                                title: Text(item['name']),
                                subtitle: Text('${item['quantity']} Adet x ₺${item['price']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _selectedItems.removeAt(idx);
                                      _recalculateTotal();
                                    });
                                  },
                                ),
                              ),
                            );
                          }),
                          
                          const SizedBox(height: 8),
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
                    _buildSectionContainer(
                      title: 'Lojistik ve Finans',
                      icon: Icons.local_shipping,
                      colorScheme: colorScheme,
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Kargo Durumu', filled: true),
                              value: _cargoStatus,
                              items: const [
                                DropdownMenuItem(value: 'packaging', child: Text('Hazırlanıyor')),
                                DropdownMenuItem(value: 'shipped', child: Text('Kargoya Verildi')),
                                DropdownMenuItem(value: 'delayed', child: Text('Geciken Kargo')),
                                DropdownMenuItem(value: 'completed', child: Text('Teslim Edildi')),
                                DropdownMenuItem(value: 'canceled', child: Text('İptal Edildi')),
                              ],
                              onChanged: (v) => setState(() => _cargoStatus = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _totalPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Toplam Tutar (₺)', filled: true),
                              validator: (v) => v == null || v.isEmpty ? 'Gerekli' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionContainer(
                      title: 'Notlar',
                      icon: Icons.note,
                      colorScheme: colorScheme,
                      child: TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Notlar (Opsiyonel)', filled: true),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saveSale,
                        icon: const Icon(Icons.save),
                        label: const Text('Satışı Kaydet'),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionContainer({required String title, required IconData icon, required ColorScheme colorScheme, required Widget child}) {
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
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}