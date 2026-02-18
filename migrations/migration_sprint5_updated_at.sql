-- ============================================================
-- Migration Sprint 5 : Ajout updated_at + trigger auto-update
-- Date : 2026-02-18
-- ============================================================

-- 1. Fonction générique pour auto-mettre à jour updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- 2. Ajout colonne updated_at sur les tables principales
-- (DEFAULT = created_at pour les lignes existantes, puis NOW() pour les nouvelles)
ALTER TABLE public.factures
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE public.devis
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE public.paiements
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE public.clients
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE public.depenses
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 3. Initialiser updated_at = created_at pour les lignes existantes
-- NOTE : Désactiver les triggers d'immutabilité avant le backfill
ALTER TABLE public.factures DISABLE TRIGGER trig_prevent_facture_mod;
ALTER TABLE public.factures DISABLE TRIGGER trg_protect_validated_facture;
ALTER TABLE public.devis DISABLE TRIGGER trig_prevent_devis_mod;

UPDATE public.factures SET updated_at = created_at;
UPDATE public.devis SET updated_at = created_at;
UPDATE public.paiements SET updated_at = created_at;
UPDATE public.clients SET updated_at = created_at;
UPDATE public.depenses SET updated_at = created_at;

ALTER TABLE public.factures ENABLE TRIGGER trig_prevent_facture_mod;
ALTER TABLE public.factures ENABLE TRIGGER trg_protect_validated_facture;
ALTER TABLE public.devis ENABLE TRIGGER trig_prevent_devis_mod;

-- 4. Triggers BEFORE UPDATE pour auto-set updated_at
CREATE OR REPLACE TRIGGER trg_factures_updated_at
  BEFORE UPDATE ON public.factures
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE TRIGGER trg_devis_updated_at
  BEFORE UPDATE ON public.devis
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE TRIGGER trg_paiements_updated_at
  BEFORE UPDATE ON public.paiements
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE TRIGGER trg_clients_updated_at
  BEFORE UPDATE ON public.clients
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE TRIGGER trg_depenses_updated_at
  BEFORE UPDATE ON public.depenses
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();
