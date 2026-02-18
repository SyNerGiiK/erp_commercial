-- ============================================================
-- MIGRATION SPRINTS 14-20: Fonctionnalités Avancées
-- Date: 2026-02-18
-- Auteur: ERP Artisan
-- ============================================================

-- ============================================================
-- 1. FACTURATION RÉCURRENTE (Sprint 14)
-- ============================================================
CREATE TABLE IF NOT EXISTS factures_recurrentes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES clients(id),
  objet TEXT NOT NULL,
  frequence TEXT NOT NULL CHECK (frequence IN ('hebdomadaire', 'mensuelle', 'trimestrielle', 'annuelle')),
  prochaine_emission DATE NOT NULL,
  jour_emission INT DEFAULT 1 CHECK (jour_emission BETWEEN 1 AND 28),
  est_active BOOLEAN DEFAULT true,
  total_ht NUMERIC NOT NULL DEFAULT 0,
  total_tva NUMERIC NOT NULL DEFAULT 0,
  total_ttc NUMERIC NOT NULL DEFAULT 0,
  remise_taux NUMERIC NOT NULL DEFAULT 0,
  conditions_reglement TEXT DEFAULT '',
  notes_publiques TEXT,
  devise TEXT DEFAULT 'EUR',
  nb_factures_generees INT DEFAULT 0,
  derniere_generation TIMESTAMPTZ,
  date_fin DATE, -- null = infini
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS lignes_facture_recurrente (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  facture_recurrente_id UUID NOT NULL REFERENCES factures_recurrentes(id) ON DELETE CASCADE,
  description TEXT NOT NULL,
  quantite NUMERIC NOT NULL DEFAULT 1,
  prix_unitaire NUMERIC NOT NULL DEFAULT 0,
  total_ligne NUMERIC NOT NULL DEFAULT 0,
  type_activite TEXT DEFAULT 'service',
  unite TEXT DEFAULT 'u',
  taux_tva NUMERIC DEFAULT 20,
  ordre INT DEFAULT 0
);

ALTER TABLE factures_recurrentes ENABLE ROW LEVEL SECURITY;
ALTER TABLE lignes_facture_recurrente ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own factures_recurrentes"
  ON factures_recurrentes FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage lignes via parent"
  ON lignes_facture_recurrente FOR ALL
  USING (facture_recurrente_id IN (SELECT id FROM factures_recurrentes WHERE user_id = auth.uid()));

-- ============================================================
-- 2. SUIVI DU TEMPS (Sprint 15)
-- ============================================================
CREATE TABLE IF NOT EXISTS temps_activites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id),
  projet TEXT DEFAULT '',
  description TEXT NOT NULL,
  date_activite DATE NOT NULL,
  duree_minutes INT NOT NULL DEFAULT 0, -- durée en minutes
  taux_horaire NUMERIC DEFAULT 0,
  est_facturable BOOLEAN DEFAULT true,
  est_facture BOOLEAN DEFAULT false,
  facture_id UUID REFERENCES factures(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

ALTER TABLE temps_activites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own temps_activites"
  ON temps_activites FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- 3. RAPPELS & ÉCHÉANCES (Sprint 16)
-- ============================================================
CREATE TABLE IF NOT EXISTS rappels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  titre TEXT NOT NULL,
  description TEXT,
  type_rappel TEXT NOT NULL CHECK (type_rappel IN ('urssaf', 'cfe', 'tva', 'impots', 'custom', 'echeance_facture', 'fin_devis')),
  date_echeance DATE NOT NULL,
  est_complete BOOLEAN DEFAULT false,
  est_recurrent BOOLEAN DEFAULT false,
  frequence_recurrence TEXT CHECK (frequence_recurrence IN ('mensuelle', 'trimestrielle', 'annuelle')),
  priorite TEXT DEFAULT 'normale' CHECK (priorite IN ('basse', 'normale', 'haute', 'urgente')),
  entite_liee_id UUID, -- facture_id, devis_id, etc.
  entite_liee_type TEXT, -- 'facture', 'devis', 'cotisation'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE rappels ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own rappels"
  ON rappels FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- 4. MULTI-DEVISES & NOTES PRIVÉES (Sprint 17-18)
-- ============================================================

-- Ajout devise + notes_privees sur factures
ALTER TABLE factures ADD COLUMN IF NOT EXISTS devise TEXT DEFAULT 'EUR';
ALTER TABLE factures ADD COLUMN IF NOT EXISTS notes_privees TEXT;
ALTER TABLE factures ADD COLUMN IF NOT EXISTS taux_change NUMERIC;

-- Ajout devise + notes_privees sur devis
ALTER TABLE devis ADD COLUMN IF NOT EXISTS devise TEXT DEFAULT 'EUR';
ALTER TABLE devis ADD COLUMN IF NOT EXISTS notes_privees TEXT;
ALTER TABLE devis ADD COLUMN IF NOT EXISTS taux_change NUMERIC;

-- Ajout type 'debours' sur lignes (pour frais de débours)
-- Le champ 'type' existe déjà, on ajoute juste la possibilité 'debours'
-- Pas de CHECK constraint à modifier car le type est TEXT libre

-- ============================================================
-- 5. TRIGGERS updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_factures_recurrentes_updated_at
  BEFORE UPDATE ON factures_recurrentes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_temps_activites_updated_at
  BEFORE UPDATE ON temps_activites
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_rappels_updated_at
  BEFORE UPDATE ON rappels
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- 6. INDEX DE PERFORMANCE
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_factures_recurrentes_user
  ON factures_recurrentes(user_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_factures_recurrentes_next
  ON factures_recurrentes(prochaine_emission) WHERE est_active = true AND deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_temps_activites_user
  ON temps_activites(user_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_temps_activites_client
  ON temps_activites(client_id, date_activite) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_temps_activites_facturable
  ON temps_activites(user_id) WHERE est_facturable = true AND est_facture = false AND deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_rappels_user
  ON rappels(user_id) WHERE est_complete = false;
CREATE INDEX IF NOT EXISTS idx_rappels_echeance
  ON rappels(date_echeance) WHERE est_complete = false;

-- ============================================================
-- 7. AUDIT TRIGGERS (nouveaux tables)
-- ============================================================
CREATE OR REPLACE FUNCTION audit_factures_recurrentes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_logs(user_id, table_name, record_id, action, new_data)
    VALUES (NEW.user_id, 'factures_recurrentes', NEW.id, 'INSERT', to_jsonb(NEW));
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_logs(user_id, table_name, record_id, action, old_data, new_data)
    VALUES (NEW.user_id, 'factures_recurrentes', NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_logs(user_id, table_name, record_id, action, old_data)
    VALUES (OLD.user_id, 'factures_recurrentes', OLD.id, 'DELETE', to_jsonb(OLD));
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_audit_factures_recurrentes
  AFTER INSERT OR UPDATE OR DELETE ON factures_recurrentes
  FOR EACH ROW EXECUTE FUNCTION audit_factures_recurrentes();
