-- =============================================================================
-- Migration Sprint 15: Smart Progress Billing & Profitability Tracker
-- Date: 2026-02-19
-- Description:
--   Évolution du modèle lignes_chiffrages pour supporter le suivi d'avancement
--   par type (Matériel vs Main d'œuvre) et le lien avec les lignes du devis.
--   Permet le calcul automatique de l'avancement des lignes publiques du devis
--   à partir de l'état interne des coûts (mode Global).
-- =============================================================================

-- 1. Ajout des nouvelles colonnes sur lignes_chiffrages
ALTER TABLE lignes_chiffrages
  ADD COLUMN IF NOT EXISTS linked_ligne_devis_id UUID REFERENCES lignes_devis(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS type_chiffrage TEXT NOT NULL DEFAULT 'materiel'
    CHECK (type_chiffrage IN ('materiel', 'main_doeuvre')),
  ADD COLUMN IF NOT EXISTS est_achete BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS avancement_mo NUMERIC NOT NULL DEFAULT 0
    CHECK (avancement_mo >= 0 AND avancement_mo <= 100),
  ADD COLUMN IF NOT EXISTS prix_vente_interne NUMERIC NOT NULL DEFAULT 0;

-- 2. Index pour les requêtes de jointure fréquentes
CREATE INDEX IF NOT EXISTS idx_lignes_chiffrages_linked_ligne_devis
  ON lignes_chiffrages(linked_ligne_devis_id)
  WHERE linked_ligne_devis_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_lignes_chiffrages_devis_id
  ON lignes_chiffrages(devis_id)
  WHERE devis_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_lignes_chiffrages_type
  ON lignes_chiffrages(type_chiffrage);

-- 3. Trigger updated_at sur lignes_chiffrages (si pas déjà existant)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'lignes_chiffrages' AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE lignes_chiffrages
      ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
  END IF;
END $$;

CREATE OR REPLACE FUNCTION update_lignes_chiffrages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_lignes_chiffrages_updated_at ON lignes_chiffrages;
CREATE TRIGGER trg_lignes_chiffrages_updated_at
  BEFORE UPDATE ON lignes_chiffrages
  FOR EACH ROW
  EXECUTE FUNCTION update_lignes_chiffrages_updated_at();

-- 4. RLS policy pour lignes_chiffrages (si pas déjà existante)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'lignes_chiffrages' AND policyname = 'lignes_chiffrages_user_policy'
  ) THEN
    ALTER TABLE lignes_chiffrages ENABLE ROW LEVEL SECURITY;
    CREATE POLICY lignes_chiffrages_user_policy ON lignes_chiffrages
      FOR ALL
      USING (user_id = auth.uid())
      WITH CHECK (user_id = auth.uid());
  END IF;
END $$;

-- 5. Commentaires de documentation
COMMENT ON COLUMN lignes_chiffrages.linked_ligne_devis_id IS
  'FK vers la ligne publique du devis. Permet de regrouper les coûts internes par ligne publique pour le calcul d''avancement en mode Global.';
COMMENT ON COLUMN lignes_chiffrages.type_chiffrage IS
  'Type de coût : materiel (fournitures, achats) ou main_doeuvre (travail, pose). Détermine le mode de suivi d''avancement.';
COMMENT ON COLUMN lignes_chiffrages.est_achete IS
  'Pour type materiel : indique si le matériel a été réceptionné/acheté. Binaire : 0% ou 100%.';
COMMENT ON COLUMN lignes_chiffrages.avancement_mo IS
  'Pour type main_doeuvre : pourcentage d''avancement du travail (0 à 100). Slider progressif.';
COMMENT ON COLUMN lignes_chiffrages.prix_vente_interne IS
  'Part du prix de vente public allouée à ce coût interne. Sert au calcul de la Valeur Réalisée pour l''avancement de la ligne publique parente.';
