-- ================================================================================
-- MIGRATION CORRECTIVE - BUGS DEVIS & FACTURES
-- Date: 2026-02-17
-- Description: Correction des 5 bugs critiques identifiés
-- ================================================================================

-- ============================================================================
-- BUG #2 : Suppression fonction dupliquée get_next_document_number
-- ============================================================================

-- Supprimer l'ancienne version qui utilise LIKE (non atomique)
DROP FUNCTION IF EXISTS get_next_document_number(text, uuid, integer);

-- La version stricte (get_next_document_number_strict) est conservée
-- Elle utilise UPDATE atomique sur compteurs_documents


-- ============================================================================
-- BUG #3 : Normalisation numérotation (3 chiffres → 4 chiffres)
-- ============================================================================

-- Mettre tous les numéros de devis au format 4 chiffres
UPDATE devis 
SET numero_devis = CASE
    WHEN numero_devis ~ '-\d{3}$' THEN 
        SUBSTRING(numero_devis FROM '^[^-]+-\d{4}-') || '0' || SUBSTRING(numero_devis FROM '\d{3}$')
    ELSE numero_devis
END
WHERE numero_devis ~ '-\d{3}$' AND numero_devis !~ '-\d{4}$';

-- Exemple: D-2026-002 devient D-2026-0002


-- ============================================================================
-- BUG #4 : Protection suppression/modification devis validés
-- ============================================================================

CREATE OR REPLACE FUNCTION prevent_devis_modification()
RETURNS TRIGGER AS $$
BEGIN
    -- Empêcher modification ou suppression des devis non-brouillon
    IF OLD.statut NOT IN ('brouillon') AND (TG_OP = 'UPDATE' OR TG_OP = 'DELETE') THEN
        RAISE EXCEPTION 'Impossible de modifier ou supprimer un devis validé/envoyé (statut: %)', OLD.statut;
    END IF;
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer le trigger
DROP TRIGGER IF EXISTS trig_prevent_devis_mod ON devis;
CREATE TRIGGER trig_prevent_devis_mod
BEFORE UPDATE OR DELETE ON devis
FOR EACH ROW EXECUTE FUNCTION prevent_devis_modification();


-- ============================================================================
-- BUG #5 : Harmonisation statut/statut_juridique dans trigger factures
-- ============================================================================

CREATE OR REPLACE FUNCTION prevent_facture_modification()
RETURNS TRIGGER AS $$
BEGIN
    -- Vérifier BOTH statut ET statut_juridique pour plus de sécurité
    IF (OLD.statut_juridique NOT IN ('brouillon') OR OLD.statut NOT IN ('brouillon', 'validee', 'envoye')) 
       AND (TG_OP = 'UPDATE' OR TG_OP = 'DELETE') THEN
        RAISE EXCEPTION 'Impossible de modifier une facture validée (statut: %, statut_juridique: %)', 
                        OLD.statut, OLD.statut_juridique;
    END IF;
    
    -- Permettre suppression UNIQUEMENT si brouillon
    IF TG_OP = 'DELETE' AND OLD.statut_juridique != 'brouillon' THEN
        RAISE EXCEPTION 'Impossible de supprimer une facture validée';
    END IF;
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recréer le trigger avec la nouvelle fonction
DROP TRIGGER IF EXISTS trig_prevent_facture_mod ON factures;
CREATE TRIGGER trig_prevent_facture_mod
BEFORE UPDATE OR DELETE ON factures
FOR EACH ROW EXECUTE FUNCTION prevent_facture_modification();


-- ============================================================================
-- RECOMMANDATIONS : Contraintes UNIQUE sur numérotation
-- ============================================================================

-- Index unique pour éviter les doublons de numéros de devis
CREATE UNIQUE INDEX IF NOT EXISTS idx_devis_numero_unique 
ON devis(user_id, numero_devis) 
WHERE numero_devis IS NOT NULL 
  AND numero_devis != '' 
  AND numero_devis != 'brouillon';

-- Index unique pour éviter les doublons de numéros de factures
CREATE UNIQUE INDEX IF NOT EXISTS idx_factures_numero_unique 
ON factures(user_id, numero_facture) 
WHERE numero_facture IS NOT NULL 
  AND numero_facture != '' 
  AND numero_facture != 'brouillon';


-- ============================================================================
-- RECOMMANDATIONS : Contraintes sur montants
-- ============================================================================

-- S'assurer que les montants de paiements sont positifs
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'chk_paiement_montant_positif'
    ) THEN
        ALTER TABLE paiements 
        ADD CONSTRAINT chk_paiement_montant_positif CHECK (montant > 0);
    END IF;
END $$;

-- S'assurer que les montants HT sont positifs ou nuls
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'chk_facture_total_ht_positif'
    ) THEN
        ALTER TABLE factures 
        ADD CONSTRAINT chk_facture_total_ht_positif CHECK (total_ht >= 0);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'chk_devis_total_ht_positif'
    ) THEN
        ALTER TABLE devis 
        ADD CONSTRAINT chk_devis_total_ht_positif CHECK (total_ht >= 0);
    END IF;
END $$;


-- ============================================================================
-- FIN DE LA MIGRATION
-- ============================================================================

-- Vérification finale
SELECT 
    'Migration terminée avec succès !' as message,
    (SELECT COUNT(*) FROM devis WHERE numero_devis ~ '-\d{3}$') as devis_3_chiffres_restants,
    (SELECT COUNT(*) FROM devis WHERE numero_devis ~ '-\d{4}$') as devis_4_chiffres
;
