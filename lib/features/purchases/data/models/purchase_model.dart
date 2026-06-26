import 'package:sales_ledger/features/purchases/domain/entities/purchase.dart';
import 'package:sales_ledger/features/purchases/domain/entities/purchase_status.dart';

/// [Purchase] entity'sinin Supabase JSON (de)serileştirme katmanı.
class PurchaseModel extends Purchase {
  const PurchaseModel({
    required super.id,
    required super.userId,
    super.supplierId,
    super.supplierName,
    required super.purchaseDate,
    super.description,
    super.notes,
    super.status,
    super.trackingNumber,
    super.paymentType,
    super.totalAmount,
    super.itemCount,
    super.photos,
    super.profileId,
    super.profileName,
    required super.createdAt,
  });

  /// `purchase_items(count)` gömülü kaynağı, listede kalem sayısını
  /// ekstra bir sorgu yapmadan göstermek için kullanılır.
  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    var itemCount = 0;
    final embeddedItems = json['purchase_items'];
    if (embeddedItems is List && embeddedItems.isNotEmpty) {
      itemCount = (embeddedItems.first['count'] as num?)?.toInt() ?? 0;
    }

    String? profileName;
    final profile = json['profiles'];
    if (profile is Map<String, dynamic>) {
      profileName = profile['name'] as String?;
    }

    return PurchaseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      supplierId: json['supplier_id'] as String?,
      supplierName: json['supplier_name'] as String?,
      purchaseDate: DateTime.parse(json['purchase_date'] as String),
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      status: PurchaseStatus.fromDbValue(json['status'] as String? ?? 'completed'),
      trackingNumber: json['tracking_number'] as String?,
      paymentType: json['payment_type'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      itemCount: itemCount,
      photos: (json['photos'] as List?)?.cast<String>() ?? const [],
      profileId: json['profile_id'] as String?,
      profileName: profileName,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> _baseJson() {
    return {
      'user_id': userId,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'purchase_date': purchaseDate.toIso8601String(),
      'description': description,
      'notes': notes,
      'status': status.dbValue,
      'payment_type': paymentType,
      'total_amount': totalAmount,
      'photos': photos,
    };
  }

  /// Oluştururken `profile_id` de yazılır.
  Map<String, dynamic> toInsertJson() => {..._baseJson(), 'profile_id': profileId};

  /// Güncellerken `profile_id` yazılmaz; mevcut profil bağı korunur.
  Map<String, dynamic> toUpdateJson() => _baseJson();
}
