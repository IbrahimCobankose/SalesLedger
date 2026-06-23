-- =============================================================================
-- Satış Defteri — product-photos storage bucket düzeltmesi
-- =============================================================================
-- "Ürün fotoğrafı yüklenemedi" sorununu giderir: uygulama ürün fotoğraflarını
-- 'product-photos' bucket'ına yükler ama bu bucket oluşturulmamıştı.
--
-- Supabase Dashboard → SQL Editor → New query alanına yapıştırıp "Run" deyin.
-- Betik idempotent'tir; birden fazla kez çalıştırmak güvenlidir.
-- =============================================================================

-- 1) 'product-photos' bucket'ını oluştur (herkese açık okuma).
insert into storage.buckets (id, name, public)
values ('product-photos', 'product-photos', true)
on conflict (id) do update set public = true;

-- 2) Storage RLS politikaları.
--    Uygulama dosyaları "<userId>/<zaman>_<index>.jpg" yoluyla yüklediği için
--    politikalar klasörün ilk segmentini (userId) auth.uid() ile eşleştirir.

-- Herkes okuyabilir (ürün görsellerinin gösterilebilmesi için).
drop policy if exists "product_photos_public_read" on storage.objects;
create policy "product_photos_public_read" on storage.objects
  for select
  using (bucket_id = 'product-photos');

-- Giriş yapmış kullanıcı yalnızca kendi klasörüne yükleyebilir.
drop policy if exists "product_photos_user_insert" on storage.objects;
create policy "product_photos_user_insert" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'product-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Kendi dosyasını güncelleyebilir.
drop policy if exists "product_photos_user_update" on storage.objects;
create policy "product_photos_user_update" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'product-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Kendi dosyasını silebilir.
drop policy if exists "product_photos_user_delete" on storage.objects;
create policy "product_photos_user_delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'product-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
