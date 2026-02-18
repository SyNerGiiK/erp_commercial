-- Sprint 9 : Colonnes personnalisation PDF avancée
-- Ajout couleur primaire personnalisée et logo footer

ALTER TABLE entreprises ADD COLUMN IF NOT EXISTS pdf_primary_color TEXT;
ALTER TABLE entreprises ADD COLUMN IF NOT EXISTS logo_footer_url TEXT;

COMMENT ON COLUMN entreprises.pdf_primary_color IS 'Couleur primaire hex sans # (ex: 1E5572) pour les thèmes PDF';
COMMENT ON COLUMN entreprises.logo_footer_url IS 'URL du logo footer (certification, label qualité) affiché en bas des PDF';
