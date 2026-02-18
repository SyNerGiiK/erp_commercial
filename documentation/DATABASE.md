# Base de données — ERP Artisan

> Documentation complète du schéma Supabase (PostgreSQL 15+) — Dernière mise à jour : 18/02/2026

---

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Schéma des tables](#schéma-des-tables)
3. [Tables détaillées](#tables-détaillées)
4. [Relations (Foreign Keys)](#relations-foreign-keys)
5. [Triggers](#triggers)
6. [Row Level Security (RLS)](#row-level-security-rls)
7. [Index](#index)
8. [Historique des migrations](#historique-des-migrations)

---

## Vue d'ensemble

Le schéma utilise **Supabase** (PostgreSQL 15+) avec :

- **RLS activé** sur toutes les tables — chaque utilisateur ne voit que ses propres données
- **Triggers d'audit** automatiques sur factures, devis, paiements (loi anti-fraude 2018)
- **Trigger d'immutabilité** bloquant la modification des factures validées
- **Triggers updated_at** sur toutes les tables principales
- **UUIDs** comme clés primaires (`gen_random_uuid()`)
- **TIMESTAMPTZ** pour toutes les dates

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   clients    │────<│   factures   │────<│  paiements   │
└──────────────┘     └──────────────┘     └──────────────┘
                           │ 1:N
                     ┌─────┴──────┐
                     │lignes_facture│
                     └────────────┘

┌──────────────┐     ┌──────────────┐
│   clients    │────<│    devis     │
└──────────────┘     └──────────────┘
                           │ 1:N
                     ┌─────┴──────┐
                     │ lignes_devis │
                     └────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  entreprises │     │  audit_logs  │     │   depenses   │
└──────────────┘     └──────────────┘     └──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   articles   │     │  cotisations │     │    events    │
└──────────────┘     └──────────────┘     └──────────────┘
```

---

## Schéma des tables

| Table | Description | RLS | Audit | updated_at |
|---|---|---|---|---|
| `clients` | Clients (particuliers et professionnels) | ✅ | ❌ | ✅ |
| `factures` | Factures et avoirs | ✅ | ✅ | ✅ |
| `lignes_facture` | Lignes de facture | ✅ | ❌ | ❌ |
| `paiements` | Paiements sur factures | ✅ | ✅ | ✅ |
| `devis` | Devis commerciaux | ✅ | ✅ | ✅ |
| `lignes_devis` | Lignes de devis | ✅ | ❌ | ❌ |
| `entreprises` | Profil entreprise (1 par user) | ✅ | ❌ | ❌ |
| `depenses` | Dépenses comptables | ✅ | ❌ | ✅ |
| `articles` | Bibliothèque de prix | ✅ | ❌ | ❌ |
| `cotisations` | Cotisations URSSAF | ✅ | ❌ | ❌ |
| `audit_logs` | Piste d'audit (loi anti-fraude) | ✅ | — | ❌ |
| `events` | Planning / calendrier | ✅ | ❌ | ❌ |
| `shopping_items` | Liste courses / matériaux | ✅ | ❌ | ❌ |

---

## Tables détaillées

### clients

| Colonne | Type | Nullable | Défaut | Description |
|---|---|---|---|---|
| `id` | `UUID` | NOT NULL | `gen_random_uuid()` | PK |
| `user_id` | `UUID` | NOT NULL | — | FK → auth.users |
| `nom_complet` | `TEXT` | NOT NULL | — | Raison sociale ou nom |
| `type_client` | `TEXT` | NOT NULL | `'particulier'` | `'particulier'` ou `'professionnel'` |
| `nom_contact` | `TEXT` | NULL | — | Contact principal (si pro) |
| `siret` | `TEXT` | NULL | — | SIRET (14 chiffres) |
| `tva_intra` | `TEXT` | NULL | — | N° TVA intracommunautaire |
| `adresse` | `TEXT` | NOT NULL | — | Adresse postale |
| `code_postal` | `TEXT` | NOT NULL | — | Code postal |
| `ville` | `TEXT` | NOT NULL | — | Ville |
| `telephone` | `TEXT` | NOT NULL | — | Téléphone |
| `email` | `TEXT` | NOT NULL | — | Email |
| `notes_privees` | `TEXT` | NULL | — | Notes internes |
| `created_at` | `TIMESTAMPTZ` | NOT NULL | `now()` | Date de création |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL | `now()` | Dernière mise à jour |

### factures

| Colonne | Type | Nullable | Défaut | Description |
|---|---|---|---|---|
| `id` | `UUID` | NOT NULL | `gen_random_uuid()` | PK |
| `user_id` | `UUID` | NOT NULL | — | FK → auth.users |
| `numero_facture` | `TEXT` | NOT NULL | — | FA-YYYY-NNNN (trigger SQL) |
| `objet` | `TEXT` | NOT NULL | — | Objet de la facture |
| `client_id` | `UUID` | NOT NULL | — | FK → clients.id |
| `devis_source_id` | `UUID` | NULL | — | FK → devis.id (si transformation) |
| `facture_source_id` | `UUID` | NULL | — | FK → factures.id (pour avoir) |
| `parent_document_id` | `UUID` | NULL | — | Lien parent (avoir → facture) |
| `type_document` | `TEXT` | NOT NULL | `'facture'` | `'facture'` ou `'avoir'` |
| `date_emission` | `TIMESTAMPTZ` | NOT NULL | — | Date d'émission |
| `date_echeance` | `TIMESTAMPTZ` | NOT NULL | — | Date d'échéance |
| `date_validation` | `TIMESTAMPTZ` | NULL | — | Date de validation |
| `statut` | `TEXT` | NOT NULL | `'brouillon'` | Statut workflow |
| `statut_juridique` | `TEXT` | NOT NULL | `'brouillon'` | Protégé par trigger immutabilité |
| `est_archive` | `BOOLEAN` | NOT NULL | `false` | Archivée |
| `type` | `TEXT` | NOT NULL | `'standard'` | standard, acompte, situation, solde |
| `avancement_global` | `NUMERIC` | NULL | — | % avancement (situation) |
| `signature_url` | `TEXT` | NULL | — | URL signature Storage |
| `date_signature` | `TIMESTAMPTZ` | NULL | — | Date de signature |
| `total_ht` | `NUMERIC` | NOT NULL | `0` | Total HT |
| `total_tva` | `NUMERIC` | NOT NULL | `0` | Total TVA |
| `total_ttc` | `NUMERIC` | NOT NULL | `0` | Total TTC |
| `remise_taux` | `NUMERIC` | NOT NULL | `0` | Taux de remise (%) |
| `acompte_deja_regle` | `NUMERIC` | NOT NULL | `0` | Acompte déjà réglé |
| `conditions_reglement` | `TEXT` | NOT NULL | — | Conditions de règlement |
| `notes_publiques` | `TEXT` | NULL | — | Notes visibles sur le PDF |
| `tva_intra` | `TEXT` | NULL | — | N° TVA |
| `numero_bon_commande` | `TEXT` | NULL | — | Référence bon de commande |
| `motif_avoir` | `TEXT` | NULL | — | Motif de l'avoir |
| `taux_penalites_retard` | `NUMERIC(5,2)` | NOT NULL | `11.62` | Taux pénalités retard |
| `escompte_applicable` | `BOOLEAN` | NOT NULL | `false` | Escompte applicable |
| `mentions_legales` | `TEXT` | NULL | — | Mentions légales complètes |
| `created_at` | `TIMESTAMPTZ` | NOT NULL | `now()` | Date de création |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL | `now()` | Dernière mise à jour |

**Statuts workflow :** `brouillon` → `validee` → `envoyee` → `payee`

### lignes_facture

| Colonne | Type | Nullable | Défaut | Description |
|---|---|---|---|---|
| `id` | `UUID` | NOT NULL | `gen_random_uuid()` | PK |
| `facture_id` | `UUID` | NOT NULL | — | FK → factures.id |
| `description` | `TEXT` | NOT NULL | — | Description |
| `quantite` | `NUMERIC` | NOT NULL | — | Quantité |
| `prix_unitaire` | `NUMERIC` | NOT NULL | — | Prix unitaire HT |
| `total_ligne` | `NUMERIC` | NOT NULL | — | Total HT ligne |
| `type_activite` | `TEXT` | NOT NULL | `'service'` | service ou commerce |
| `unite` | `TEXT` | NOT NULL | `'u'` | Unité |
| `type` | `TEXT` | NOT NULL | `'article'` | article, titre, sous-titre |
| `ordre` | `INTEGER` | NOT NULL | `0` | Position dans la facture |
| `est_gras` | `BOOLEAN` | NOT NULL | `false` | Mise en forme |
| `est_italique` | `BOOLEAN` | NOT NULL | `false` | Mise en forme |
| `est_souligne` | `BOOLEAN` | NOT NULL | `false` | Mise en forme |
| `avancement` | `NUMERIC` | NOT NULL | `100` | % avancement (situation) |
| `taux_tva` | `NUMERIC` | NOT NULL | `20.0` | Taux TVA applicable |

### paiements

| Colonne | Type | Nullable | Défaut | Description |
|---|---|---|---|---|
| `id` | `UUID` | NOT NULL | `gen_random_uuid()` | PK |
| `facture_id` | `UUID` | NOT NULL | — | FK → factures.id |
| `montant` | `NUMERIC` | NOT NULL | — | Montant du paiement |
| `date_paiement` | `TIMESTAMPTZ` | NOT NULL | — | Date du paiement |
| `type_paiement` | `TEXT` | NOT NULL | `'virement'` | virement, cheque, especes, cb |
| `commentaire` | `TEXT` | NULL | `''` | Note libre |
| `is_acompte` | `BOOLEAN` | NOT NULL | `false` | Paiement d'acompte |
| `created_at` | `TIMESTAMPTZ` | NOT NULL | `now()` | Date de création |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL | `now()` | Dernière mise à jour |

### devis

Structure très similaire à `factures`, avec colonnes spécifiques :

| Colonne spécifique | Type | Description |
|---|---|---|
| `numero_devis` | `TEXT` | DV-YYYY-NNNN (auto) |
| `duree_validite` | `INTEGER` | Durée validité en jours |
| `taux_acompte` | `NUMERIC` | Taux d'acompte demandé |
| `devis_parent_id` | `UUID` | FK → devis.id (avenants) |
| `version_avenant` | `INTEGER` | N° version avenant |

**Statuts :** `brouillon`, `envoye`, `accepte`, `refuse`, `expire`, `facture`, `avenant`

### lignes_devis

Structure identique à `lignes_facture` avec `devis_id` au lieu de `facture_id`.

### entreprises

| Colonne | Type | Nullable | Défaut | Description |
|---|---|---|---|---|
| `id` | `UUID` | NOT NULL | `gen_random_uuid()` | PK |
| `user_id` | `UUID` | NOT NULL | — | FK → auth.users (unique) |
| `nom_entreprise` | `TEXT` | NOT NULL | — | Raison sociale |
| `nom_gerant` | `TEXT` | NOT NULL | — | Nom du gérant |
| `adresse` | `TEXT` | NOT NULL | — | Adresse |
| `code_postal` | `TEXT` | NOT NULL | — | Code postal |
| `ville` | `TEXT` | NOT NULL | — | Ville |
| `siret` | `TEXT` | NOT NULL | — | SIRET (14 chiffres) |
| `email` | `TEXT` | NOT NULL | — | Email professionnel |
| `telephone` | `TEXT` | NULL | — | Téléphone |
| `iban` | `TEXT` | NULL | — | IBAN |
| `bic` | `TEXT` | NULL | — | BIC |
| `frequence_cotisation` | `TEXT` | NOT NULL | `'mensuelle'` | mensuelle ou trimestrielle |
| `logo_url` | `TEXT` | NULL | — | URL logo |
| `signature_url` | `TEXT` | NULL | — | URL signature défaut |
| `mentions_legales` | `TEXT` | NULL | — | Mentions personnalisées |
| `type_entreprise` | `TEXT` | NOT NULL | `'micro_entrepreneur_service'` | Type juridique |
| `regime_fiscal` | `TEXT` | NULL | — | Régime fiscal |
| `caisse_retraite` | `TEXT` | NOT NULL | `'ssi'` | SSI, CIPAV, etc. |
| `tva_applicable` | `BOOLEAN` | NOT NULL | `false` | TVA applicable |
| `numero_tva_intra` | `TEXT` | NULL | — | N° TVA intracommunautaire |
| `pdf_theme` | `TEXT` | NOT NULL | `'moderne'` | classique, moderne, minimaliste |
| `pdf_primary_color` | `TEXT` | NULL | — | Hex sans # (ex: 1E5572) |
| `logo_footer_url` | `TEXT` | NULL | — | Logo footer (certifications) |
| `mode_facturation` | `TEXT` | NOT NULL | `'global'` | global ou detaille |
| `mode_discret` | `BOOLEAN` | NOT NULL | `false` | Cacher le CA dans l'UI |
| `taux_penalites_retard` | `NUMERIC(5,2)` | NOT NULL | `11.62` | Taux pénalités par défaut |
| `escompte_applicable` | `BOOLEAN` | NOT NULL | `false` | Escompte par défaut |
| `est_immatricule` | `BOOLEAN` | NOT NULL | `false` | Si false → "Dispensé d'immatriculation" |
| `created_at` | `TIMESTAMPTZ` | NOT NULL | `now()` | Date de création |

### depenses

| Colonne | Type | Nullable | Défaut | Description |
|---|---|---|---|---|
| `id` | `UUID` | NOT NULL | `gen_random_uuid()` | PK |
| `user_id` | `UUID` | NOT NULL | — | FK → auth.users |
| `description` | `TEXT` | NOT NULL | — | Description |
| `montant` | `NUMERIC` | NOT NULL | — | Montant TTC |
| `date_depense` | `TIMESTAMPTZ` | NOT NULL | — | Date |
| `categorie` | `TEXT` | NOT NULL | — | Catégorie |
| `est_deductible` | `BOOLEAN` | NOT NULL | `false` | Déductible |
| `justificatif` | `TEXT` | NULL | — | URL justificatif |
| `created_at` | `TIMESTAMPTZ` | NOT NULL | `now()` | Création |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL | `now()` | Mise à jour |

### audit_logs

| Colonne | Type | Nullable | Défaut | Description |
|---|---|---|---|---|
| `id` | `UUID` | NOT NULL | `gen_random_uuid()` | PK |
| `user_id` | `UUID` | NOT NULL | — | FK → auth.users |
| `table_name` | `TEXT` | NOT NULL | — | Table concernée |
| `record_id` | `UUID` | NOT NULL | — | ID de l'enregistrement |
| `action` | `TEXT` | NOT NULL | — | Type d'action (voir CHECK) |
| `old_data` | `JSONB` | NULL | — | Données avant modification |
| `new_data` | `JSONB` | NULL | — | Données après modification |
| `metadata` | `JSONB` | NULL | `'{}'` | Métadonnées additionnelles |
| `created_at` | `TIMESTAMPTZ` | NOT NULL | `now()` | Horodatage |

**CHECK constraint :** `action IN ('INSERT', 'UPDATE', 'DELETE', 'VALIDATE', 'PAYMENT', 'EMAIL_SENT', 'RELANCE_SENT')`

### articles

| Colonne | Type | Description |
|---|---|---|
| `id` | `UUID` | PK |
| `user_id` | `UUID` | FK → auth.users |
| `designation` | `TEXT` | Nom de l'article |
| `prix_unitaire` | `NUMERIC` | Prix unitaire HT |
| `unite` | `TEXT` | Unité (u, h, m², etc.) |
| `type_activite` | `TEXT` | service ou commerce |
| `categorie` | `TEXT` | Catégorie |
| `description` | `TEXT` | Description longue |

### cotisations

| Colonne | Type | Description |
|---|---|---|
| `id` | `UUID` | PK |
| `user_id` | `UUID` | FK → auth.users |
| `periode` | `TEXT` | Période (ex: "2026-T1") |
| `montant_ca` | `NUMERIC` | CA de la période |
| `taux_cotisation` | `NUMERIC` | Taux applicable |
| `montant_cotisation` | `NUMERIC` | Montant calculé |
| `date_paiement` | `TIMESTAMPTZ` | Date de règlement |
| `est_paye` | `BOOLEAN` | Cotisation réglée |

---

## Relations (Foreign Keys)

```
auth.users (Supabase Auth)
  │
  ├── 1:N → clients.user_id
  ├── 1:N → factures.user_id
  ├── 1:N → devis.user_id
  ├── 1:N → depenses.user_id
  ├── 1:N → entreprises.user_id (1:1 en pratique)
  ├── 1:N → articles.user_id
  ├── 1:N → cotisations.user_id
  ├── 1:N → audit_logs.user_id
  ├── 1:N → events.user_id
  └── 1:N → shopping_items.user_id

clients
  ├── 1:N → factures.client_id
  └── 1:N → devis.client_id

factures
  ├── 1:N → lignes_facture.facture_id
  ├── 1:N → paiements.facture_id
  └── self → factures.facture_source_id (avoirs)

devis
  ├── 1:N → lignes_devis.devis_id
  ├── 1:1 → factures.devis_source_id (transformation)
  └── self → devis.devis_parent_id (avenants)
```

---

## Triggers

### Audit automatique

| Trigger | Table | Event | Fonction | Description |
|---|---|---|---|---|
| `trg_audit_factures` | `factures` | AFTER INSERT/UPDATE/DELETE | `audit_facture_changes()` | Log toute modification dans audit_logs |
| `trg_audit_devis` | `devis` | AFTER INSERT/UPDATE/DELETE | `audit_devis_changes()` | Log toute modification dans audit_logs |
| `trg_audit_paiements` | `paiements` | AFTER INSERT/UPDATE/DELETE | `audit_paiement_changes()` | Log avec résolution user_id via facture |

**Fonctions :** `SECURITY DEFINER` — s'exécutent avec les droits du propriétaire de la fonction.

### Immutabilité factures validées

| Trigger | Table | Event | Fonction |
|---|---|---|---|
| `trg_protect_validated_facture` | `factures` | BEFORE UPDATE | `protect_validated_facture()` |

**Comportement :** Si `statut_juridique != 'brouillon'` et que les champs protégés changent → `RAISE EXCEPTION`.

**Champs protégés :** `total_ht`, `total_tva`, `total_ttc`, `objet`, `client_id`, `remise_taux`, `conditions_reglement`

**Champs modifiables sur facture validée :** `statut`, `est_archive`, `signature_url`, `date_signature` (transitions de workflow)

### Updated_at automatique

| Trigger | Table |
|---|---|
| `trg_factures_updated_at` | `factures` |
| `trg_devis_updated_at` | `devis` |
| `trg_paiements_updated_at` | `paiements` |
| `trg_clients_updated_at` | `clients` |
| `trg_depenses_updated_at` | `depenses` |

**Fonction commune :** `set_updated_at()` — met `NEW.updated_at = NOW()` avant chaque UPDATE.

---

## Row Level Security (RLS)

**Principe :** Toutes les tables ont RLS activé. Chaque user ne voit que ses propres données.

```sql
-- Pattern standard pour toutes les tables
CREATE POLICY policy_name ON table_name
  FOR ALL
  USING (auth.uid() = user_id);
```

**Cas spéciaux :**

- `lignes_facture` / `lignes_devis` : policy basée sur la facture/devis parent (join)
- `paiements` : policy basée sur la facture parent
- `audit_logs` : policy directe sur `user_id`

---

## Index

### audit_logs (optimisation des requêtes d'audit)

```sql
CREATE INDEX idx_audit_logs_record ON audit_logs(record_id);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_table ON audit_logs(table_name);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);
```

### Autres index (créés automatiquement)

- PK sur toutes les tables (`id`)
- FK index automatiques sur les colonnes référencées
- `user_id` index implicite via les policies RLS

---

## Historique des migrations

Les migrations sont dans le dossier `migrations/` et doivent être exécutées dans l'ordre.

### Sprint 1-2 : Conformité légale (`migration_sprint1_legal_compliance.sql`)

**207 lignes** — Migration fondamentale :

1. **Nouveaux champs `entreprises`** : `taux_penalites_retard`, `escompte_applicable`, `est_immatricule`
2. **Nouveaux champs `factures`** : `numero_bon_commande`, `motif_avoir`
3. **Table `audit_logs`** : Création complète avec index et RLS
4. **Triggers d'audit** : `trg_audit_factures`, `trg_audit_devis`, `trg_audit_paiements`
5. **Trigger d'immutabilité** : `trg_protect_validated_facture`

### Sprint 5 : Updated_at (`migration_sprint5_updated_at.sql`)

1. **Fonction `set_updated_at()`** : Trigger function commune
2. **Colonne `updated_at`** : Ajoutée sur factures, devis, paiements, clients, depenses
3. **Backfill** : `updated_at = created_at` pour les données existantes (avec désactivation temporaire des triggers de protection)
4. **5 triggers** : `trg_*_updated_at` sur chaque table

### Sprint 8 : Extension audit (`migration_sprint8_audit_email.sql`)

1. **Extension CHECK constraint** : Ajout de `'EMAIL_SENT'` et `'RELANCE_SENT'` aux actions audit autorisées

### Sprint 9 : Personnalisation PDF (`migration_sprint9_pdf_custom.sql`)

1. **Colonne `pdf_primary_color`** : Couleur hex personnalisée pour les thèmes PDF
2. **Colonne `logo_footer_url`** : Logo footer (certifications, labels qualité)

### Ordre d'exécution

```
1. migration_sprint1_legal_compliance.sql   (Sprint 1-2)
2. migration_sprint5_updated_at.sql         (Sprint 5)
3. migration_sprint8_audit_email.sql        (Sprint 8)
4. migration_sprint9_pdf_custom.sql         (Sprint 9)
```

> **Note :** Les fichiers `hardening_integrity.sql`, `migration_avoirs.sql`, et `migration_numerotation_stricte.sql` référencés dans l'arborescence sont des fichiers placeholder ou legacy qui n'existent plus. Seules les 4 migrations ci-dessus sont effectives.
