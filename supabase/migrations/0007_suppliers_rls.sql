-- =============================================================================
-- Satış Defteri — suppliers tablosu için eksik RLS politikaları
-- =============================================================================
-- 01_security_hardening.sql, suppliers üzerindeki eski "Kullanıcılar kendi
-- tedarikçilerini yönetebilir" politikasını DROP etti ama yerine yenisini
-- EKLEMEDİ. 0005_rls_all_tables.sql ise suppliers'ı dizisine almadı.
-- Sonuç: suppliers tablosu sahip-bazlı politikadan yoksun kaldı.
--
-- backup_service.dart suppliers tablosunu okuyor; politika olmadan ya boş döner
-- ya da (RLS kapalıysa) başka kullanıcıların verisi sızar. Bu betik diğer ana
-- tablolarla aynı sahip-bazlı (auth.uid() = user_id) korumayı ekler.
--
-- Supabase Dashboard → SQL Editor → New query alanına yapıştırıp "Run" deyin.
-- Betik idempotent'tir; birden fazla kez çalıştırmak güvenlidir.
-- =============================================================================

alter table public.suppliers enable row level security;

drop policy if exists "sl_suppliers_select" on public.suppliers;
create policy "sl_suppliers_select" on public.suppliers
  for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "sl_suppliers_insert" on public.suppliers;
create policy "sl_suppliers_insert" on public.suppliers
  for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "sl_suppliers_update" on public.suppliers;
create policy "sl_suppliers_update" on public.suppliers
  for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "sl_suppliers_delete" on public.suppliers;
create policy "sl_suppliers_delete" on public.suppliers
  for delete to authenticated
  using (auth.uid() = user_id);
