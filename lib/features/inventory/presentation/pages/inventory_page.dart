import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sales_ledger/core/widgets/custom_snackbar.dart';
import 'package:sales_ledger/features/inventory/presentation/pages/add_product_page.dart';
import 'package:sales_ledger/features/inventory/presentation/pages/product_details_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  // Filtreleme ve Arama State'leri
  String _searchQuery = '';
  String _selectedFilter = 'Tümü'; // Tümü, Stokta Var, Stokta Yok
  String _sortBy = 'Ad (A-Z)'; // Varsayılan sıralama

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('products')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _products = List<Map<String, dynamic>>.from(response);
        _applyFiltersAndSort();
      });
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Ürünler yüklenirken bir hata oluştu.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> result = List.from(_products);

    // 1. Arama
    if (_searchQuery.isNotEmpty) {
      result = result.where((p) {
        final name = (p['name'] as String).toLowerCase();
        final desc = (p['description'] as String?)?.toLowerCase() ?? '';
        final q = _searchQuery.toLowerCase();
        return name.contains(q) || desc.contains(q);
      }).toList();
    }

    // 2. Stok Durumu Filtresi
    if (_selectedFilter == 'Stokta Var') {
      result = result.where((p) => (p['stock_quantity'] as int) > 0).toList();
    } else if (_selectedFilter == 'Stokta Yok') {
      result = result.where((p) => (p['stock_quantity'] as int) <= 0).toList();
    }

    // 3. Sıralama
    switch (_sortBy) {
      case 'Fiyat (Artan)':
        result.sort((a, b) => (a['sale_price'] as num).compareTo(b['sale_price'] as num));
        break;
      case 'Fiyat (Azalan)':
        result.sort((a, b) => (b['sale_price'] as num).compareTo(a['sale_price'] as num));
        break;
      case 'En Çok Satanlar':
        result.sort((a, b) => (b['sold_count'] as int).compareTo(a['sold_count'] as int));
        break;
      case 'Ad (A-Z)':
      default:
        result.sort((a, b) => (a['name'] as String).toLowerCase().compareTo((b['name'] as String).toLowerCase()));
        break;
    }

    setState(() {
      _filteredProducts = result;
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Ad (A-Z)'),
                onTap: () {
                  setState(() => _sortBy = 'Ad (A-Z)');
                  _applyFiltersAndSort();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Fiyat (Artan)'),
                onTap: () {
                  setState(() => _sortBy = 'Fiyat (Artan)');
                  _applyFiltersAndSort();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Fiyat (Azalan)'),
                onTap: () {
                  setState(() => _sortBy = 'Fiyat (Azalan)');
                  _applyFiltersAndSort();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('En Çok Satanlar'),
                onTap: () {
                  setState(() => _sortBy = 'En Çok Satanlar');
                  _applyFiltersAndSort();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme),
      body: Column(
        children: [
          _buildFilterSection(colorScheme),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          'Ürün bulunamadı.',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchProducts,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, // Mobil için 1, tablet/web için MediaQuery ile artırılabilir
                            childAspectRatio: 3.5,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(
                                _filteredProducts[index], colorScheme);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
          // Ürün eklendikten sonra sayfaya dönülürse listeyi yenile
          if (result == true) {
            _fetchProducts();
          }
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      title: Text(
        'Satış Defteri',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Arama çubuğunu aktif et
          },
        ),
        IconButton(
          icon: const Icon(Icons.table_view),
          onPressed: () {
            // TODO: Excel Dışa Aktar
          },
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: colorScheme.surfaceContainerHighest,
          radius: 16,
          child: Icon(Icons.person, size: 20, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildFilterSection(ColorScheme colorScheme) {
    final filters = ['Tümü', 'Stokta Var', 'Stokta Yok'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.surfaceContainerHigh)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilter = filter);
                          _applyFiltersAndSort();
                        }
                      },
                      selectedColor: colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.sort, color: colorScheme.onSurfaceVariant),
            onPressed: _showSortOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, ColorScheme colorScheme) {
    final stock = product['stock_quantity'] as int;
    final price = product['sale_price'];
    final name = product['name'] as String;
    final category = product['category'] as String?;
    
    // Stok durumuna göre renk ayarlaması
    Color stockBgColor;
    Color stockTextColor;
    if (stock <= 0) {
      stockBgColor = colorScheme.errorContainer;
      stockTextColor = colorScheme.onErrorContainer;
    } else if (stock < 10) {
      stockBgColor = Colors.orange.shade100;
      stockTextColor = Colors.orange.shade900;
    } else {
      stockBgColor = Colors.green.shade100;
      stockTextColor = Colors.green.shade900;
    }

    final photos = product['photos'] as List<dynamic>?;
    final firstPhoto = (photos != null && photos.isNotEmpty) ? photos.first.toString() : null;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: stock <= 0 ? colorScheme.errorContainer : colorScheme.surfaceContainerHigh),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ürün Fotoğrafı
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.surfaceContainer),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: firstPhoto != null
                    ? Image.network(firstPhoto, fit: BoxFit.cover)
                    : Icon(Icons.inventory_2_outlined, color: colorScheme.outlineVariant, size: 32),
              ),
            ),
            const SizedBox(width: 16),
            // Ürün Detayları
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₺${price.toString()}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: stock <= 0 ? colorScheme.onSurfaceVariant : colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: stockBgColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stock <= 0 ? 'Tükendi' : '$stock Adet',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: stockTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (category != null)
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}