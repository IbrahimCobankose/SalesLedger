-- =====================================================================
-- GÜVENLİK SIKILAŞTIRMA MIGRATION'I (Grup A)
-- Supabase SQL Editor'da çalıştırın.
--
-- BÖLÜM 1 (RLS/grant temizliği): Hemen çalıştırılabilir, mevcut uygulamayı
--   bozmaz.
-- BÖLÜM 2 (storage gizliliği): Bucket'ları gizli yapar. Bu, ESKİ public
--   foto URL'lerini kıracağı için YALNIZCA signed-URL kullanan yeni uygulama
--   sürümüyle BİRLİKTE çalıştırılmalıdır. Detay aşağıda.
-- =====================================================================


-- =====================================================================
-- BÖLÜM 1 — RLS politika ve grant temizliği (güvenli, şimdi çalıştırılabilir)
-- =====================================================================

-- 1a) Eski/çift politikaları kaldır. Bunlar rol belirtmediği için 'anon'
--     rolüne de uygulanıyordu ve WITH CHECK içermiyordu. Yerlerine zaten
--     authenticated'a özel sl_* / *_own politikaları mevcut.
DROP POLICY IF EXISTS "Kullanıcılar kendi alış detaylarını yönetebilir" ON public.purchase_items;
DROP POLICY IF EXISTS "Kullanıcılar kendi alışlarını yönetebilir"       ON public.purchases;
DROP POLICY IF EXISTS "Kullanıcılar kendi müşterilerini yönetebilir"     ON public.customers;
DROP POLICY IF EXISTS "Kullanıcılar kendi profillerini yönetebilir"      ON public.profiles;
DROP POLICY IF EXISTS "Kullanıcılar kendi satış detaylarını yönetebilir" ON public.sale_items;
DROP POLICY IF EXISTS "Kullanıcılar kendi satışlarını yönetebilir"       ON public.sales;
DROP POLICY IF EXISTS "Kullanıcılar kendi tedarikçilerini yönetebilir"   ON public.suppliers;
DROP POLICY IF EXISTS "Kullanıcılar kendi ürünlerini yönetebilir"        ON public.products;

-- 1b) 'anon' rolünün tüm tablo yetkilerini kaldır. Uygulama yalnızca
--     authenticated kullanıcı ile çalışır; oturum açmamış (anon) erişime
--     hiçbir tabloda gerek yoktur. RLS zaten koruyor ama grant'ları da
--     kaldırmak savunmayı derinleştirir.
REVOKE ALL ON public.customers       FROM anon;
REVOKE ALL ON public.products        FROM anon;
REVOKE ALL ON public.profiles        FROM anon;
REVOKE ALL ON public.purchase_items  FROM anon;
REVOKE ALL ON public.purchases       FROM anon;
REVOKE ALL ON public.sale_items      FROM anon;
REVOKE ALL ON public.sales           FROM anon;
REVOKE ALL ON public.suppliers       FROM anon;

-- 1c) Yeni eklenecek tablolar için de varsayılan anon grant'ını engelle.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON TABLES FROM anon;


-- =====================================================================
-- BÖLÜM 2 — Storage (fotoğraf) gizliliği + RLS
-- ⚠️ YALNIZCA signed-URL kullanan yeni uygulama sürümüyle birlikte çalıştırın.
--    Bucket gizli olunca eski public URL'ler 403 döner.
-- =====================================================================

-- 2a) Bucket'ları gizli yap.
UPDATE storage.buckets SET public = false
WHERE id IN ('product-photos', 'purchase-photos', 'avatars');

-- 2b) storage.objects üzerinde RLS politikaları: her kullanıcı yalnızca
--     kendi klasörüne (path'in ilk segmenti = kullanıcı id) erişebilir.
--     Yükleme yolu uygulamada 'userId/...' biçimindedir.

-- Önce olası eski politikaları temizle (idempotent çalıştırma için).
DROP POLICY IF EXISTS "sl_storage_select_own" ON storage.objects;
DROP POLICY IF EXISTS "sl_storage_insert_own" ON storage.objects;
DROP POLICY IF EXISTS "sl_storage_update_own" ON storage.objects;
DROP POLICY IF EXISTS "sl_storage_delete_own" ON storage.objects;

CREATE POLICY "sl_storage_select_own" ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id IN ('product-photos', 'purchase-photos', 'avatars')
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "sl_storage_insert_own" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id IN ('product-photos', 'purchase-photos', 'avatars')
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "sl_storage_update_own" ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id IN ('product-photos', 'purchase-photos', 'avatars')
    AND (storage.foldername(name))[1] = auth.uid()::text
  )
  WITH CHECK (
    bucket_id IN ('product-photos', 'purchase-photos', 'avatars')
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "sl_storage_delete_own" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id IN ('product-photos', 'purchase-photos', 'avatars')
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- 2c) Mevcut kayıtlardaki tam public URL'leri bucket içi göreli path'e çevir.
--     Yeni uygulama, DB'de path saklayıp görüntülerken signed URL üretir.
--     (Bu UPDATE'leri yalnızca uygulama path tabanlı sürüme geçtiyse çalıştırın.)

-- products.photos (text[]): her elemandan public prefix'i sök.
UPDATE public.products
SET photos = ARRAY(
  SELECT regexp_replace(p, '^.*/object/public/product-photos/', '')
  FROM unnest(photos) AS p
)
WHERE photos IS NOT NULL;

-- purchases.photos (text[]):
UPDATE public.purchases
SET photos = ARRAY(
  SELECT regexp_replace(p, '^.*/object/public/purchase-photos/', '')
  FROM unnest(photos) AS p
)
WHERE photos IS NOT NULL;

-- purchase_items.photo_url (text): üründen kopyalanan anlık görsel.
UPDATE public.purchase_items
SET photo_url = regexp_replace(photo_url, '^.*/object/public/[^/]+/', '')
WHERE photo_url LIKE '%/object/public/%';

-- sale_items.photo_url (text):
UPDATE public.sale_items
SET photo_url = regexp_replace(photo_url, '^.*/object/public/[^/]+/', '')
WHERE photo_url LIKE '%/object/public/%';

-- profiles.avatar_url (text):
UPDATE public.profiles
SET avatar_url = regexp_replace(avatar_url, '^.*/object/public/avatars/', '')
WHERE avatar_url LIKE '%/object/public/avatars/%';
