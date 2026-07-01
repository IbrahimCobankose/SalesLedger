# Satış Defteri — Play Store Yayınlama Adımları (Detaylı)

## DURUM
- [x] Release AAB hazır: `build/app/outputs/bundle/release/app-release.aab`
- [x] INTERNET izni, imzalama, RLS, hesap silme tamam
- [x] 0008 SQL çalıştırıldı (hesap silme aktif)
- [ ] **Uygulama ikonu hâlâ varsayılan Flutter logosu — değiştirilmeli**
- [ ] Mağaza görselleri (512x512 ikon + 1024x500 feature graphic)
- [ ] Gizlilik politikası yayınlanacak (URL)
- [ ] Ekran görüntüleri üretilecek
- [ ] Test hesabı (inceleme ekibi için)

---

## ADIM 0 — Yayından ÖNCE bitmesi gerekenler

### 0.1 Uygulama ikonu (ZORUNLU)
Tasarladığın logoyu `assets/icon/app_icon.png` olarak kaydet (en az 1024x1024, kare, PNG).
Sonra `flutter_launcher_icons` ile tüm boyutlar otomatik üretilir. (Claude bunu senin için kurabilir.)

### 0.2 Mağaza grafikleri (ZORUNLU)
- **Uygulama ikonu:** 512 x 512 px, PNG (32-bit)
- **Öne çıkan görsel (Feature graphic):** 1024 x 500 px, PNG/JPEG
- **Telefon ekran görüntüleri:** en az 2, en fazla 8 (screenshot_studio.html ile)

### 0.3 Test hesabı (ÇOK ÖNEMLİ)
Uygulama girişli olduğu için inceleme ekibinin giriş yapması gerekir.
- Demo bir hesap aç (örn. demo@satisdefteri.app), içine seed_demo_data.sql ile veri yükle.
- E-posta + şifreyi Play Console → App access bölümüne gireceksin.

---

## ADIM 1 — Gizlilik Politikasını Yayınla (URL al)

**Netlify Drop (en kolay, ücretsiz):**
1. https://app.netlify.com/drop adresine git, Google ile giriş yap.
2. `playstore/privacy_policy.html` dosyasını sayfaya sürükle-bırak.
3. Verilen URL'i kopyala: `https://....netlify.app/privacy_policy.html`
4. Bu URL'i not et — Play Console'da iki yerde kullanacaksın.

---

## ADIM 2 — Ekran Görüntülerini Üret
1. `playstore/screenshot_studio.html` dosyasını çift tıkla (tarayıcıda açılır).
2. 5 ham ekran görüntünü sürükle-bırak.
3. "Tümünü indir (PNG)" → 1080x1920 dosyalar iner.

---

## ADIM 3 — Play Console Hesabı
1. https://play.google.com/console → Google hesabınla gir.
2. Geliştirici kaydı: **tek seferlik 25 USD** + kimlik doğrulama (1-2 gün sürebilir).
3. Hesap tipi: bireysel veya kuruluş. (Bireysel hesaplarda aşağıdaki kapalı test şartı geçerli.)

---

## ADIM 4 — Uygulama Oluştur
Play Console → **Create app**:
- App name: `Satış Defteri`
- Default language: Türkçe (tr-TR)
- App or game: **App**
- Free or paid: **Free**
- Beyanları (ücretsiz, politikalara uyum) işaretle → Create.

---

## ADIM 5 — Store Listing (Main store listing)
`playstore/store_listing.md` içinden kopyala:
- App name, Short description, Full description
- App icon (512x512), Feature graphic (1024x500), Phone screenshots
- App category: **Business** (veya Finance)
- Contact email: ibrahim451914@gmail.com
- Save.

---

## ADIM 6 — App content (Policy beyanları) — SOL MENÜ

Hepsini tek tek doldur:

1. **Privacy policy:** Netlify URL'ini yapıştır.
2. **App access:** "All functionality is restricted" → demo hesabın e-posta+şifresini gir
   (inceleme ekibi giriş yapacak).
3. **Ads:** "No, my app does not contain ads."
4. **Content rating:** Anketi doldur (iş/araç uygulaması, şiddet/içerik yok) → IARC derecesi alırsın.
5. **Target audience:** Yaş: 18+ (veya 13+). Çocuklara yönelik **değil**.
6. **Data safety:** `playstore/data_safety_form.md`'yi birebir uygula.
7. **Data deletion:** Account deletion = Yes. URL: `https://....netlify.app/privacy_policy.html#silme`
8. **Government apps / Financial features / Health:** Hepsi **No/Hayır**
   (kullanıcının kendi defteri; ödeme/banka entegrasyonu yok).
9. **News app:** No.

---

## ADIM 7 — Kapalı Test (BİREYSEL hesaplarda ZORUNLU)
13 Kasım 2023 sonrası açılan **bireysel** geliştirici hesapları, production'dan önce:
- **En az 12 test kullanıcısı** + **14 gün** kesintisiz kapalı test yapmalı.
- Play Console → Testing → Closed testing → track oluştur, AAB yükle, testçi e-postalarını ekle.
- 14 gün sonra "Apply for production" açılır.
> Kuruluş (organization) hesaplarında bu şart yoktur, doğrudan production'a geçebilirsin.

---

## ADIM 8 — Production Sürümü
1. Play Console → **Production** → **Create new release**.
2. **Play App Signing**'i kabul et (Google imza anahtarını yönetir; senin upload key'in zaten ayarlı).
3. `app-release.aab` dosyasını yükle.
4. Release name: `1.0.0 (1)`
5. Release notes (tr-TR):
   ```
   İlk sürüm: satış, alış, stok, kasa ve finans takibi tek uygulamada.
   ```
6. Save → Review release.

---

## ADIM 9 — Yayınla
1. **Countries/regions:** Türkiye (+ istersen tümü).
2. Tüm uyarılar temizlenince → **Start rollout to Production** → onayla.
3. İlk inceleme genelde birkaç gün sürer. Onaylanınca uygulama mağazada yayınlanır.

---

## NOTLAR
- versionCode artık 1. Her güncellemede `pubspec.yaml`'da `1.0.0+1` → `1.0.1+2` gibi artır.
- upload-keystore.jks'i KAYBETME (güvenli yedekle) — kaybedersen güncelleme yapamazsın.
- İlk yüklemeden sonra paket adı (com.satisdefteri.app) değiştirilemez.
