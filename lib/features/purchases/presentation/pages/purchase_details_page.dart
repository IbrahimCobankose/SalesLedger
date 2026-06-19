import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchaseDetailPage extends StatefulWidget {
  final Map<String, dynamic> purchase;

  const PurchaseDetailPage({super.key, required this.purchase});

  @override
  State<PurchaseDetailPage> createState() => _PurchaseDetailPageState();
}

class _PurchaseDetailPageState extends State<PurchaseDetailPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _purchaseItems = [];

  @override
  void initState() {
    super.initState();
    _fetchPurchaseDetails();
  }

  Future<void> _fetchPurchaseDetails() async {
    setState(() => _isLoading = true);
    try {
      // Alıma ait ürün detaylarını çekiyoruz (purchase_items tablosundan)
      final response = await _supabase
          .from('purchase_items')
          .select()
          .eq('purchase_id', widget.purchase['id']);

      setState(() {
        _purchaseItems = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Detaylar yüklenirken hata: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Durumlara göre renk ve ikon eşleştirmesi
  Map<String, dynamic> _getStatusConfig(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'completed':
        return {
          'label': 'Tamamlandı',
          'color': const Color(0xFF137333),
          'bgColor': const Color(0xFFE6F4EA),
          'icon': Icons.check_circle,
        };
      case 'canceled':
        return {
          'label': 'İptal Edildi',
          'color': colorScheme.onErrorContainer,
          'bgColor': colorScheme.errorContainer,
          'icon': Icons.cancel,
        };
      case 'packaging':
      case 'delayed':
      case 'shipped':
      default:
        return {
          'label': 'Bekliyor',
          'color': const Color(0xFFE65100),
          'bgColor': const Color(0xFFFFF3E0),
          'icon': Icons.pending,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final purchase = widget.purchase;
    
    final statusConfig = _getStatusConfig(purchase['status'] ?? 'completed', colorScheme);
    final purchaseDate = DateTime.parse(purchase['purchase_date']).toLocal();
    final dateStr = '${purchaseDate.day} ${_getMonthName(purchaseDate.month)} ${purchaseDate.year}';
    
    final totalAmount = purchase['total_amount'] ?? 0.0;
    
    // Açıklamadan tedarikçi adını ayıklama
    final description = purchase['description'] as String? ?? '';
    final supplierName = description.startsWith('Tedarikçi: ') 
        ? description.replaceFirst('Tedarikçi: ', '') 
        : 'Bilinmeyen Tedarikçi';

    // Notlar alanından ödeme yöntemini ve asıl notu ayıklama
    final rawNotes = purchase['notes'] as String? ?? '';
    String paymentMethod = '-';
    String actualNotes = rawNotes;
    
    if (rawNotes.startsWith('Ödeme Yöntemi: ')) {
      final parts = rawNotes.split('\n');
      paymentMethod = parts[0].replaceAll('Ödeme Yöntemi: ', '');
      actualNotes = parts.skip(1).join('\n').trim();
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Alım Detayı', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Üst Bilgi Kartları (Tedarikçi ve Tutar)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tedarikçi Bilgileri Kartı
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.surfaceContainerHighest),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('TEDARİKÇİ BİLGİLERİ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, letterSpacing: 1)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: statusConfig['bgColor'],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      statusConfig['label'], 
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusConfig['color'])
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(supplierName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                              const SizedBox(height: 16),
                              // İsteğe bağlı ekstra müşteri detayı eklenebilir
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Toplam Tutar Kartı
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.surfaceContainerHighest),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOPLAM TUTAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, letterSpacing: 1)),
                              const SizedBox(height: 8),
                              Text('₺${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Tarih:', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                                  Text(dateStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Ödeme:', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                                  Text(paymentMethod, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 2. Alınan Ürünler Listesi
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.surfaceContainerHighest),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Alınan Ürünler', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.onSurface)),
                        ),
                        const Divider(height: 1),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _purchaseItems.length,
                          separatorBuilder: (context, index) => Divider(height: 1, color: colorScheme.surfaceContainerHighest),
                          itemBuilder: (context, index) {
                            final item = _purchaseItems[index];
                            final itemName = item['name'] ?? 'Bilinmeyen Ürün';
                            final quantity = item['quantity'] ?? 1;
                            final price = item['custom_purchase_price'] ?? 0.0;
                            final total = quantity * price;

                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(itemName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
                                        const SizedBox(height: 4),
                                        Text('$quantity Adet x ₺${price.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                  Text('₺${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Notlar Alanı
                  if (actualNotes.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.surfaceContainerHighest),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AÇIKLAMA / NOTLAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, letterSpacing: 1)),
                          const SizedBox(height: 8),
                          Text(actualNotes, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // 4. Aksiyon Butonları
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: İndir PDF
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('İndir (PDF)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: colorScheme.primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            // TODO: Alım düzenleme sayfasına yönlendir
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Düzenle'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return months[month - 1];
  }
}