-- =============================================================================
-- Satış Defteri — uygulama içi "Hesabımı Sil" için sunucu fonksiyonu
-- =============================================================================
-- Google Play, hesap oluşturulabilen uygulamalarda uygulama İÇİNDE hesap silme
-- yolu ister. Auth kullanıcısını silmek service_role gerektirir; bu yüzden
-- SECURITY DEFINER bir fonksiyon kullanırız: fonksiyon, çağıran kullanıcının
-- (auth.uid()) tüm verisini ve auth kaydını siler.
--
-- Supabase Dashboard → SQL Editor → New query → yapıştır → Run.
-- Betik idempotent'tir (create or replace).
-- =============================================================================

create or replace function public.delete_current_user()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Oturum bulunamadı.';
  end if;

  -- Alt (kalem) tablolar — sahiplik üst tablo üzerinden.
  delete from public.sale_items     where sale_id     in (select id from public.sales     where user_id = uid);
  delete from public.purchase_items where purchase_id in (select id from public.purchases where user_id = uid);

  -- Ana tablolar.
  delete from public.sales      where user_id = uid;
  delete from public.purchases  where user_id = uid;
  delete from public.products   where user_id = uid;
  delete from public.customers  where user_id = uid;
  delete from public.suppliers  where user_id = uid;
  delete from public.profiles   where user_id = uid;

  -- Kullanıcının yüklediği depolama nesneleri (klasör adının ilk segmenti = uid).
  delete from storage.objects
   where bucket_id in ('product-photos', 'purchase-photos', 'avatars')
     and (storage.foldername(name))[1] = uid::text;

  -- Son olarak auth kullanıcısını sil (oturumlar/kimlikler cascade ile gider).
  delete from auth.users where id = uid;
end;
$$;

-- Yalnızca giriş yapmış kullanıcı kendi hesabını silebilsin.
revoke all on function public.delete_current_user() from public, anon;
grant execute on function public.delete_current_user() to authenticated;
