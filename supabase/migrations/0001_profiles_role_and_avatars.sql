-- =============================================================================
-- Satış Defteri — profiles tablosu ve avatars storage düzeltmesi
-- =============================================================================
-- Bu betik iki sorunu giderir:
--   1) "Profil kaydedilemedi": profiles tablosunda 'role' kolonu eksikti.
--   2) "Profil resmi yüklenemedi": 'avatars' storage bucket'ı yoktu.
--
-- Supabase Dashboard → SQL Editor → New query alanına yapıştırıp "Run" deyin.
-- Betik idempotent'tir; birden fazla kez çalıştırmak güvenlidir.
-- =============================================================================

-- 1) Eksik 'role' kolonunu ekle (nullable; ilk profil rolsüz oluşturulabilir).
alter table public.profiles
  add column if not exists role text;

-- 2) profiles tablosu RLS politikaları — kullanıcı yalnızca kendi profillerini
--    görüntüleyip yönetebilir. (Mevcutsa yeniden oluşturulur.)
alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
  for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "profiles_delete_own" on public.profiles;
create policy "profiles_delete_own" on public.profiles
  for delete to authenticated
  using (auth.uid() = user_id);

-- 3) 'avatars' storage bucket'ını oluştur (herkese açık okuma — public avatar URL).
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

-- 4) avatars bucket için storage RLS politikaları.
--    Uygulama dosyaları "<userId>/<zaman>.<uzanti>" yoluyla yüklediği için
--    politikalar klasörün ilk segmentini (userId) auth.uid() ile eşleştirir.

-- Herkes okuyabilir (avatar görsellerinin gösterilebilmesi için).
drop policy if exists "avatars_public_read" on storage.objects;
create policy "avatars_public_read" on storage.objects
  for select
  using (bucket_id = 'avatars');

-- Giriş yapmış kullanıcı yalnızca kendi klasörüne yükleyebilir.
drop policy if exists "avatars_user_insert" on storage.objects;
create policy "avatars_user_insert" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Kendi dosyasını güncelleyebilir (upsert için gerekli).
drop policy if exists "avatars_user_update" on storage.objects;
create policy "avatars_user_update" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Kendi dosyasını silebilir.
drop policy if exists "avatars_user_delete" on storage.objects;
create policy "avatars_user_delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
