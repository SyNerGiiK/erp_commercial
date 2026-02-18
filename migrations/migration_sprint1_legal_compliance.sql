-- ============================================================
-- MIGRATION SPRINT 1-2 : Conformité légale micro-entreprise
-- Date: 2026-02
-- ============================================================

-- ========================================
-- 1. NOUVEAUX CHAMPS ProfilEntreprise
-- ========================================

-- Taux de pénalités de retard (défaut: taux directeur BCE + 10 ≈ 11.62% en 2025)
ALTER TABLE profil_entreprise
  ADD COLUMN IF NOT EXISTS taux_penalites_retard NUMERIC(5,2) DEFAULT 11.62;

-- Escompte applicable en cas de paiement anticipé
ALTER TABLE profil_entreprise
  ADD COLUMN IF NOT EXISTS escompte_applicable BOOLEAN DEFAULT false;

-- Est immatriculé au RCS/RM (si false → mention "Dispensé d'immatriculation" sur PDF)
ALTER TABLE profil_entreprise
  ADD COLUMN IF NOT EXISTS est_immatricule BOOLEAN DEFAULT false;


-- ========================================
-- 2. NOUVEAUX CHAMPS Factures
-- ========================================

-- Numéro de bon de commande client (facultatif)
ALTER TABLE factures
  ADD COLUMN IF NOT EXISTS numero_bon_commande TEXT;

-- Motif de l'avoir (obligatoire moralement pour type='avoir')
ALTER TABLE factures
  ADD COLUMN IF NOT EXISTS motif_avoir TEXT;


-- ========================================
-- 3. TABLE AUDIT_LOGS (piste d'audit loi anti-fraude 2018)
-- ========================================

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE', 'VALIDATE', 'PAYMENT')),
  old_data JSONB,
  new_data JSONB,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Index pour recherche rapide par document
CREATE INDEX IF NOT EXISTS idx_audit_logs_record ON audit_logs(record_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_table ON audit_logs(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at DESC);

-- RLS : chaque utilisateur ne voit que ses propres logs
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS audit_logs_policy ON audit_logs
  FOR ALL
  USING (auth.uid() = user_id);


-- ========================================
-- 4. TRIGGER D'AUDIT AUTOMATIQUE SUR FACTURES
-- ========================================

CREATE OR REPLACE FUNCTION audit_facture_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_logs (user_id, table_name, record_id, action, new_data)
    VALUES (NEW.user_id, 'factures', NEW.id, 'INSERT', to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_logs (user_id, table_name, record_id, action, old_data, new_data)
    VALUES (NEW.user_id, 'factures', NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_logs (user_id, table_name, record_id, action, old_data)
    VALUES (OLD.user_id, 'factures', OLD.id, 'DELETE', to_jsonb(OLD));
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_audit_factures ON factures;
CREATE TRIGGER trg_audit_factures
  AFTER INSERT OR UPDATE OR DELETE ON factures
  FOR EACH ROW EXECUTE FUNCTION audit_facture_changes();


-- ========================================
-- 5. TRIGGER D'AUDIT SUR DEVIS
-- ========================================

CREATE OR REPLACE FUNCTION audit_devis_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_logs (user_id, table_name, record_id, action, new_data)
    VALUES (NEW.user_id, 'devis', NEW.id, 'INSERT', to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_logs (user_id, table_name, record_id, action, old_data, new_data)
    VALUES (NEW.user_id, 'devis', NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_logs (user_id, table_name, record_id, action, old_data)
    VALUES (OLD.user_id, 'devis', OLD.id, 'DELETE', to_jsonb(OLD));
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_audit_devis ON devis;
CREATE TRIGGER trg_audit_devis
  AFTER INSERT OR UPDATE OR DELETE ON devis
  FOR EACH ROW EXECUTE FUNCTION audit_devis_changes();


-- ========================================
-- 6. TRIGGER D'AUDIT SUR PAIEMENTS
-- ========================================

CREATE OR REPLACE FUNCTION audit_paiement_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_logs (user_id, table_name, record_id, action, new_data)
    VALUES (NEW.user_id, 'paiements', NEW.id, 'INSERT', to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_logs (user_id, table_name, record_id, action, old_data, new_data)
    VALUES (NEW.user_id, 'paiements', NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_logs (user_id, table_name, record_id, action, old_data)
    VALUES (OLD.user_id, 'paiements', OLD.id, 'DELETE', to_jsonb(OLD));
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_audit_paiements ON paiements;
CREATE TRIGGER trg_audit_paiements
  AFTER INSERT OR UPDATE OR DELETE ON paiements
  FOR EACH ROW EXECUTE FUNCTION audit_paiement_changes();


-- ========================================
-- 7. PROTECTION IMMUTABILITÉ : BLOQUER UPDATE SUR FACTURES VALIDÉES
-- ========================================

CREATE OR REPLACE FUNCTION protect_validated_facture()
RETURNS TRIGGER AS $$
BEGIN
  -- Autoriser les changements de statut (paiement, envoi) mais pas de contenu
  IF OLD.statut_juridique != 'brouillon' THEN
    -- Seuls certains champs sont modifiables après validation
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

DROP TRIGGER IF EXISTS trg_protect_validated_facture ON factures;
CREATE TRIGGER trg_protect_validated_facture
  BEFORE UPDATE ON factures
  FOR EACH ROW EXECUTE FUNCTION protect_validated_facture();
