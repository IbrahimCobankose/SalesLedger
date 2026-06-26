import 'package:sales_ledger/features/inventory/domain/entities/product.dart';

/// [Product] entity'sinin Supabase JSON (de)serileştirme katmanı.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.salePrice,
    super.productionCost,
    super.length,
    super.width,
    super.height,
    super.weight,
    super.description,
    super.stockQuantity,
    super.soldCount,
    super.notes,
    super.photos,
    super.category,
    super.tags,
    super.isFavorite,
    super.profileId,
    super.profileName,
    required super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Listede `profiles(name)` gömülü kaynağı, ürünün ait olduğu profil adını
    // ekstra sorgu yapmadan getirir.
    String? profileName;
    final profile = json['profiles'];
    if (profile is Map<String, dynamic>) {
      profileName = profile['name'] as String?;
    }
    return ProductModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      salePrice: (json['sale_price'] as num).toDouble(),
      productionCost: (json['production_cost'] as num?)?.toDouble(),
      length: (json['length'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      description: json['description'] as String?,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      soldCount: json['sold_count'] as int? ?? 0,
      notes: json['notes'] as String?,
      photos: (json['photos'] as List?)?.cast<String>() ?? const [],
      category: json['category'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      isFavorite: json['is_favorite'] as bool? ?? false,
      profileId: json['profile_id'] as String?,
      profileName: profileName,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      userId: product.userId,
      name: product.name,
      salePrice: product.salePrice,
      productionCost: product.productionCost,
      length: product.length,
      width: product.width,
      height: product.height,
      weight: product.weight,
      description: product.description,
      stockQuantity: product.stockQuantity,
      soldCount: product.soldCount,
      notes: product.notes,
      photos: product.photos,
      category: product.category,
      tags: product.tags,
      isFavorite: product.isFavorite,
      profileId: product.profileId,
      profileName: product.profileName,
      createdAt: product.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'sale_price': salePrice,
      'production_cost': productionCost,
      'length': length,
      'width': width,
      'height': height,
      'weight': weight,
      'description': description,
      'stock_quantity': stockQuantity,
      'notes': notes,
      'photos': photos,
      'category': category,
      'tags': tags,
    };
  }

  /// Eklerken `id`/`sold_count` Supabase tarafında üretilir; gönderilmez.
  /// `profile_id` yalnızca oluştururken yazılır (düzenlemede [toJson] içine
  /// konmaz ki mevcut profil bağı korunur).
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json['profile_id'] = profileId;
    return json;
  }
}
