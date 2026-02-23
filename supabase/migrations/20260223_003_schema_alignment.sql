-- ----------------------------------------------------------------------------
-- MIGRATION: 20260223_003_schema_alignment.sql
-- DESCRIPTION: Master alignment migration to sync DB with Dart models (Sprints 1-21)
-- ----------------------------------------------------------------------------

-- 1. EXTENSIONS & FUNCTIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Fonction updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. CREATE NEW TABLES
-- 2.1 Audit Logs (Loi anti-fraude)
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id),
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE', 'EMAIL_SENT', 'RELANCE_SENT')),
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    ip_address TEXT,
    user_agent TEXT
);
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can insert audit logs" ON public.audit_logs;
DROP POLICY IF EXISTS "Users can read own audit logs" ON public.audit_logs;
CREATE POLICY "Users can insert audit logs" ON public.audit_logs FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id OR user_id IS NULL);
CREATE POLICY "Users can read own audit logs" ON public.audit_logs FOR SELECT TO authenticated USING (auth.uid() = user_id);


-- 2.2 Factures Récurrentes
CREATE TABLE IF NOT EXISTS public.factures_recurrentes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES public.clients(id) ON DELETE CASCADE,
    objet TEXT NOT NULL,
    frequence TEXT NOT NULL DEFAULT 'mensuelle',
    prochaine_emission TIMESTAMPTZ NOT NULL,
    jour_emission INTEGER DEFAULT 1,
    est_active BOOLEAN DEFAULT true,
    total_ht NUMERIC DEFAULT 0,
    total_tva NUMERIC DEFAULT 0,
    total_ttc NUMERIC DEFAULT 0,
    remise_taux NUMERIC DEFAULT 0,
    conditions_reglement TEXT,
    notes_publiques TEXT,
    devise TEXT DEFAULT 'EUR',
    nb_factures_generees INTEGER DEFAULT 0,
    derniere_generation TIMESTAMPTZ,
    date_fin TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.factures_recurrentes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own factures_recurrentes" ON public.factures_recurrentes;
CREATE POLICY "Users manage own factures_recurrentes" ON public.factures_recurrentes FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS public.lignes_facture_recurrente (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    facture_recurrente_id UUID NOT NULL REFERENCES public.factures_recurrentes(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    quantite NUMERIC DEFAULT 1,
    prix_unitaire NUMERIC DEFAULT 0,
    total_ligne NUMERIC DEFAULT 0,
    type_activite TEXT DEFAULT 'service',
    unite TEXT DEFAULT 'u',
    taux_tva NUMERIC DEFAULT 20.0,
    ordre INTEGER DEFAULT 0
);
ALTER TABLE public.lignes_facture_recurrente ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own lignes_facture_recurrente" ON public.lignes_facture_recurrente;
-- Policy using subquery since we don't have user_id directly on the line
CREATE POLICY "Users manage own lignes_facture_recurrente" ON public.lignes_facture_recurrente FOR ALL TO authenticated 
USING (facture_recurrente_id IN (SELECT id FROM public.factures_recurrentes WHERE user_id = auth.uid()))
WITH CHECK (facture_recurrente_id IN (SELECT id FROM public.factures_recurrentes WHERE user_id = auth.uid()));


-- 2.3 Suivi du Temps (Temps Activites)
CREATE TABLE IF NOT EXISTS public.temps_activites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    client_id UUID REFERENCES public.clients(id) ON DELETE SET NULL,
    projet_devis_id UUID REFERENCES public.devis(id) ON DELETE SET NULL,
    titre TEXT NOT NULL,
    description TEXT,
    duree_minutes INTEGER NOT NULL DEFAULT 0,
    date_activite TIMESTAMPTZ NOT NULL,
    est_facturable BOOLEAN DEFAULT true,
    taux_horaire_applique NUMERIC,
    categorie TEXT DEFAULT 'dev',
    facture_associee_id UUID REFERENCES public.factures(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.temps_activites ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own temps_activites" ON public.temps_activites;
CREATE POLICY "Users manage own temps_activites" ON public.temps_activites FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);


-- 2.4 Rappels / Échéances
CREATE TABLE IF NOT EXISTS public.rappels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    titre TEXT NOT NULL,
    description TEXT,
    date_echeance TIMESTAMPTZ NOT NULL,
    type_rappel TEXT DEFAULT 'custom',
    priorite TEXT DEFAULT 'medium',
    est_termine BOOLEAN DEFAULT false,
    lien_document_id UUID,
    lien_type_document TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.rappels ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users manage own rappels" ON public.rappels;
CREATE POLICY "Users manage own rappels" ON public.rappels FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);



-- 3. ALTER EXISTING TABLES
-- 3.1 Entreprises
ALTER TABLE public.entreprises 
    ADD COLUMN IF NOT EXISTS type_entreprise TEXT DEFAULT 'microEntrepreneur',
    ADD COLUMN IF NOT EXISTS regime_fiscal TEXT,
    ADD COLUMN IF NOT EXISTS caisse_retraite TEXT DEFAULT 'ssi',
    ADD COLUMN IF NOT EXISTS tva_applicable BOOLEAN DEFAULT false,
    ADD COLUMN IF NOT EXISTS numero_tva_intra TEXT,
    ADD COLUMN IF NOT EXISTS pdf_theme TEXT DEFAULT 'moderne',
    ADD COLUMN IF NOT EXISTS pdf_primary_color TEXT,
    ADD COLUMN IF NOT EXISTS logo_footer_url TEXT,
    ADD COLUMN IF NOT EXISTS mode_facturation TEXT DEFAULT 'global',
    ADD COLUMN IF NOT EXISTS mode_discret BOOLEAN DEFAULT false,
    ADD COLUMN IF NOT EXISTS taux_penalites_retard NUMERIC DEFAULT 11.62,
    ADD COLUMN IF NOT EXISTS escompte_applicable BOOLEAN DEFAULT false,
    ADD COLUMN IF NOT EXISTS est_immatricule BOOLEAN DEFAULT false,
    ADD COLUMN IF NOT EXISTS logo_url TEXT,
    ADD COLUMN IF NOT EXISTS signature_url TEXT;

-- 3.2 Urssaf Configs
ALTER TABLE public.urssaf_configs
    ADD COLUMN IF NOT EXISTS accre_annee INTEGER DEFAULT 1,
    ADD COLUMN IF NOT EXISTS statut TEXT DEFAULT 'artisan',
    ADD COLUMN IF NOT EXISTS type_activite TEXT DEFAULT 'mixte',
    ADD COLUMN IF NOT EXISTS versement_liberatoire BOOLEAN DEFAULT false,
    ADD COLUMN IF NOT EXISTS taux_micro_vente NUMERIC DEFAULT 12.3,
    ADD COLUMN IF NOT EXISTS taux_micro_prestation_bic NUMERIC DEFAULT 21.2,
    ADD COLUMN IF NOT EXISTS taux_micro_prestation_bnc NUMERIC DEFAULT 25.6,
    ADD COLUMN IF NOT EXISTS taux_cfp_liberal NUMERIC DEFAULT 0.2,
    ADD COLUMN IF NOT EXISTS plafond_vl_rfr NUMERIC DEFAULT 29315,
    ADD COLUMN IF NOT EXISTS last_synced_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS source_api BOOLEAN DEFAULT false,
    ADD COLUMN IF NOT EXISTS plafond_ca_micro_vente NUMERIC DEFAULT 188700,
    ADD COLUMN IF NOT EXISTS plafond_ca_micro_service NUMERIC DEFAULT 77700,
    ADD COLUMN IF NOT EXISTS seuil_tva_micro_vente NUMERIC DEFAULT 91900,
    ADD COLUMN IF NOT EXISTS seuil_tva_micro_vente_maj NUMERIC DEFAULT 101000,
    ADD COLUMN IF NOT EXISTS seuil_tva_micro_service NUMERIC DEFAULT 36800,
    ADD COLUMN IF NOT EXISTS seuil_tva_micro_service_maj NUMERIC DEFAULT 39100;

-- 3.3 Factures
ALTER TABLE public.factures
    ADD COLUMN IF NOT EXISTS facture_source_id UUID REFERENCES public.factures(id),
    ADD COLUMN IF NOT EXISTS parent_document_id UUID REFERENCES public.factures(id),
    ADD COLUMN IF NOT EXISTS type_document TEXT DEFAULT 'facture',
    ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'standard',
    ADD COLUMN IF NOT EXISTS avancement_global NUMERIC,
    ADD COLUMN IF NOT EXISTS signature_url TEXT,
    ADD COLUMN IF NOT EXISTS date_signature TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS total_tva NUMERIC DEFAULT 0,
    ADD COLUMN IF NOT EXISTS total_ttc NUMERIC DEFAULT 0,
    ADD COLUMN IF NOT EXISTS numero_bon_commande TEXT,
    ADD COLUMN IF NOT EXISTS motif_avoir TEXT,
    ADD COLUMN IF NOT EXISTS devise TEXT DEFAULT 'EUR',
    ADD COLUMN IF NOT EXISTS taux_change NUMERIC DEFAULT 1.0,
    ADD COLUMN IF NOT EXISTS notes_privees TEXT,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 3.4 Devis
ALTER TABLE public.devis
    ADD COLUMN IF NOT EXISTS type_chiffrage TEXT DEFAULT 'standard',
    ADD COLUMN IF NOT EXISTS avancement_global NUMERIC,
    ADD COLUMN IF NOT EXISTS total_tva NUMERIC DEFAULT 0,
    ADD COLUMN IF NOT EXISTS total_ttc NUMERIC DEFAULT 0,
    ADD COLUMN IF NOT EXISTS devise TEXT DEFAULT 'EUR',
    ADD COLUMN IF NOT EXISTS taux_change NUMERIC DEFAULT 1.0,
    ADD COLUMN IF NOT EXISTS notes_privees TEXT,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 3.5 Lignes Factures & Devis
ALTER TABLE public.lignes_factures
    ADD COLUMN IF NOT EXISTS taux_tva NUMERIC DEFAULT 20.0,
    ADD COLUMN IF NOT EXISTS avancement NUMERIC DEFAULT 100.0;

ALTER TABLE public.lignes_devis
    ADD COLUMN IF NOT EXISTS taux_tva NUMERIC DEFAULT 20.0;

-- 3.6 Lignes Chiffrages
ALTER TABLE public.lignes_chiffrages
    ADD COLUMN IF NOT EXISTS linked_ligne_devis_id UUID REFERENCES public.lignes_devis(id),
    ADD COLUMN IF NOT EXISTS type_chiffrage TEXT,
    ADD COLUMN IF NOT EXISTS est_achete BOOLEAN DEFAULT false,
    ADD COLUMN IF NOT EXISTS avancement_mo NUMERIC DEFAULT 0,
    ADD COLUMN IF NOT EXISTS prix_vente_interne NUMERIC DEFAULT 0,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 3.7 Add updated_at to remaining
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.depenses ADD COLUMN IF NOT EXISTS chantier_devis_id UUID REFERENCES public.devis(id) ON DELETE SET NULL;
ALTER TABLE public.depenses ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.paiements ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 4. APPLY UPDATED_AT TRIGGERS
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_factures_updated_at') THEN
        CREATE TRIGGER trg_factures_updated_at BEFORE UPDATE ON public.factures FOR EACH ROW EXECUTE FUNCTION set_updated_at();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_devis_updated_at') THEN
        CREATE TRIGGER trg_devis_updated_at BEFORE UPDATE ON public.devis FOR EACH ROW EXECUTE FUNCTION set_updated_at();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_clients_updated_at') THEN
        CREATE TRIGGER trg_clients_updated_at BEFORE UPDATE ON public.clients FOR EACH ROW EXECUTE FUNCTION set_updated_at();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_depenses_updated_at') THEN
        CREATE TRIGGER trg_depenses_updated_at BEFORE UPDATE ON public.depenses FOR EACH ROW EXECUTE FUNCTION set_updated_at();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_paiements_updated_at') THEN
        CREATE TRIGGER trg_paiements_updated_at BEFORE UPDATE ON public.paiements FOR EACH ROW EXECUTE FUNCTION set_updated_at();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_factures_recurrentes_updated_at') THEN
        CREATE TRIGGER trg_factures_recurrentes_updated_at BEFORE UPDATE ON public.factures_recurrentes FOR EACH ROW EXECUTE FUNCTION set_updated_at();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_temps_activites_updated_at') THEN
        CREATE TRIGGER trg_temps_activites_updated_at BEFORE UPDATE ON public.temps_activites FOR EACH ROW EXECUTE FUNCTION set_updated_at();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_rappels_updated_at') THEN
        CREATE TRIGGER trg_rappels_updated_at BEFORE UPDATE ON public.rappels FOR EACH ROW EXECUTE FUNCTION set_updated_at();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_lignes_chiffrages_updated_at') THEN
        CREATE TRIGGER trg_lignes_chiffrages_updated_at BEFORE UPDATE ON public.lignes_chiffrages FOR EACH ROW EXECUTE FUNCTION set_updated_at();
    END IF;
END
$$;
