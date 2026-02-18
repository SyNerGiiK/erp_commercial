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

-- 5. Mise à jour des triggers pour autoriser le soft-delete ET les transitions de statut
-- Les triggers prevent_*_modification() bloquaient TOUT update si statut != brouillon
-- Nouveau comportement : seules les colonnes financières/structurelles sont protégées
-- Les changements de statut, signature, archivage, soft-delete sont autorisés

CREATE OR REPLACE FUNCTION prevent_facture_modification()
RETURNS TRIGGER AS $$
BEGIN
  -- Autoriser le soft-delete et la restauration depuis la corbeille
  IF TG_OP = 'UPDATE' AND (OLD.deleted_at IS DISTINCT FROM NEW.deleted_at) THEN
    RETURN NEW;
  END IF;

  -- Pour les DELETE réels, bloquer si pas brouillon
  IF TG_OP = 'DELETE' THEN
    IF OLD.statut != 'brouillon' OR OLD.statut_juridique != 'brouillon' THEN
      RAISE EXCEPTION 'Impossible de supprimer une facture validée (statut: %, statut_juridique: %)', OLD.statut, OLD.statut_juridique;
    END IF;
    RETURN OLD;
  END IF;

  -- Pour les UPDATE : autoriser les transitions de statut et métadonnées
  -- mais bloquer les modifications de contenu financier sur facture non-brouillon
  IF OLD.statut_juridique != 'brouillon' THEN
    IF (OLD.total_ht IS DISTINCT FROM NEW.total_ht)
       OR (OLD.total_tva IS DISTINCT FROM NEW.total_tva)
       OR (OLD.total_ttc IS DISTINCT FROM NEW.total_ttc)
       OR (OLD.objet IS DISTINCT FROM NEW.objet)
       OR (OLD.client_id IS DISTINCT FROM NEW.client_id)
       OR (OLD.remise_taux IS DISTINCT FROM NEW.remise_taux)
       OR (OLD.conditions_reglement IS DISTINCT FROM NEW.conditions_reglement)
    THEN
      RAISE EXCEPTION 'Modification interdite : facture validée (statut_juridique = %). Créez un avoir.', OLD.statut_juridique;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION protect_validated_facture()
RETURNS TRIGGER AS $$
BEGIN
  -- Autoriser le soft-delete et la restauration depuis la corbeille
  IF (OLD.deleted_at IS DISTINCT FROM NEW.deleted_at) THEN
    RETURN NEW;
  END IF;

  -- Autoriser les changements de statut (paiement, envoi) mais pas de contenu
  IF OLD.statut_juridique != 'brouillon' THEN
    IF (OLD.total_ht IS DISTINCT FROM NEW.total_ht)
       OR (OLD.total_tva IS DISTINCT FROM NEW.total_tva)
       OR (OLD.total_ttc IS DISTINCT FROM NEW.total_ttc)
       OR (OLD.objet IS DISTINCT FROM NEW.objet)
       OR (OLD.client_id IS DISTINCT FROM NEW.client_id)
       OR (OLD.remise_taux IS DISTINCT FROM NEW.remise_taux)
       OR (OLD.conditions_reglement IS DISTINCT FROM NEW.conditions_reglement)
    THEN
      RAISE EXCEPTION 'Modification interdite : facture validée (statut_juridique = %). Créez un avoir.',
        OLD.statut_juridique;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION prevent_devis_modification()
RETURNS TRIGGER AS $$
BEGIN
  -- Autoriser le soft-delete et la restauration depuis la corbeille
  IF TG_OP = 'UPDATE' AND (OLD.deleted_at IS DISTINCT FROM NEW.deleted_at) THEN
    RETURN NEW;
  END IF;

  -- Pour les DELETE réels, bloquer si pas brouillon
  IF TG_OP = 'DELETE' THEN
    IF OLD.statut NOT IN ('brouillon', 'expire') THEN
      RAISE EXCEPTION 'Impossible de supprimer un devis validé (statut: %)', OLD.statut;
    END IF;
    RETURN OLD;
  END IF;

  -- Pour les UPDATE : autoriser les transitions de statut et métadonnées
  -- mais bloquer les modifications de contenu financier sur devis non-brouillon
  IF OLD.statut != 'brouillon' THEN
    IF (OLD.total_ht IS DISTINCT FROM NEW.total_ht)
       OR (OLD.total_tva IS DISTINCT FROM NEW.total_tva)
       OR (OLD.total_ttc IS DISTINCT FROM NEW.total_ttc)
       OR (OLD.objet IS DISTINCT FROM NEW.objet)
       OR (OLD.client_id IS DISTINCT FROM NEW.client_id)
       OR (OLD.remise_taux IS DISTINCT FROM NEW.remise_taux)
       OR (OLD.conditions_reglement IS DISTINCT FROM NEW.conditions_reglement)
    THEN
      RAISE EXCEPTION 'Modification interdite : devis non-brouillon (statut = %). Créez un avenant.', OLD.statut;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. RLS : les politiques existantes filtrent par user_id, pas besoin de modifier
-- Le filtrage deleted_at est fait côté application (requêtes Supabase)
