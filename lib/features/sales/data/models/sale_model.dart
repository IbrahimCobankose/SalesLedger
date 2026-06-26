import 'package:sales_ledger/features/sales/domain/entities/cargo_status.dart';
import 'package:sales_ledger/features/sales/domain/entities/sale.dart';

/// [Sale] entity'sinin Supabase JSON (de)serileştirme katmanı.
class SaleModel extends Sale {
  const SaleModel({
    required super.id,
    required super.userId,
    super.customerId,
    super.customerName,
    required super.saleDate,
    super.platform,
    super.description,
    super.notes,
    super.status,
    super.trackingNumber,
    super.totalAmount,
    super.itemCount,
    super.firstItemName,
    super.profileId,
    super.profileName,
    required super.createdAt,
  });

  /// `customers(name)` ve `sale_items(count)`/`sale_items(name)` gömülü
  /// kaynakları, listede ekstra sorgu yapmadan müşteri/ürün adını ve
  /// kalem sayısını göstermek için kullanılır.
  factory SaleModel.fromJson(Map<String, dynamic> json) {
    String? customerName;
    final customer = json['customers'];
    if (customer is Map<String, dynamic>) {
      customerName = customer['name'] as String?;
    }

    var itemCount = 0;
    String? firstItemName;
    final embeddedItems = json['sale_items'];
    if (embeddedItems is List && embeddedItems.isNotEmpty) {
      itemCount = embeddedItems.length;
      firstItemName = embeddedItems.first['name'] as String?;
    }

    String? profileName;
    final profile = json['profiles'];
    if (profile is Map<String, dynamic>) {
      profileName = profile['name'] as String?;
    }

    return SaleModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      customerId: json['customer_id'] as String?,
      customerName: customerName,
      saleDate: DateTime.parse(json['sale_date'] as String),
      platform: json['platform'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      status: CargoStatus.fromDbValue(json['status'] as String? ?? 'packaging'),
      trackingNumber: json['tracking_number'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      itemCount: itemCount,
      firstItemName: firstItemName,
      profileId: json['profile_id'] as String?,
      profileName: profileName,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> _baseJson() {
    return {
      'user_id': userId,
      'customer_id': customerId,
      'sale_date': saleDate.toIso8601String(),
      'platform': platform,
      'description': description,
      'notes': notes,
      'status': status.dbValue,
      'tracking_number': trackingNumber,
      'total_amount': totalAmount,
    };
  }

  /// Oluştururken `profile_id` de yazılır.
  Map<String, dynamic> toInsertJson() => {..._baseJson(), 'profile_id': profileId};

  /// Güncellerken `profile_id` yazılmaz; mevcut profil bağı korunur.
  Map<String, dynamic> toUpdateJson() => _baseJson();
}
