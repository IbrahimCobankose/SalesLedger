import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/sales/presentation/pages/sale_details_page.dart';
// import 'package:sales_ledger/features/sales/presentation/pages/add_sale_page.dart'; // Yönlendirme için eklenecek

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _sales = [];

  @override
  void initState() {
    super.initState();
    _fetchSales();
  }

  Future<void> _fetchSales() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      // Satışları ve her satışa ait ürünlerin miktarını çekiyoruz
      final response = await _supabase
          .from('sales')
          .select('*, sale_items(quantity, name)')
          .eq('user_id', userId)
          .order('sale_date', ascending: false);

      setState(() {
        _sales = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Satışlar yüklenirken hata oluştu.',
          isError: true,
        );
      }
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
          'color': const Color(0xFF93000A), // Koyu Kırmızı/Turuncu
          'bgColor': const Color(0xFFFFDAD6),
          'icon': Icons.local_shipping,
        };
      case 'completed':
        return {
          'label': 'Teslim Edildi',
          'color': const Color(0xFF137333), // Yeşil
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Satışlar', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.table_view), onPressed: () {}),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sales.isEmpty
              ? Center(
                  child: Text('Henüz bir satış kaydı bulunmuyor.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant)),
                )
              : RefreshIndicator(
                  onRefresh: _fetchSales,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sales.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildSaleCard(_sales[index], colorScheme);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // TODO: Satış Ekle sayfasına yönlendirme aktif edilecek
          // final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSalePage()));
          // if (result == true) _fetchSales();
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSaleCard(Map<String, dynamic> sale, ColorScheme colorScheme) {
    final statusConfig = _getStatusConfig(sale['status'], colorScheme);
    final saleDate = DateTime.parse(sale['sale_date']).toLocal();
    final dateStr = '${saleDate.day}/${saleDate.month}/${saleDate.year}';
    final platform = sale['platform'] ?? 'Bilinmiyor';
    final totalAmount = sale['total_amount'] ?? 0.0;
    
    // Satışın içindeki ürünlerin toplam adedini bulma
    final items = sale['sale_items'] as List<dynamic>? ?? [];
    final totalItems = items.fold<int>(0, (sum, item) => sum + (item['quantity'] as int? ?? 1));
    
    // İlk ürünün adını temsil olarak gösterme
    final firstItemName = items.isNotEmpty ? items.first['name'] : 'İsimsiz Ürün';
    final title = items.length > 1 ? '$firstItemName +${items.length - 1} Ürün' : firstItemName;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SaleDetailPage(sale: sale),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.surfaceContainerHigh),
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
                      Text(
                        title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface, decoration: sale['status'] == 'canceled' ? TextDecoration.lineThrough : null),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dateStr • $platform',
                        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₺${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: sale['status'] == 'canceled' ? colorScheme.outline : colorScheme.primary
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, size: 18, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('$totalItems Adet', style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusConfig['bgColor'],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(statusConfig['icon'], size: 14, color: statusConfig['color']),
                      const SizedBox(width: 4),
                      Text(
                        statusConfig['label'],
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusConfig['color']),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}