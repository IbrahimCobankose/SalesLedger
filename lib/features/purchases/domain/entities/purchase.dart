import 'package:sales_ledger/features/purchases/domain/entities/purchase_status.dart';

/// `purchases` tablosunun saf (Flutter/Supabase bağımsız) domain karşılığı.
/// Değişmezdir (immutable).
class Purchase {
  const Purchase({
    required this.id,
    required this.userId,
    this.supplierId,
    this.supplierName,
    required this.purchaseDate,
    this.description,
    this.notes,
    this.status = PurchaseStatus.completed,
    this.trackingNumber,
    this.paymentType,
    this.totalAmount = 0,
    this.itemCount = 0,
    this.photos = const [],
    this.profileId,
    this.profileName,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String? supplierId;
  final String? supplierName;
  final DateTime purchaseDate;
  final String? description;
  final String? notes;
  final PurchaseStatus status;
  final String? trackingNumber;
  final String? paymentType;
  final double totalAmount;
  final int itemCount;
  final List<String> photos;

  /// Alışın hangi profil üzerinden yapıldığı. [profileName] listede
  /// `profiles(name)` gömülü kaynağından doldurulur.
  final String? profileId;
  final String? profileName;
  final DateTime createdAt;

  String get displaySupplierName =>
      (supplierName != null && supplierName!.isNotEmpty) ? supplierName! : 'Tedarikçi belirtilmedi';
}
