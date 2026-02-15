-- ==============================================================================
-- MIGRATION NUMÉROTATION STRICTE (ANTI-FRAUDE & SANS TROUS)
-- Date : 2026-02-15
-- Description : Remplace les Séquences PostgreSQL et les RPC manuelles par 
--               une gestion centralisée via Triggers + Table Compteurs.
-- ==============================================================================

-- 1. FONCTION DE GÉNÉRATION STRICTE (Atomicité garantie)
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.get_next_document_number_strict(
    p_user_id uuid,
    p_type_doc text,
    p_annee integer
)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER -- Exécuté avec les droits du créateur (pour accès table compteurs)
AS $$
DECLARE
    v_next_val int;
    v_prefix text;
    v_formatted_number text;
BEGIN
    -- Définition des préfixes
    IF p_type_doc = 'facture' THEN
        v_prefix := 'F';
    ELSIF p_type_doc = 'devis' THEN
        v_prefix := 'D';
    ELSIF p_type_doc = 'avoir' THEN
        v_prefix := 'AV';
    ELSIF p_type_doc = 'acompte' THEN
        v_prefix := 'FA';
    ELSE
        RAISE EXCEPTION 'Type de document invalide: %', p_type_doc;
    END IF;

    -- Mise à jour atomique du compteur (Verrouillage ligne)
    UPDATE public.compteurs_documents
    SET valeur_actuelle = valeur_actuelle + 1
    WHERE user_id = p_user_id 
      AND annee = p_annee 
      AND type_document = p_type_doc
    RETURNING valeur_actuelle INTO v_next_val;

    -- Si aucun compteur n'existe, on le crée
    IF v_next_val IS NULL THEN
        v_next_val := 1;
        INSERT INTO public.compteurs_documents (user_id, annee, type_document, valeur_actuelle)
        VALUES (p_user_id, p_annee, p_type_doc, v_next_val);
    END IF;

    -- Formatage : PREFIXE-ANNEE-0001 (4 chiffres)
    -- Ex: F-2026-0001, D-2026-0042
    v_formatted_number := v_prefix || '-' || p_annee || '-' || LPAD(v_next_val::text, 4, '0');

    RETURN v_formatted_number;
END;
$$;

-- 2. MISE À JOUR TRIGGER FACTURE
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.generate_facture_number()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    year_int integer;
    new_number text;
    doc_type text;
BEGIN
    -- Uniquement si statut passe à 'validee' ou 'payee' ET pas de numéro
    IF (NEW.statut_juridique IN ('validee', 'payee')) 
       AND (OLD.statut_juridique != 'validee' AND OLD.statut_juridique != 'payee' OR OLD.statut_juridique IS NULL) 
       AND (NEW.numero_facture IS NULL OR NEW.numero_facture = '') THEN
        
        year_int := CAST(to_char(now(), 'YYYY') AS INTEGER);
        
        -- Détermination du type (Facture ou Avoir)
        IF NEW.type = 'avoir' THEN
            doc_type := 'avoir';
        ELSIF NEW.type = 'acompte' THEN
             doc_type := 'acompte'; -- Optionnel, sinon laisser en facture
        ELSE
            doc_type := 'facture';
        END IF;
        
        -- Appel de la fonction stricte
        new_number := public.get_next_document_number_strict(NEW.user_id, doc_type, year_int);
        
        NEW.numero_facture := new_number;
        NEW.date_validation := now(); -- Fige la date de validation
    END IF;
    RETURN NEW;
END;
$$;

-- Note : Le trigger 'trg_generate_facture_number' existe déjà et appelle cette fonction.
-- Pas besoin de le recréer s'il pointe vers generate_facture_number().

-- 3. MISE À JOUR TRIGGER DEVIS
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.generate_devis_number()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    year_int integer;
    new_number text;
BEGIN
    -- Uniquement si statut passe à 'envoye' ou 'signe' ET pas de numéro
    IF (NEW.statut IN ('envoye', 'signe')) 
       AND (OLD.statut != 'envoye' AND OLD.statut != 'signe' OR OLD.statut IS NULL) 
       AND (NEW.numero_devis IS NULL OR NEW.numero_devis = '') THEN
        
        year_int := CAST(to_char(now(), 'YYYY') AS INTEGER);
        
        -- Appel de la fonction stricte
        new_number := public.get_next_document_number_strict(NEW.user_id, 'devis', year_int);
        
        NEW.numero_devis := new_number;
    END IF;
    RETURN NEW;
END;
$$;
