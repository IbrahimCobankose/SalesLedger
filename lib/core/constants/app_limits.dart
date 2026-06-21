/// Uygulama genelinde kullanılan sayısal/metinsel sınırlar.
/// Magic number/string kullanımını önlemek için tüm limitler burada
/// toplanır (gereksinim 2.3.2, 3.4).
abstract class AppLimits {
  // ── Ürün (Envanter) ────────────────────────────────────────────────────
  static const maxProductNameLength = 200;
  static const maxProductDescriptionLength = 2000;
  static const maxProductPhotos = 10;

  // ── Profil ────────────────────────────────────────────────────────────
  static const maxProfileNameLength = 200;
  static const maxProfileRoleLength = 200;

  // ── Dosya Yükleme ─────────────────────────────────────────────────────
  static const maxPhotoSizeMb = 5;
  static const maxPhotoSizeBytes = maxPhotoSizeMb * 1024 * 1024;

  // ── Arama ─────────────────────────────────────────────────────────────
  static const searchDebounce = Duration(milliseconds: 300);

  // ── Sayfalama ─────────────────────────────────────────────────────────
  static const defaultPageSize = 20;

  // ── Stok Eşikleri ─────────────────────────────────────────────────────
  /// Bu adet ve altı "düşük stok" (turuncu rozet) olarak gösterilir.
  static const lowStockThreshold = 5;

  // ── İstatistik / Kasa ─────────────────────────────────────────────────
  static const topProductListLimit = 5;

  // ── Şifre ─────────────────────────────────────────────────────────────
  static const minPasswordLength = 6;
}
