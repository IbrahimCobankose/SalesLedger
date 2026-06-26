import 'package:sales_ledger/core/constants/app_limits.dart';

/// `products` tablosunun saf (Flutter/Supabase bağımsız) domain karşılığı.
/// Değişmezdir (immutable); güncelleme [copyWith] ile yapılır.
class Product {
  const Product({
    required this.id,
    required this.userId,
    required this.name,
    required this.salePrice,
    this.productionCost,
    this.length,
    this.width,
    this.height,
    this.weight,
    this.description,
    this.stockQuantity = 0,
    this.soldCount = 0,
    this.notes,
    this.photos = const [],
    this.category,
    this.tags = const [],
    this.isFavorite = false,
    this.profileId,
    this.profileName,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final double salePrice;
  final double? productionCost;
  final double? length;
  final double? width;
  final double? height;
  final double? weight;
  final String? description;
  final int stockQuantity;
  final int soldCount;
  final String? notes;
  final List<String> photos;
  final String? category;
  final List<String> tags;
  final bool isFavorite;

  /// Bu ürünün hangi profil üzerinden eklendiği. Gösterim için [profileName]
  /// listede `profiles(name)` gömülü kaynağından doldurulur.
  final String? profileId;
  final String? profileName;
  final DateTime createdAt;

  bool get isInStock => stockQuantity > 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= AppLimits.lowStockThreshold;

  /// (Satış Fiyatı - Maliyet) / Satış Fiyatı × 100 — gereksinim 4.2.3.
  /// Maliyet veya satış fiyatı tanımsızsa hesaplanamaz.
  double? get profitMarginPercent {
    if (productionCost == null || salePrice <= 0) return null;
    return (salePrice - productionCost!) / salePrice * 100;
  }

  Product copyWith({
    String? name,
    double? salePrice,
    double? productionCost,
    double? length,
    double? width,
    double? height,
    double? weight,
    String? description,
    int? stockQuantity,
    String? notes,
    List<String>? photos,
    String? category,
    List<String>? tags,
    bool? isFavorite,
    String? profileId,
    String? profileName,
  }) {
    return Product(
      id: id,
      userId: userId,
      name: name ?? this.name,
      salePrice: salePrice ?? this.salePrice,
      productionCost: productionCost ?? this.productionCost,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      description: description ?? this.description,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      soldCount: soldCount,
      notes: notes ?? this.notes,
      photos: photos ?? this.photos,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      profileId: profileId ?? this.profileId,
      profileName: profileName ?? this.profileName,
      createdAt: createdAt,
    );
  }
}
