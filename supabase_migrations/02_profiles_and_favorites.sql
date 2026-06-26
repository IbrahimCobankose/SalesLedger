-- =====================================================================
-- GRUP B — Profiller & Favoriler için şema değişiklikleri
-- Supabase SQL Editor'da çalıştırın. Güvenlidir; mevcut veriyi bozmaz.
--
-- products tablosunda profile_id ve is_favorite kolonları YOKTU.
-- (customers/suppliers/sales/purchases tablolarında profile_id zaten var.)
-- =====================================================================

-- 1) Favori işareti (envanterde "Favoriler" filtresi için).
ALTER TABLE public.products
  ADD COLUMN IF NOT EXISTS is_favorite boolean NOT NULL DEFAULT false;

-- 2) Ürünün hangi profil üzerinden eklendiği.
ALTER TABLE public.products
  ADD COLUMN IF NOT EXISTS profile_id uuid;

-- 3) Profil silinince ürün kaybolmasın; sadece bağ kopsun (diğer tablolarla aynı davranış).
ALTER TABLE public.products
  DROP CONSTRAINT IF EXISTS products_profile_id_fkey;
ALTER TABLE public.products
  ADD CONSTRAINT products_profile_id_fkey
  FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL;

-- 4) Profile göre filtreleme sorgularını hızlandırmak için indeksler.
CREATE INDEX IF NOT EXISTS products_profile_id_idx   ON public.products (profile_id);
CREATE INDEX IF NOT EXISTS sales_profile_id_idx       ON public.sales (profile_id);
CREATE INDEX IF NOT EXISTS purchases_profile_id_idx   ON public.purchases (profile_id);

-- Not: Mevcut (eski) kayıtların profile_id'si NULL kalır; bunlar "Atanmamış"
-- olarak görünür ve "Tüm Profiller" filtresinde listelenir. Yeni eklenen
-- kayıtlar, o an aktif profilin id'siyle kaydedilir.
