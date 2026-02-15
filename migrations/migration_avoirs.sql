-- MIGRATION PHASE 21 : GESTION DES AVOIRS
-- Auteur: Assistant IA
-- Date: 2026-02-15

-- 1. Table FACTURES
-- Ajout de la colonne pour lier un avoir à sa facture d'origine
ALTER TABLE public.factures 
ADD COLUMN IF NOT EXISTS facture_source_id UUID REFERENCES public.factures(id);

-- Ajout d'un commentaire explicatif
COMMENT ON COLUMN public.factures.facture_source_id IS 'Pour un AVOIR : Référence vers la facture annulée ou remboursée.';

-- Note: Le champ 'type' existe déjà (standard, acompte, solde).
-- Nous utiliserons la valeur 'avoir' pour ce champ.
-- Assurez-vous que votre contrainte de validation sur 'type' (si elle existe) autorise 'avoir'.
-- Exemple de modification de contrainte (si nécessaire) :
-- ALTER TABLE public.factures DROP CONSTRAINT IF EXISTS factures_type_check;
-- ALTER TABLE public.factures ADD CONSTRAINT factures_type_check CHECK (type IN ('standard', 'acompte', 'solde', 'situation', 'avoir'));
