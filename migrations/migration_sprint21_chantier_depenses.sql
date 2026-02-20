-- Sprint 21: Liaison Dépenses <-> Chantiers (Cockpit Rentabilité)
-- Objectif: rattacher une dépense à un chantier/devis pour calculer la marge réelle.

ALTER TABLE depenses
ADD COLUMN IF NOT EXISTS chantier_devis_id UUID REFERENCES devis(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_depenses_chantier_devis_id
ON depenses(chantier_devis_id)
WHERE chantier_devis_id IS NOT NULL;

-- Migration de données legacy: si une ancienne colonne devis_id existe,
-- on recopie ses valeurs vers chantier_devis_id.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'depenses'
      AND column_name = 'devis_id'
  ) THEN
    EXECUTE '
      UPDATE depenses
      SET chantier_devis_id = devis_id
      WHERE chantier_devis_id IS NULL
        AND devis_id IS NOT NULL
    ';
  END IF;
END $$;

COMMENT ON COLUMN depenses.chantier_devis_id IS
'Liaison optionnelle vers le devis/chantier pour le calcul de marge réelle dans le cockpit rentabilité.';
