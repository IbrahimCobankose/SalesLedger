-- =============================================================================
-- Satış Defteri — purchases tablosu eksik kolonlar + fotoğraf desteği
-- =============================================================================
-- "Alış kaydedilemedi" sorununu giderir: purchases tablosunda 'supplier_name'
-- ve 'payment_type' kolonları eksikti (uygulama bu alanlara yazıyor).
-- Ayrıca alış fotoğrafları için 'photos' kolonu eklenir.
--
-- Supabase Dashboard → SQL Editor → New query alanına yapıştırıp "Run" deyin.
-- Betik idempotent'tir; birden fazla kez çalıştırmak güvenlidir.
-- =============================================================================

alter table public.purchases
  add column if not exists supplier_name text;

alter table public.purchases
  add column if not exists payment_type text;

alter table public.purchases
  add column if not exists photos text[] not null default '{}';
