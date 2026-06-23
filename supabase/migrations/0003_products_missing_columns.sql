-- =============================================================================
-- Satış Defteri — products tablosu eksik boyut kolonları düzeltmesi
-- =============================================================================
-- "Ürün kaydedilemedi" sorununu giderir: products tablosunda 'width' ve
-- 'height' kolonları eksikti, ama uygulama ürün eklerken bu alanlara yazıyor.
-- ('length' ve 'weight' zaten mevcuttu.)
--
-- Supabase Dashboard → SQL Editor → New query alanına yapıştırıp "Run" deyin.
-- Betik idempotent'tir; birden fazla kez çalıştırmak güvenlidir.
-- =============================================================================

alter table public.products
  add column if not exists width numeric;

alter table public.products
  add column if not exists height numeric;
