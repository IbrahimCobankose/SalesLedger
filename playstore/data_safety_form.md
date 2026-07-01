# Play Console — Veri Güvenliği (Data Safety) Formu Cevap Anahtarı

> Play Console → **App content → Data safety** bölümünü açıp aşağıdaki cevapları birebir işaretle.
> Uygulamada reklam/analitik/crash SDK'sı **yok**, bu yüzden çoğu bölüm "Hayır".

---

## Bölüm 1 — Data collection and security (genel)

| Soru | Cevap |
|------|-------|
| Does your app collect or share any of the required user data types? | **Yes** (topluyor) |
| Is all of the user data collected by your app encrypted in transit? | **Yes** (HTTPS/TLS) |
| Do you provide a way for users to request that their data is deleted? | **Yes** (uygulama içi "Hesabı Sil" + e-posta) |

---

## Bölüm 2 — Data types (hangi veriler toplanıyor)

Aşağıdakileri **"Collected = Yes"**, **"Shared = No"** işaretle. Hiçbiri üçüncü tarafla paylaşılmıyor.

### Personal info
| Veri tipi | Collected | Shared | Purpose (amaç) | Optional/Required |
|-----------|-----------|--------|----------------|-------------------|
| **Email address** | Yes | No | Account management | Required |
| **Name** (firma adı + profil adı) | Yes | No | Account management, App functionality | Required |

### Financial info
| Veri tipi | Collected | Shared | Purpose | Not |
|-----------|-----------|--------|---------|-----|
| **Other financial info** (kullanıcının kendi girdiği satış/alış tutarları) | Yes | No | App functionality | Kullanıcı kendi defterini tutuyor |

> Not: Burada **"User payment info"** (kredi kartı vb.) **toplanmıyor** — onu işaretleme. Sadece kullanıcının kendi kayıt tuttuğu tutarlar olduğu için "Other financial info" en doğru ve güvenli seçim.

### Photos and videos
| Veri tipi | Collected | Shared | Purpose | Optional/Required |
|-----------|-----------|--------|---------|-------------------|
| **Photos** | Yes | No | App functionality | Optional (kullanıcı isterse ekler) |

### App info and performance / Device IDs / Location / Contacts / Messages / Web history / Audio / Calendar
- **Hiçbiri toplanmıyor → hepsini boş bırak (Collected = No).**
- Crash logs / Diagnostics: **No** (crash SDK yok).

---

## Bölüm 3 — Her veri tipi için tekrarlanan sorular

Her "Yes" dediğin veri tipinde Play sana şunu sorar; cevaplar:

- **Is this data collected, shared, or both?** → *Collected*
- **Is this data processed ephemerally?** → *No, it is sent off the device and stored*
- **Is this data required or optional?** → Email/Name/Financial = *Required*; Photos = *Users can choose (Optional)*
- **Why is this data collected?** → *App functionality* ve (e-posta/ad için) *Account management*

---

## Bölüm 4 — Data deletion (App content içindeki ayrı bölüm)

Google, hesap oluşturulabilen uygulamalarda **silme yolu** ister. Artık uygulamada
**hem uygulama içi "Hesabımı Sil" butonu hem de e-posta** yöntemi var.

- **Does your app allow users to request that some or all of their data is deleted?** → **Yes**
- **Can users request that their account is deleted?** → **Yes**
- **How can users request deletion?**
  - *In-app:* Ayarlar → **Hesabı Sil** → Hesabımı Sil (tüm veri + auth kaydı kalıcı silinir).
  - *Web/e-posta yedek yöntemi:* gizlilik politikasındaki silme bölümü.
- **Account/Data deletion URL** alanına gizlilik politikasının silme bölümünü ver:
  `https://SENIN-URL/privacy_policy.html#silme`

> ✅ Uygulama içi silme akışı eklendi: Supabase'de SECURITY DEFINER `delete_current_user()`
> fonksiyonu (migration `supabase/migrations/0008_delete_account.sql`) kullanıcının tüm
> verisini + auth kaydını siler. **Bu migration'ı Supabase SQL Editor'da çalıştırmayı unutma**,
> aksi halde butona basınca "Hesap silinemedi" hatası alınır.

---

## Özet (tek bakışta)
- Toplanıyor: **e-posta, ad, kendi finansal kayıtları, fotoğraflar**
- Paylaşılıyor: **hiçbiri**
- Şifreleme: **aktarımda var (TLS)**
- Silme: **var (e-posta talebi)**
- Reklam/analitik/izleme: **yok**
