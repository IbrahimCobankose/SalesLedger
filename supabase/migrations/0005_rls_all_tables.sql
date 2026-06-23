-- =============================================================================
-- Satış Defteri — tüm tablolar için sahip (owner) bazlı RLS politikaları
-- =============================================================================
-- "Ürün silinmiyor" gibi sorunları giderir: silme/güncelleme için RLS politikası
-- eksik olduğunda Supabase işlemi hata vermeden 0 satır etkiler. Bu betik her
-- tablo için sahibin (auth.uid() = user_id) tüm işlemleri yapmasına izin verir.
--
-- Politikalar PERMISSIVE'dir ve OR ile birleşir; bu yüzden mevcut çalışan
-- politikaları bozmaz, yalnızca eksik izinleri ekler. Betik idempotent'tir.
--
-- Supabase Dashboard → SQL Editor → New query alanına yapıştırıp "Run" deyin.
-- =============================================================================

-- --- user_id kolonu olan ana tablolar ---
do $$
declare
  t text;
begin
  foreach t in array array['products', 'sales', 'purchases', 'customers'] loop
    execute format('alter table public.%I enable row level security;', t);

    execute format('drop policy if exists "sl_%1$s_select" on public.%1$s;', t);
    execute format(
      'create policy "sl_%1$s_select" on public.%1$s for select to authenticated using (auth.uid() = user_id);',
      t);

    execute format('drop policy if exists "sl_%1$s_insert" on public.%1$s;', t);
    execute format(
      'create policy "sl_%1$s_insert" on public.%1$s for insert to authenticated with check (auth.uid() = user_id);',
      t);

    execute format('drop policy if exists "sl_%1$s_update" on public.%1$s;', t);
    execute format(
      'create policy "sl_%1$s_update" on public.%1$s for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);',
      t);

    execute format('drop policy if exists "sl_%1$s_delete" on public.%1$s;', t);
    execute format(
      'create policy "sl_%1$s_delete" on public.%1$s for delete to authenticated using (auth.uid() = user_id);',
      t);
  end loop;
end $$;

-- --- Alt (kalem) tabloları: sahiplik üst tablo üzerinden kontrol edilir ---
alter table public.sale_items enable row level security;

drop policy if exists "sl_sale_items_all" on public.sale_items;
create policy "sl_sale_items_all" on public.sale_items
  for all to authenticated
  using (exists (
    select 1 from public.sales s where s.id = sale_id and s.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.sales s where s.id = sale_id and s.user_id = auth.uid()
  ));

alter table public.purchase_items enable row level security;

drop policy if exists "sl_purchase_items_all" on public.purchase_items;
create policy "sl_purchase_items_all" on public.purchase_items
  for all to authenticated
  using (exists (
    select 1 from public.purchases p where p.id = purchase_id and p.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.purchases p where p.id = purchase_id and p.user_id = auth.uid()
  ));
