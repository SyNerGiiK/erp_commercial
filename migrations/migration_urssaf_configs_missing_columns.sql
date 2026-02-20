-- Migration: Ajouter les colonnes manquantes à urssaf_configs
-- Contexte: Le modèle Dart envoie ces champs mais ils n'existent pas dans la table Supabase

ALTER TABLE urssaf_configs
  ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS source_api BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS plafond_vl_rfr TEXT,
  ADD COLUMN IF NOT EXISTS plafond_ca_micro_vente TEXT,
  ADD COLUMN IF NOT EXISTS plafond_ca_micro_service TEXT,
  ADD COLUMN IF NOT EXISTS seuil_tva_micro_vente TEXT,
  ADD COLUMN IF NOT EXISTS seuil_tva_micro_vente_maj TEXT,
  ADD COLUMN IF NOT EXISTS seuil_tva_micro_service TEXT,
  ADD COLUMN IF NOT EXISTS seuil_tva_micro_service_maj TEXT;
