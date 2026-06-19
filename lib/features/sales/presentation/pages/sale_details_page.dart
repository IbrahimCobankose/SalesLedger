import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaleDetailPage extends StatefulWidget {
  final Map<String, dynamic> sale;

  const SaleDetailPage({super.key, required this.sale});

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _saleItems = [];

  @override
  void initState() {
    super.initState();
    _fetchSaleDetails();
  }

  Future<void> _fetchSaleDetails() async {
    setState(() => _isLoading = true);
    try {
      // Satışa ait ürün detaylarını çekiyoruz. 
      // Varsa bağlı olduğu ürünün fotoğrafını da alıyoruz.
      final response = await _supabase
          .from('sale_items')
          .select('*, products(photos)')
          .eq('sale_id', widget.sale['id']);

      setState(() {
        _saleItems = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Detaylar yüklenirken hata: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Kargo durumlarına göre renk ve ikon eşleştirmesi
  Map<String, dynamic> _getStatusConfig(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'delayed':
        return {
          'label': 'Geciken Kargo',
          'color': const Color(0xFF5E4200), // on-warning-container
          'bgColor': const Color(0xFFFFEFD6), // warning-container
          'icon': Icons.schedule,
        };
      case 'completed':
        return {
          'label': 'Teslim Edildi',
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
      case 'shipped':
        return {
          'label': 'Kargoda',
          'color': colorScheme.onPrimaryContainer,
          'bgColor': colorScheme.primaryContainer.withOpacity(0.2),
          'icon': Icons.local_shipping,
        };
      case 'packaging':
      default:
        return {
          'label': 'Hazırlanıyor',
          'color': colorScheme.onSurfaceVariant,
          'bgColor': colorScheme.surfaceContainerHigh,
          'icon': Icons.inventory_2,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sale = widget.sale;
    
    final statusConfig = _getStatusConfig(sale['status'], colorScheme);
    final saleDate = DateTime.parse(sale['sale_date']).toLocal();
    final dateStr = '${saleDate.day} ${_getMonthName(saleDate.month)} ${saleDate.year}, ${saleDate.hour.toString().padLeft(2, '0')}:${saleDate.minute.toString().padLeft(2, '0')}';
    
    final platform = sale['platform'] ?? 'Belirtilmedi';
    final totalAmount = sale['total_amount'] ?? 0.0;
    final trackingNumber = sale['tracking_number'] ?? '-';
    
    // AddSale sayfasında müşteri adını description alanına 'Müşteri: İsim' formatında kaydetmiştik.
    final description = sale['description'] as String? ?? '';
    final customerName = description.startsWith('Müşteri: ') 
        ? description.replaceFirst('Müşteri: ', '') 
        : 'Bilinmeyen Müşteri';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Satış Detayı', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
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
                  // 1. Ana Bilgi Kartı
                  Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('MÜŞTERİ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  Text(customerName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.storefront, size: 16, color: colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(platform, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('TUTAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text('₺${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                                const SizedBox(height: 8),
                                Text(dateStr, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Durum', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusConfig['bgColor'],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusConfig['icon'], size: 14, color: statusConfig['color']),
                                        const SizedBox(width: 4),
                                        Text(statusConfig['label'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusConfig['color'])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Takip No', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                                  const SizedBox(height: 4),
                                  Text(trackingNumber, style: TextStyle(fontSize: 14, fontFamily: 'monospace', color: colorScheme.onSurface)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 2. Ürünler Listesi
                  Text('Ürünler', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.surfaceContainerHighest),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _saleItems.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: colorScheme.surfaceContainerHighest),
                      itemBuilder: (context, index) {
                        final item = _saleItems[index];
                        final itemName = item['name'] ?? 'Bilinmeyen Ürün';
                        final quantity = item['quantity'] ?? 1;
                        final price = item['custom_sale_price'] ?? 0.0;
                        
                        // Ürünün fotoğrafını bulmaya çalışıyoruz
                        String? photoUrl = item['photo_url'];
                        if (photoUrl == null && item['products'] != null && item['products']['photos'] != null) {
                          final photos = List.from(item['products']['photos']);
                          if (photos.isNotEmpty) photoUrl = photos.first.toString();
                        }

                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: photoUrl != null 
                                      ? Image.network(photoUrl, fit: BoxFit.cover)
                                      : Icon(Icons.inventory_2_outlined, color: colorScheme.outlineVariant),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(itemName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Adet: $quantity', style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                                        Text('₺${price.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Aksiyon Butonları
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Fatura PDF indirme işlemi
                          },
                          icon: const Icon(Icons.receipt_long),
                          label: const Text('Fatura İndir'),
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
                            // TODO: Satış düzenleme sayfasına yönlendir
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