-- ==============================================================================
-- HARDENING INTEGRITY (SÉCURITÉ DES DONNÉES)
-- Date : 2026-02-16
-- Description : Ajout de contraintes CHECK pour garantir la validité des données.
-- ==============================================================================

-- 1. CLIENTS
-- ==============================================================================
ALTER TABLE public.clients DROP CONSTRAINT IF EXISTS clients_nom_complet_check;
ALTER TABLE public.clients ADD CONSTRAINT clients_nom_complet_check CHECK (char_length(trim(nom_complet)) > 0);

ALTER TABLE public.clients DROP CONSTRAINT IF EXISTS clients_email_check;
ALTER TABLE public.clients ADD CONSTRAINT clients_email_check CHECK (email IS NULL OR email = '' OR email ~* '^.+@.+\..+$');

-- 2. ARTICLES
-- ==============================================================================
ALTER TABLE public.articles DROP CONSTRAINT IF EXISTS articles_designation_check;
ALTER TABLE public.articles ADD CONSTRAINT articles_designation_check CHECK (char_length(trim(designation)) > 0);

ALTER TABLE public.articles DROP CONSTRAINT IF EXISTS articles_prix_check;
-- Prix unitaire peut être 0 (cadeau) mais pas négatif (catalogue).
ALTER TABLE public.articles ADD CONSTRAINT articles_prix_check CHECK (prix_unitaire >= 0 AND prix_achat >= 0);

-- 3. FACTURES & DEVIS
-- ==============================================================================
ALTER TABLE public.factures DROP CONSTRAINT IF EXISTS factures_total_check;
-- Le montant facial d'une facture ou d'un avoir est toujours positif.
ALTER TABLE public.factures ADD CONSTRAINT factures_total_check CHECK (total_ttc >= 0 AND total_ht >= 0);

ALTER TABLE public.devis DROP CONSTRAINT IF EXISTS devis_total_check;
ALTER TABLE public.devis ADD CONSTRAINT devis_total_check CHECK (total_ttc >= 0 AND total_ht >= 0);

-- 4. LIGNES (Factures & Devis)
-- ==============================================================================
ALTER TABLE public.lignes_factures DROP CONSTRAINT IF EXISTS lignes_factures_qte_check;
-- Quantité peut être négative (retour) mais jamais NULLE, SAUF pour le formatage (titre, etc.)
ALTER TABLE public.lignes_factures ADD CONSTRAINT lignes_factures_qte_check 
CHECK ( 
    (type IN ('titre', 'sous-titre', 'texte', 'saut_page')) 
    OR 
    (quantite <> 0) 
);

ALTER TABLE public.lignes_devis DROP CONSTRAINT IF EXISTS lignes_devis_qte_check;
ALTER TABLE public.lignes_devis ADD CONSTRAINT lignes_devis_qte_check 
CHECK ( 
    (type IN ('titre', 'sous-titre', 'texte', 'saut_page')) 
    OR 
    (quantite <> 0) 
);

-- 5. PAIEMENTS
-- ==============================================================================
ALTER TABLE public.paiements DROP CONSTRAINT IF EXISTS paiements_montant_check;
-- Un paiement ne sert à rien s'il est de 0.
ALTER TABLE public.paiements ADD CONSTRAINT paiements_montant_check CHECK (montant <> 0);
