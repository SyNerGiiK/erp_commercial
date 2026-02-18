-- Migration Sprint 11 : Soft-delete sur les tables principales
-- Date : 2026-02-18
-- Description : Ajout de la colonne deleted_at pour le soft-delete

-- 1. Ajout de la colonne deleted_at sur les 4 tables principales
ALTER TABLE factures ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
ALTER TABLE devis ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
ALTER TABLE depenses ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

-- 2. Index partiels pour optimiser les requêtes (la plupart des items ne sont PAS supprimés)
CREATE INDEX IF NOT EXISTS idx_factures_not_deleted ON factures(user_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_devis_not_deleted ON devis(user_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_clients_not_deleted ON clients(user_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_depenses_not_deleted ON depenses(user_id) WHERE deleted_at IS NULL;

-- 3. Index pour la corbeille (items supprimés)
CREATE INDEX IF NOT EXISTS idx_factures_deleted ON factures(user_id, deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_devis_deleted ON devis(user_id, deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_clients_deleted ON clients(user_id, deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_depenses_deleted ON depenses(user_id, deleted_at) WHERE deleted_at IS NOT NULL;

-- 4. Fonction de purge automatique (supprime définitivement les items > 30 jours dans la corbeille)
CREATE OR REPLACE FUNCTION purge_old_deleted_items()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Purge paiements orphelins d'abord (FK)
  DELETE FROM paiements WHERE facture_id IN (
    SELECT id FROM factures WHERE deleted_at < NOW() - INTERVAL '30 days'
  );
  DELETE FROM lignes_factures WHERE facture_id IN (
    SELECT id FROM factures WHERE deleted_at < NOW() - INTERVAL '30 days'
  );
  DELETE FROM lignes_chiffrages WHERE facture_id IN (
    SELECT id FROM factures WHERE deleted_at < NOW() - INTERVAL '30 days'
  );
  DELETE FROM lignes_chiffrages WHERE devis_id IN (
    SELECT id FROM devis WHERE deleted_at < NOW() - INTERVAL '30 days'
  );
  DELETE FROM lignes_devis WHERE devis_id IN (
    SELECT id FROM devis WHERE deleted_at < NOW() - INTERVAL '30 days'
  );

  -- Purge les documents eux-mêmes
  DELETE FROM factures WHERE deleted_at < NOW() - INTERVAL '30 days';
  DELETE FROM devis WHERE deleted_at < NOW() - INTERVAL '30 days';
  DELETE FROM clients WHERE deleted_at < NOW() - INTERVAL '30 days';
  DELETE FROM depenses WHERE deleted_at < NOW() - INTERVAL '30 days';
END;
$$;

-- 5. RLS : les politiques existantes filtrent par user_id, pas besoin de modifier
-- Le filtrage deleted_at est fait côté application (requêtes Supabase)
