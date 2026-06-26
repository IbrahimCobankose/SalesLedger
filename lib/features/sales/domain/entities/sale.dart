import 'package:sales_ledger/features/sales/domain/entities/cargo_status.dart';

/// `sales` tablosunun saf (Flutter/Supabase bağımsız) domain karşılığı.
/// Değişmezdir (immutable).
class Sale {
  const Sale({
    required this.id,
    required this.userId,
    this.customerId,
    this.customerName,
    required this.saleDate,
    this.platform,
    this.description,
    this.notes,
    this.status = CargoStatus.packaging,
    this.trackingNumber,
    this.totalAmount = 0,
    this.itemCount = 0,
    this.firstItemName,
    this.profileId,
    this.profileName,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String? customerId;
  final String? customerName;
  final DateTime saleDate;
  final String? platform;
  final String? description;
  final String? notes;
  final CargoStatus status;
  final String? trackingNumber;
  final double totalAmount;
  final int itemCount;
  final String? firstItemName;

  /// Satışın hangi profil üzerinden yapıldığı. [profileName] listede
  /// `profiles(name)` gömülü kaynağından doldurulur.
  final String? profileId;
  final String? profileName;
  final DateTime createdAt;

  bool get isCanceled => status == CargoStatus.canceled;

  String get displayCustomerName =>
      (customerName != null && customerName!.isNotEmpty) ? customerName! : 'Müşteri belirtilmedi';

  /// Kart başlığı: ilk ürün adı, yoksa müşteri adı (gereksinim 4.3.1).
  String get displayTitle =>
      (firstItemName != null && firstItemName!.isNotEmpty) ? firstItemName! : displayCustomerName;
}
