-- =============================================================================
-- Satış Defteri — purchase-photos storage bucket
-- =============================================================================
-- Alış kayıtlarına fotoğraf ekleyebilmek için 'purchase-photos' bucket'ını
-- oluşturur ve RLS politikalarını kurar. Yükleme yolu "<userId>/..." biçiminde
-- olduğundan politikalar klasörün ilk segmentini auth.uid() ile eşleştirir.
--
-- Supabase Dashboard → SQL Editor → New query alanına yapıştırıp "Run" deyin.
-- Betik idempotent'tir.
-- =============================================================================

insert into storage.buckets (id, name, public)
values ('purchase-photos', 'purchase-photos', true)
on conflict (id) do update set public = true;

drop policy if exists "purchase_photos_public_read" on storage.objects;
create policy "purchase_photos_public_read" on storage.objects
  for select
  using (bucket_id = 'purchase-photos');

drop policy if exists "purchase_photos_user_insert" on storage.objects;
create policy "purchase_photos_user_insert" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'purchase-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "purchase_photos_user_update" on storage.objects;
create policy "purchase_photos_user_update" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'purchase-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "purchase_photos_user_delete" on storage.objects;
create policy "purchase_photos_user_delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'purchase-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
