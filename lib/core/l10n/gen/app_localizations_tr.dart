// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Satış Defteri';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonDismiss => 'Vazgeç';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonAll => 'Tümü';

  @override
  String get commonAllProfiles => 'Tüm Profiller';

  @override
  String get commonProfile => 'Profil';

  @override
  String commonProfileLine(Object name) {
    return 'Profil: $name';
  }

  @override
  String get commonRetry => 'Tekrar dene';

  @override
  String get commonExportExcel => 'Excel Dışa Aktar';

  @override
  String get commonExportFailed => 'Dışa aktarma başarısız oldu.';

  @override
  String commonUnitsCount(Object count) {
    return '$count Adet';
  }

  @override
  String get commonNotes => 'Notlar';

  @override
  String get commonDate => 'Tarih';

  @override
  String get commonProductNameRequired => 'Ürün adı gerekli.';

  @override
  String get commonValidPrice => 'Geçerli bir fiyat girin.';

  @override
  String get commonValidQuantity => 'Geçerli bir miktar girin.';

  @override
  String get commonProduct => 'Ürün';

  @override
  String get commonQuantity => 'Miktar';

  @override
  String get commonUnitPrice => 'Birim Fiyat';

  @override
  String get commonTotal => 'Toplam';

  @override
  String get commonTotalAmount => 'Toplam Tutar';

  @override
  String get commonTotalAmountColon => 'Toplam Tutar:';

  @override
  String get commonAddAnotherProduct => 'Başka Ürün Ekle';

  @override
  String get navInventory => 'Envanter';

  @override
  String get navSales => 'Satışlar';

  @override
  String get navPurchases => 'Alımlar';

  @override
  String get navFinance => 'Finans';

  @override
  String get navProfile => 'Profilim';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get navReports => 'Raporlar';

  @override
  String get navLogout => 'Çıkış Yap';

  @override
  String get sessionExpiredMessage =>
      'Güvenlik nedeniyle oturumunuz zaman aşımına uğradı. Lütfen tekrar giriş yapın.';

  @override
  String get loginWelcome => 'Hesabınıza giriş yapın ve yönetime başlayın.';

  @override
  String get loginEmailLabel => 'E-posta Adresi';

  @override
  String get loginEmailHint => 'ornek@sirket.com';

  @override
  String get loginPasswordLabel => 'Şifre';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginForgotPassword => 'Şifremi Unuttum';

  @override
  String get loginSubmit => 'Giriş Yap';

  @override
  String get loginNoAccount => 'Hesabınız yok mu? ';

  @override
  String get loginCreateAccount => 'Hesap Oluştur';

  @override
  String get loginEmailRequired => 'E-posta adresi gerekli.';

  @override
  String get loginEmailInvalid => 'Geçerli bir e-posta adresi girin.';

  @override
  String get loginPasswordRequired => 'Şifre gerekli.';

  @override
  String get loginFailed => 'Giriş yapılamadı.';

  @override
  String get registerTitle => 'Hesap Oluştur';

  @override
  String get registerWelcome =>
      'Satış Defteri\'ne hoş geldiniz. Lütfen bilgilerinizi girin.';

  @override
  String get registerCompanyName => 'Şirket Adı';

  @override
  String get registerCompanyNameHint => 'Örn: Yılmaz Ticaret';

  @override
  String get registerEmail => 'E-posta';

  @override
  String get registerPassword => 'Şifre';

  @override
  String get registerSubmit => 'Kayıt Ol';

  @override
  String get registerHaveAccount => 'Zaten bir hesabınız var mı? ';

  @override
  String get registerLogin => 'Giriş Yap';

  @override
  String get registerCompanyNameRequired => 'Şirket adı gerekli.';

  @override
  String get registerPasswordTooShort => 'Şifre en az 6 karakter olmalı.';

  @override
  String get registerFailed => 'Hesap oluşturulamadı.';

  @override
  String get profileSelectionTitle => 'Profil Seçiniz';

  @override
  String get profileSelectionSubtitle =>
      'Satış Defteri\'ne giriş yapmak için kullanmak istediğiniz profili seçin.';

  @override
  String get profileSelectionLoadFailed => 'Profiller yüklenemedi.';

  @override
  String get profileSelectionAddNew => 'Yeni Profil Ekle';

  @override
  String get profileSelectionAddNewSubtitle => 'Farklı bir hesapla giriş yapın';

  @override
  String get addProfileTitle => 'Profil Ekle';

  @override
  String get addProfileNameLabel => 'Profil Adı';

  @override
  String get addProfileNameHint => 'Örn: Saha Satış';

  @override
  String get addProfileRoleLabel => 'Rol / Unvan';

  @override
  String get addProfileRoleHint => 'Örn: Bölge Yöneticisi';

  @override
  String get addProfileNameRequired => 'Profil adı gerekli.';

  @override
  String get addProfileSaveFailed => 'Profil kaydedilemedi.';

  @override
  String get inventoryLoadFailed => 'Ürünler yüklenemedi.';

  @override
  String get inventoryNoExportData => 'Dışa aktarılacak ürün yok.';

  @override
  String inventoryExportSuccess(Object path) {
    return 'Envanter dışa aktarıldı: $path';
  }

  @override
  String get inventorySearchHint => 'Ürün adı veya açıklamada ara...';

  @override
  String get inventoryEmpty => 'Henüz ürün eklenmemiş.';

  @override
  String get inventoryAddNew => 'Yeni Ürün Ekle';

  @override
  String get inventoryFilterInStock => 'Stokta Var';

  @override
  String get inventoryFilterOutOfStock => 'Stokta Yok';

  @override
  String get inventoryFilterFavorites => 'Favoriler';

  @override
  String get inventoryFavoriteFailed => 'Favori durumu güncellenemedi.';

  @override
  String get inventorySort => 'Sırala';

  @override
  String get inventorySortAlphabetical => 'Alfabetik';

  @override
  String get inventorySortPriceDesc => 'Fiyat (Azalan)';

  @override
  String get inventorySortPriceAsc => 'Fiyat (Artan)';

  @override
  String get inventorySortBestSelling => 'En Çok Satan';

  @override
  String get inventoryOutOfStockBadge => 'Tükendi';

  @override
  String get addProductTitle => 'Ürün Ekle';

  @override
  String get addProductBasicInfo => 'Temel Bilgiler *';

  @override
  String get addProductNameLabel => 'Ürün Adı';

  @override
  String get addProductNameHint => 'Örn: Premium Deri Cüzdan';

  @override
  String get addProductSalePrice => 'Satış Fiyatı (₺)';

  @override
  String get addProductOptionalDetails => 'Detaylar (İsteğe Bağlı)';

  @override
  String get addProductCategory => 'Kategori';

  @override
  String get addProductCostPrice => 'Maliyet Fiyatı (₺)';

  @override
  String get addProductInitialStock => 'Başlangıç Stok Adedi';

  @override
  String get addProductWeight => 'Ağırlık (kg)';

  @override
  String get addProductDimensions => 'Boyutlar (U x G x Y cm)';

  @override
  String get addProductDimensionLength => 'U';

  @override
  String get addProductDimensionWidth => 'G';

  @override
  String get addProductDimensionHeight => 'Y';

  @override
  String get addProductDescription => 'Ürün Açıklaması';

  @override
  String get addProductDescriptionHint => 'Müşteriler için ürün detayları...';

  @override
  String get addProductInternalNotes => 'Dahili Notlar';

  @override
  String get addProductInternalNotesHint =>
      'Sadece sizin görebileceğiniz notlar...';

  @override
  String get addProductTags => 'Etiketler';

  @override
  String get addProductTagsHint => 'Virgülle ayırın: deri, hediyelik';

  @override
  String get addProductSubmit => 'Ürünü Kaydet';

  @override
  String get addProductPhotoRequired => 'En az 1 fotoğraf eklemelisiniz.';

  @override
  String get addProductSaveFailed => 'Ürün kaydedilemedi.';

  @override
  String addProductPhotoCounter(Object current, Object max) {
    return '$current/$max fotoğraf (en az 1 zorunlu)';
  }

  @override
  String addProductPhotoSizeExceeded(Object maxMb) {
    return 'Bazı fotoğraflar $maxMb MB sınırını aştığı için eklenmedi.';
  }

  @override
  String get productDetailsTitle => 'Ürün Detayı';

  @override
  String get productDetailsLoadFailed => 'Ürün yüklenemedi.';

  @override
  String get productDetailsDeleteTitle => 'Ürünü Sil';

  @override
  String get productDetailsDeleteMessage =>
      'Bu ürünü silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get productDetailsDeleteFailed => 'Ürün silinemedi.';

  @override
  String get productDetailsStockStatus => 'Stok Durumu';

  @override
  String get productDetailsTotalSales => 'Toplam Satış';

  @override
  String get productDetailsCost => 'Maliyet';

  @override
  String get productDetailsMargin => 'Kâr Marjı';

  @override
  String get productDetailsDimensions => 'Boyutlar (U x G x Y)';

  @override
  String get productDetailsWeight => 'Ağırlık';

  @override
  String get productDetailsDescription => 'Açıklama';

  @override
  String get productDetailsInternalNotes => 'Dahili Notlar';

  @override
  String get productDetailsRecentSales => 'Geçmiş Satışlar';

  @override
  String get productDetailsSalesHistoryFailed => 'Satış geçmişi yüklenemedi.';

  @override
  String get productDetailsNoSalesHistory =>
      'Bu ürüne ait satış kaydı bulunamadı.';

  @override
  String productDetailsSaleHistoryLine(Object date, Object count) {
    return '$date • $count Adet';
  }

  @override
  String get purchasesLoadFailed => 'Alışlar yüklenemedi.';

  @override
  String get purchasesNoExportData => 'Dışa aktarılacak alış yok.';

  @override
  String purchasesExportSuccess(Object path) {
    return 'Alışlar dışa aktarıldı: $path';
  }

  @override
  String get purchasesSearchHint => 'Tedarikçi veya açıklamada ara...';

  @override
  String get purchasesFilterCompleted => 'Tamamlananlar';

  @override
  String get purchasesFilterPending => 'Bekleyenler';

  @override
  String get purchasesFilterCanceled => 'İptal Edilenler';

  @override
  String get purchasesEmpty => 'Henüz alış kaydı eklenmemiş.';

  @override
  String get purchasesAddNew => 'Yeni Alım Ekle';

  @override
  String purchaseCardItemCount(Object count) {
    return '$count Kalem Ürün';
  }

  @override
  String get addPurchaseTitle => 'Alış Ekle';

  @override
  String get addPurchaseSupplierInfo => 'Tedarikçi Bilgileri';

  @override
  String get addPurchaseSupplierName => 'Tedarikçi Adı / Unvanı';

  @override
  String get addPurchaseSupplierHint => 'Tedarikçi Seçin veya Yazın';

  @override
  String get addPurchaseDate => 'Alış Tarihi';

  @override
  String get addPurchaseProductDetails => 'Ürün Detayları';

  @override
  String get addPurchasePaymentAndNotes => 'Ödeme ve Notlar';

  @override
  String get addPurchasePaymentMethod => 'Ödeme Yöntemi';

  @override
  String get addPurchaseNotesLabel => 'Açıklama / Not (Opsiyonel)';

  @override
  String get addPurchaseNotesHint => 'Alış ile ilgili notlar...';

  @override
  String get addPurchaseSubmit => 'Alışı Kaydet';

  @override
  String get addPurchaseProductHint => 'Ürün Ara veya Yeni Ürün Adı Girin';

  @override
  String get addPurchaseSaveFailed => 'Alış kaydedilemedi.';

  @override
  String get paymentCash => 'Nakit';

  @override
  String get paymentCard => 'Kredi Kartı';

  @override
  String get paymentTransfer => 'Havale/EFT';

  @override
  String get purchaseDetailsTitle => 'Alım Detayı';

  @override
  String get purchaseDetailsLoadFailed => 'Alış yüklenemedi.';

  @override
  String get purchaseDetailsDeleteTitle => 'Alışı Sil';

  @override
  String get purchaseDetailsDeleteMessage =>
      'Bu alış kaydını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get purchaseDetailsDeleteFailed => 'Alış silinemedi.';

  @override
  String get purchaseDetailsSupplierInfo => 'TEDARİKÇİ BİLGİLERİ';

  @override
  String get purchaseDetailsTotalAmount => 'TOPLAM TUTAR';

  @override
  String get purchaseDetailsPaymentType => 'Ödeme Tipi';

  @override
  String get purchaseDetailsItemsTitle => 'Alınan Ürünler';

  @override
  String get purchaseDetailsItemsFailed => 'Ürün kalemleri yüklenemedi.';

  @override
  String get purchaseDetailsNotes => 'AÇIKLAMA / NOTLAR';

  @override
  String get purchaseDetailsNoItems => 'Bu alışa ürün eklenmemiş.';

  @override
  String get purchaseDetailsColumnProductName => 'Ürün Kodu/Adı';

  @override
  String get purchaseDetailsColumnUnitPrice => 'Birim Fiyat';

  @override
  String get purchaseDetailsColumnTotal => 'Toplam';

  @override
  String get salesTitle => 'Satışlar';

  @override
  String get salesLoadFailed => 'Satışlar yüklenemedi.';

  @override
  String get salesNoExportData => 'Dışa aktarılacak satış yok.';

  @override
  String salesExportSuccess(Object path) {
    return 'Satışlar dışa aktarıldı: $path';
  }

  @override
  String get salesSearchHint => 'Platform veya açıklamada ara...';

  @override
  String get salesSortNewestFirst => 'Yeniden Eskiye';

  @override
  String get salesSortOldestFirst => 'Eskiden Yeniye';

  @override
  String get salesEmpty => 'Henüz satış kaydı eklenmemiş.';

  @override
  String get salesAddNew => 'Yeni Satış Ekle';

  @override
  String saleCardItemCount(Object count) {
    return '$count Adet';
  }

  @override
  String get addSaleTitle => 'Satış Ekle';

  @override
  String get addSaleCustomerInfo => 'Müşteri Bilgileri';

  @override
  String get addSaleCustomerName => 'Müşteri Adı / Unvanı';

  @override
  String get addSaleOrderDetails => 'Sipariş Detayları';

  @override
  String get addSalePlatform => 'Platform';

  @override
  String get addSalePlatformHint => 'Trendyol, Hepsiburada...';

  @override
  String get addSaleProducts => 'Ürünler';

  @override
  String get addSaleLogisticsAndFinance => 'Lojistik ve Finans';

  @override
  String get addSaleCargoStatus => 'Kargo Durumu';

  @override
  String get addSaleStatusPreparing => 'Hazırlanıyor';

  @override
  String get addSaleStatusShipped => 'Kargoya Verildi';

  @override
  String get addSaleStatusDelivered => 'Teslim Edildi';

  @override
  String get addSaleTrackingNumber => 'Kargo Takip No (Opsiyonel)';

  @override
  String get addSaleNotesHint => 'Notlar (Opsiyonel)';

  @override
  String get addSaleSubmit => 'Satışı Kaydet';

  @override
  String get addSaleProductHint => 'Envanterden ürün ara veya yeni gir';

  @override
  String get addSaleSaveFailed => 'Satış kaydedilemedi.';

  @override
  String get saleDetailsTitle => 'Satış Detayı';

  @override
  String get saleDetailsLoadFailed => 'Satış yüklenemedi.';

  @override
  String get saleDetailsDeleteTitle => 'Satışı Sil';

  @override
  String get saleDetailsDeleteMessage =>
      'Bu satış kaydını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get saleDetailsDeleteFailed => 'Satış silinemedi.';

  @override
  String get saleDetailsCustomer => 'MÜŞTERİ';

  @override
  String get saleDetailsAmount => 'TUTAR';

  @override
  String get saleDetailsStatus => 'Durum';

  @override
  String get saleDetailsTrackingNumber => 'Takip No';

  @override
  String get saleDetailsItemsTitle => 'Ürünler';

  @override
  String get saleDetailsItemsFailed => 'Ürün kalemleri yüklenemedi.';

  @override
  String get saleDetailsNoItems => 'Bu satışa ürün eklenmemiş.';

  @override
  String saleDetailsQuantityLine(Object count) {
    return 'Adet: $count';
  }

  @override
  String get financeTitle => 'Kasa Özeti';

  @override
  String get financeSubtitle => 'Finansal durum ve nakit akışı';

  @override
  String get financeReportButton => 'Rapor Al';

  @override
  String get financeSummaryFailed => 'Kasa özeti yüklenemedi.';

  @override
  String get financeTotalIncome => 'Toplam Gelir';

  @override
  String get financeTotalExpense => 'Toplam Gider';

  @override
  String get financeViewCashMovements => 'Kasa Hareketlerini Görüntüle';

  @override
  String get financeChartTitle => 'Gelir / Gider Analizi';

  @override
  String get financeChartFailed => 'Grafik verisi yüklenemedi.';

  @override
  String get financeTopSelling => 'En Çok Satan Ürünler';

  @override
  String get financeTopRevenue => 'En Yüksek Gelir Getiren Ürünler';

  @override
  String get financeReportNotReady => 'Rapor için veri henüz hazır değil.';

  @override
  String financeReportExportSuccess(Object path) {
    return 'Kasa raporu dışa aktarıldı: $path';
  }

  @override
  String get financeReportFailed => 'Rapor oluşturulamadı.';

  @override
  String get financeNetProfit => 'Net Kâr';

  @override
  String financeChangeVsPrevious(Object percent) {
    return '$percent geçen döneme göre';
  }

  @override
  String get financeNoDataForChart => 'Veri yok.';

  @override
  String get financeIncomeLegend => 'Gelir';

  @override
  String get financeExpenseLegend => 'Gider';

  @override
  String get financeNoPeriodData => 'Bu periyotta veri yok.';

  @override
  String get financePeriodDaily => 'Günlük';

  @override
  String get financePeriodWeekly => 'Haftalık';

  @override
  String get financePeriodMonthly => 'Aylık';

  @override
  String get financePeriodYearly => 'Yıllık';

  @override
  String get cashFlowTitle => 'Kasa Hareketleri';

  @override
  String get cashFlowMovementType => 'Hareket Türü';

  @override
  String get cashFlowIncomeFilter => 'Girdiler';

  @override
  String get cashFlowExpenseFilter => 'Çıktılar';

  @override
  String get cashFlowPickDateRange => 'Tarih Aralığı Seç';

  @override
  String get cashFlowClearFilter => 'Filtreyi Temizle';

  @override
  String get cashFlowTotalBalance => 'Toplam Bakiye';

  @override
  String get cashFlowMonthIncome => 'Bu Ayki Girdiler';

  @override
  String get cashFlowMonthExpense => 'Bu Ayki Çıktılar';

  @override
  String get cashFlowRecentTransactions => 'Son İşlemler';

  @override
  String get cashFlowLoadFailed => 'Kasa hareketleri yüklenemedi.';

  @override
  String get cashFlowEmpty => 'Bu filtrede kasa hareketi bulunamadı.';

  @override
  String get cargoStatusPackaging => 'Kargolanıyor';

  @override
  String get cargoStatusDelayed => 'Geciken Kargo';

  @override
  String get cargoStatusShipped => 'Kargoya Verildi';

  @override
  String get cargoStatusCompleted => 'Satış Tamamlandı';

  @override
  String get cargoStatusCanceled => 'İptal Edildi';

  @override
  String get purchaseStatusCompleted => 'Tamamlandı';

  @override
  String get purchaseStatusPending => 'Bekliyor';

  @override
  String get purchaseStatusCanceled => 'İptal Edildi';
}
