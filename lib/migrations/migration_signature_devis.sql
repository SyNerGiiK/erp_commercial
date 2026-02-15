-- Ajout des colonnes de signature pour les devis
ALTER TABLE devis ADD COLUMN signature_url text;
ALTER TABLE devis ADD COLUMN date_signature timestamp with time zone;
