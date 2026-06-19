import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/purchases/presentation/pages/add_purchase_page.dart';
import 'package:sales_ledger/features/purchases/presentation/pages/purchase_details_page.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _purchases = [];

  @override
  void initState() {
    super.initState();
    _fetchPurchases();
  }

  Future<void> _fetchPurchases() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      // Alışları ve içindeki ürünleri çekiyoruz
      final response = await _supabase
          .from('purchases')
          .select('*, purchase_items(quantity, name)')
          .eq('user_id', userId)
          .order('purchase_date', ascending: false);

      setState(() {
        _purchases = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Alımlar yüklenirken hata oluştu.',
          isError: true,
        );
      }
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Alımlar', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _purchases.isEmpty
              ? Center(
                  child: Text('Henüz bir alım kaydı bulunmuyor.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant)),
                )
              : RefreshIndicator(
                  onRefresh: _fetchPurchases,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _purchases.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildPurchaseCard(_purchases[index], colorScheme);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPurchasePage()),
          );
          if (result == true) _fetchPurchases();
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPurchaseCard(Map<String, dynamic> purchase, ColorScheme colorScheme) {
    final statusConfig = _getStatusConfig(purchase['status'] ?? 'completed', colorScheme);
    final purchaseDate = DateTime.parse(purchase['purchase_date']).toLocal();
    final dateStr = '${purchaseDate.day}/${purchaseDate.month}/${purchaseDate.year}';
    
    final totalAmount = purchase['total_amount'] ?? 0.0;
    
    // Tedarikçi adını description'dan çekiyoruz
    final description = purchase['description'] as String? ?? '';
    final supplierName = description.startsWith('Tedarikçi: ') 
        ? description.replaceFirst('Tedarikçi: ', '') 
        : 'Bilinmeyen Tedarikçi';

    final items = purchase['purchase_items'] as List<dynamic>? ?? [];
    final totalItems = items.fold<int>(0, (sum, item) => sum + (item['quantity'] as int? ?? 1));

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseDetailPage(purchase: purchase),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
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
                        supplierName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface, decoration: purchase['status'] == 'canceled' ? TextDecoration.lineThrough : null),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dateStr',
                        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusConfig['bgColor'],
                    borderRadius: BorderRadius.circular(6),
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('$totalItems Kalem Ürün', style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Toplam Tutar', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                    Text(
                      '₺${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: purchase['status'] == 'canceled' ? colorScheme.outline : colorScheme.primary
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}