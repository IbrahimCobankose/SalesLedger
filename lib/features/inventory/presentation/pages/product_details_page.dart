import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final name = product['name'] ?? 'İsimsiz Ürün';
    final salePrice = product['sale_price'] ?? 0.0;
    final costPrice = product['production_cost'];
    final stock = product['stock_quantity'] ?? 0;
    final sold = product['sold_count'] ?? 0;
    final photos = List<String>.from(product['photos'] ?? []);
    final desc = product['description'];
    final notes = product['notes'];

    // Kar marjı hesaplama: ((Satış - Maliyet) / Satış) * 100
    String marginStr = '-';
    if (costPrice != null && salePrice > 0) {
      double margin = ((salePrice - costPrice) / salePrice) * 100;
      marginStr = '%${margin.toStringAsFixed(1)}';
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Ürün Detayı', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {
            // TODO: Ürün düzenleme sayfasına yönlendir
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fotoğraf Alanı
            if (photos.isNotEmpty)
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(photos.first),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.inventory_2, size: 64, color: Colors.grey),
              ),
            const SizedBox(height: 24),
            
            // Başlık ve Fiyat
            Text(name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('₺${salePrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 28, color: colorScheme.primary, fontWeight: FontWeight.bold)),
            
            const SizedBox(height: 24),

            // İstatistik Kartları
            Row(
              children: [
                Expanded(child: _buildStatCard('Stok Durumu', '$stock Adet', Icons.inventory_2, colorScheme)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Toplam Satış', '$sold Adet', Icons.trending_up, colorScheme)),
              ],
            ),
            
            const SizedBox(height: 24),

            // Detaylar Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildInfoTile('Maliyet', costPrice != null ? '₺$costPrice' : '-', colorScheme),
                _buildInfoTile('Kar Marjı', marginStr, colorScheme, isHighlight: true),
                _buildInfoTile('Uzunluk', product['length'] != null ? '${product['length']} cm' : '-', colorScheme),
                _buildInfoTile('Ağırlık', product['weight'] != null ? '${product['weight']} kg' : '-', colorScheme),
              ],
            ),

            const SizedBox(height: 24),

            // Açıklama ve Notlar
            if (desc != null && desc.toString().isNotEmpty) ...[
              Text('Açıklama', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: colorScheme.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), border: Border.all(color: colorScheme.surfaceContainerHigh)),
                child: Text(desc, style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ),
              const SizedBox(height: 16),
            ],

            if (notes != null && notes.toString().isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.note, color: colorScheme.tertiary),
                  const SizedBox(width: 8),
                  Text('Dahili Notlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
                child: Text(notes, style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, ColorScheme colorScheme, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isHighlight ? colorScheme.primary : colorScheme.onSurface)),
        ],
      ),
    );
  }
}