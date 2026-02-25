# DATABASE.md — Base de Données ERP Artisan

> **Projet Supabase cible :** `Cap'Tech Project` — ID : `phfkebkwlhqizgizqlhu` — Région : `eu-west-1`
> **Moteur :** PostgreSQL 17 | **Dernière mise à jour :** 2026-02-25

---

## 1. Principes Généraux

| Règle | Description |
|-------|-------------|
| **Nommage tables** | Pluriel (`clients`, `factures`, `devis`) |
| **Nommage clés étrangères** | Singulier + `_id` (ex: `client_id`, `devis_id`) |
| **Clés primaires** | `UUID` généré par `gen_random_uuid()` |
| **Dates** | `TIMESTAMPTZ` (avec timezone) |
| **Montants** | `NUMERIC` (jamais `DOUBLE PRECISION`) |
| **Soft-delete** | `deleted_at TIMESTAMPTZ NULL` (pas de DELETE réel sur les docs) |
| **Isolation utilisateur** | Toutes les tables ont un `user_id UUID` référençant `auth.users.id` |
| **RLS** | Row Level Security activé sur **toutes** les tables |

---

## 2. Schéma des Tables

### 2.1 `entreprises`
Profil de l'entreprise artisane (1 ligne par utilisateur).

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `nom_entreprise` | TEXT | NON | — | Raison sociale |
| `nom_gerant` | TEXT | NON | — | Nom du gérant |
| `adresse` | TEXT | OUI | — | Adresse postale |
| `code_postal` | TEXT | OUI | — | Code postal |
| `ville` | TEXT | OUI | — | Ville |
| `siret` | TEXT | OUI | — | Numéro SIRET |
| `email` | TEXT | OUI | — | Email de l'entreprise |
| `telephone` | TEXT | OUI | — | Téléphone |
| `iban` | TEXT | OUI | — | IBAN bancaire |
| `bic` | TEXT | OUI | — | BIC bancaire |
| `frequence_cotisation` | TEXT | OUI | `'mois'` | Fréquence cotisation URSSAF |
| `logo_url` | TEXT | OUI | — | URL du logo (base64 stocké en DB) |
| `signature_url` | TEXT | OUI | — | URL de la signature |
| `mentions_legales` | TEXT | OUI | — | Mentions légales PDF |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |
| `type_entreprise` | VARCHAR | OUI | `'microEntrepreneurServiceBIC'` | Type légal de l'entreprise |
| `regime_fiscal` | VARCHAR | OUI | — | Régime fiscal (`micro`, `reelSimplifie`, `reelNormal`) |
| `caisse_retraite` | VARCHAR | OUI | `'ssi'` | Caisse de retraite (`ssi`, `cipav`, `carmf`…) |
| `tva_applicable` | BOOLEAN | OUI | `false` | TVA facturée (SASU/SARL) |
| `numero_tva_intra` | TEXT | OUI | — | N° TVA intracommunautaire |
| `pdf_theme` | VARCHAR | OUI | `'moderne'` | Thème PDF (`moderne`, `classique`, `minimal`) |
| `mode_facturation` | VARCHAR | OUI | `'global'` | Mode facturation (`global`, `detaille`) |
| `mode_discret` | BOOLEAN | OUI | `false` | Masquer résumé financier dans éditeur |
| `taux_penalites_retard` | NUMERIC | OUI | `11.62` | Taux pénalités retard (%) |
| `escompte_applicable` | BOOLEAN | OUI | `false` | Escompte applicable |
| `est_immatricule` | BOOLEAN | OUI | `false` | Entreprise immatriculée |
| `pdf_primary_color` | TEXT | OUI | — | Couleur primaire hex (ex: `1E5572`) pour PDF |
| `logo_footer_url` | TEXT | OUI | — | URL logo footer (certifications) |
| `is_admin` | BOOLEAN | OUI | `false` | Accès administrateur plateforme |

**Index :** `idx_entreprises_type` sur `type_entreprise`

---

### 2.2 `clients`
Carnet d'adresses des clients.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `nom_complet` | TEXT | NON | — | Nom complet (CHECK: non vide) |
| `type_client` | TEXT | OUI | `'particulier'` | `particulier` ou `professionnel` |
| `siret` | TEXT | OUI | — | SIRET (si professionnel) |
| `tva_intra` | TEXT | OUI | — | N° TVA intracommunautaire |
| `nom_contact` | TEXT | OUI | — | Contact principal |
| `adresse` | TEXT | OUI | — | Adresse |
| `code_postal` | TEXT | OUI | — | Code postal |
| `ville` | TEXT | OUI | — | Ville |
| `telephone` | TEXT | OUI | — | Téléphone |
| `email` | TEXT | OUI | — | Email (CHECK: format valide) |
| `notes_privees` | TEXT | OUI | — | Notes internes (non visibles client) |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |
| `updated_at` | TIMESTAMPTZ | OUI | `now()` | Dernière modification |
| `deleted_at` | TIMESTAMPTZ | OUI | NULL | Soft-delete |

**Index :**
- `idx_clients_not_deleted` sur `(user_id)` WHERE `deleted_at IS NULL`
- `idx_clients_deleted` sur `(user_id, deleted_at)` WHERE `deleted_at IS NOT NULL`

**Contraintes CHECK :**
- `nom_complet` : `char_length(TRIM(nom_complet)) > 0`
- `email` : format email valide ou NULL/vide

---

### 2.3 `articles`
Catalogue d'articles/prestations réutilisables.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `designation` | TEXT | NON | — | Libellé (CHECK: non vide) |
| `prix_unitaire` | NUMERIC | OUI | `0` | Prix de vente unitaire HT |
| `prix_achat` | NUMERIC | OUI | `0` | Prix d'achat unitaire |
| `type_activite` | TEXT | OUI | `'service'` | `service` ou `vente` |
| `unite` | TEXT | OUI | `'u'` | Unité de mesure |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |
| `taux_tva` | NUMERIC | OUI | `20` | Taux TVA (%) |

---

### 2.4 `devis`
Devis commerciaux / Chantiers.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `numero_devis` | TEXT | NON | — | Numéro formaté (ex: `D-2026-0001`) |
| `objet` | TEXT | OUI | — | Objet / titre du devis |
| `client_id` | UUID | OUI | — | FK → `clients.id` |
| `date_emission` | TIMESTAMPTZ | OUI | `now()` | Date d'émission |
| `date_validite` | TIMESTAMPTZ | OUI | — | Date d'expiration |
| `statut` | TEXT | OUI | `'brouillon'` | `brouillon`, `envoye`, `signe`, `refuse`, `expire`, `annule` |
| `est_transforme` | BOOLEAN | OUI | `false` | Converti en facture |
| `est_archive` | BOOLEAN | OUI | `false` | Archivé |
| `total_ht` | NUMERIC | OUI | `0` | Total HT (≥ 0) |
| `remise_taux` | NUMERIC | OUI | `0` | Remise globale (%) |
| `acompte_montant` | NUMERIC | OUI | `0` | Montant d'acompte demandé |
| `acompte_percentage` | NUMERIC | OUI | `30` | Pourcentage acompte (%) |
| `conditions_reglement` | TEXT | OUI | — | Conditions de paiement |
| `notes_publiques` | TEXT | OUI | — | Notes visibles dans le PDF |
| `notes_privees` | TEXT | OUI | — | Notes internes |
| `signature_url` | TEXT | OUI | — | URL signature client |
| `date_signature` | TIMESTAMPTZ | OUI | — | Date de la signature |
| `tva_intra` | TEXT | OUI | — | N° TVA intracommunautaire |
| `total_tva` | NUMERIC | OUI | `0` | Total TVA |
| `total_ttc` | NUMERIC | OUI | `0` | Total TTC |
| `devis_parent_id` | UUID | OUI | — | FK auto-référente → `devis.id` (avenants) |
| `devise` | TEXT | OUI | `'EUR'` | Code devise ISO |
| `taux_change` | NUMERIC | OUI | — | Taux de change si devise ≠ EUR |
| `type_chiffrage` | TEXT | OUI | `'standard'` | `standard` ou `progress_billing` |
| `avancement_global` | NUMERIC | OUI | — | % avancement global (Progress Billing) |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |
| `updated_at` | TIMESTAMPTZ | OUI | `now()` | Dernière modification (trigger) |
| `deleted_at` | TIMESTAMPTZ | OUI | NULL | Soft-delete |

**Index :**
- `idx_devis_not_deleted` sur `(user_id)` WHERE `deleted_at IS NULL`
- `idx_devis_deleted` sur `(user_id, deleted_at)` WHERE `deleted_at IS NOT NULL`
- `idx_devis_numero_unique` UNIQUE sur `(user_id, numero_devis)` WHERE `numero_devis` non vide et ≠ `'brouillon'`

**Contraintes CHECK :** `statut` ∈ {`brouillon`, `envoye`, `signe`, `refuse`, `expire`, `annule`}

---

### 2.5 `lignes_devis`
Lignes de détail des devis.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `devis_id` | UUID | NON | — | FK → `devis.id` |
| `description` | TEXT | OUI | — | Désignation de la ligne |
| `quantite` | NUMERIC | OUI | `1` | Quantité |
| `prix_unitaire` | NUMERIC | OUI | `0` | Prix unitaire HT |
| `total_ligne` | NUMERIC | OUI | `0` | Total HT de la ligne |
| `type_activite` | TEXT | OUI | `'service'` | `service` ou `vente` |
| `unite` | TEXT | OUI | `'u'` | Unité |
| `type` | TEXT | OUI | `'article'` | `article`, `titre`, `sous_total`, `saut_page` |
| `est_gras` | BOOLEAN | OUI | `false` | Formatage gras |
| `est_italique` | BOOLEAN | OUI | `false` | Formatage italique |
| `est_souligne` | BOOLEAN | OUI | `false` | Formatage souligné |
| `ordre` | INTEGER | OUI | `0` | Ordre d'affichage |
| `taux_tva` | NUMERIC | OUI | `0` | Taux TVA de la ligne (%) |
| `is_ai_estimated` | BOOLEAN | OUI | `false` | Ligne estimée par l'intelligence artificielle |

---

### 2.6 `factures`
Factures, avoirs, acomptes, situations.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `numero_facture` | TEXT | NON | — | Numéro formaté (ex: `F-2026-0001`) |
| `objet` | TEXT | OUI | — | Objet / titre |
| `client_id` | UUID | OUI | — | FK → `clients.id` |
| `date_emission` | TIMESTAMPTZ | OUI | `now()` | Date d'émission |
| `date_echeance` | TIMESTAMPTZ | OUI | — | Date d'échéance paiement |
| `date_validation` | TIMESTAMPTZ | OUI | — | Date de validation (remplie par trigger) |
| `statut` | TEXT | OUI | `'brouillon'` | Statut opérationnel |
| `statut_juridique` | TEXT | OUI | `'brouillon'` | Statut légal : `brouillon`, `validee`, `payee` |
| `est_archive` | BOOLEAN | OUI | `false` | Archivée |
| `total_ht` | NUMERIC | OUI | `0` | Total HT (≥ 0) |
| `remise_taux` | NUMERIC | OUI | `0` | Remise globale (%) |
| `acompte_deja_regle` | NUMERIC | OUI | `0` | Acompte déjà encaissé |
| `conditions_reglement` | TEXT | OUI | — | Conditions de paiement |
| `notes_publiques` | TEXT | OUI | — | Notes visibles PDF |
| `notes_privees` | TEXT | OUI | — | Notes internes |
| `devis_source_id` | UUID | OUI | — | Devis d'origine |
| `parent_document_id` | UUID | OUI | — | Document parent (situation → facture globale) |
| `facture_source_id` | UUID | OUI | — | FK auto-référente → `factures.id` (pour avoir) |
| `type_document` | TEXT | OUI | `'facture'` | Type de document |
| `type` | TEXT | OUI | `'standard'` | `standard`, `acompte`, `situation`, `solde`, `avoir` |
| `avancement_global` | NUMERIC | OUI | — | % avancement (facture de situation) |
| `tva_intra` | TEXT | OUI | — | N° TVA intracommunautaire |
| `total_tva` | NUMERIC | OUI | `0` | Total TVA |
| `total_ttc` | NUMERIC | OUI | `0` | Total TTC |
| `signature_url` | TEXT | OUI | — | URL signature |
| `date_signature` | TIMESTAMPTZ | OUI | — | Date signature |
| `numero_bon_commande` | TEXT | OUI | — | N° bon de commande client |
| `motif_avoir` | TEXT | OUI | — | Motif de l'avoir |
| `devise` | TEXT | OUI | `'EUR'` | Code devise ISO |
| `taux_change` | NUMERIC | OUI | — | Taux de change |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |
| `updated_at` | TIMESTAMPTZ | OUI | `now()` | Modification (trigger) |
| `deleted_at` | TIMESTAMPTZ | OUI | NULL | Soft-delete |

**Index :**
- `idx_factures_not_deleted` sur `(user_id)` WHERE `deleted_at IS NULL`
- `idx_factures_deleted` sur `(user_id, deleted_at)` WHERE `deleted_at IS NOT NULL`
- `idx_factures_numero_unique` UNIQUE sur `(user_id, numero_facture)` WHERE non vide et ≠ `'brouillon'`

> ⚠️ **Immuabilité légale** : Une facture avec `statut_juridique != 'brouillon'` ne peut plus voir ses données financières modifiées (trigger `trg_protect_validated_facture`). Créer un avoir pour toute rectification.

---

### 2.7 `lignes_factures`
Lignes de détail des factures.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `facture_id` | UUID | NON | — | FK → `factures.id` |
| `description` | TEXT | OUI | — | Désignation |
| `quantite` | NUMERIC | OUI | `1` | Quantité |
| `prix_unitaire` | NUMERIC | OUI | `0` | Prix unitaire HT |
| `total_ligne` | NUMERIC | OUI | `0` | Total HT ligne |
| `type_activite` | TEXT | OUI | `'service'` | `service` ou `vente` |
| `unite` | TEXT | OUI | `'u'` | Unité |
| `type` | TEXT | OUI | `'article'` | Type de ligne |
| `est_gras` | BOOLEAN | OUI | `false` | Gras |
| `est_italique` | BOOLEAN | OUI | `false` | Italique |
| `est_souligne` | BOOLEAN | OUI | `false` | Souligné |
| `ordre` | INTEGER | OUI | `0` | Ordre d'affichage |
| `avancement` | NUMERIC | OUI | `100` | % avancement ligne (factures de situation) |
| `taux_tva` | NUMERIC | OUI | `0` | Taux TVA (%) |

---

### 2.8 `lignes_chiffrages`
Chiffrage interne (Progress Billing) — coûts réels liés aux lignes devis/factures.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `devis_id` | UUID | OUI | — | FK → `devis.id` |
| `facture_id` | UUID | OUI | — | FK → `factures.id` |
| `designation` | TEXT | OUI | — | Désignation interne |
| `quantite` | NUMERIC | OUI | `1` | Quantité |
| `unite` | TEXT | OUI | `'u'` | Unité |
| `prix_achat_unitaire` | NUMERIC | OUI | `0` | Prix d'achat unitaire |
| `prix_vente_unitaire` | NUMERIC | OUI | `0` | Prix de vente unitaire |
| `prix_vente_interne` | NUMERIC | NON | `0` | Part du prix de vente public allouée (Valeur Réalisée) |
| `type_chiffrage` | TEXT | NON | `'materiel'` | `materiel` ou `main_doeuvre` (CHECK) |
| `est_achete` | BOOLEAN | NON | `false` | Matériel réceptionné (binaire 0/100%) |
| `avancement_mo` | NUMERIC | NON | `0` | % avancement MO (0–100, CHECK) |
| `linked_ligne_devis_id` | UUID | OUI | — | FK → `lignes_devis.id` (groupement Progress Billing) |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |
| `updated_at` | TIMESTAMPTZ | OUI | `now()` | Modification (trigger) |

**Index :**
- `idx_lignes_chiffrages_devis_id` WHERE `devis_id IS NOT NULL`
- `idx_lignes_chiffrages_linked_ligne_devis` WHERE `linked_ligne_devis_id IS NOT NULL`
- `idx_lignes_chiffrages_type` sur `type_chiffrage`

---

### 2.9 `paiements`
Encaissements sur les factures.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `facture_id` | UUID | NON | — | FK → `factures.id` |
| `montant` | NUMERIC | OUI | `0` | Montant (CHECK: ≠ 0) |
| `date_paiement` | TIMESTAMPTZ | OUI | `now()` | Date de paiement |
| `type_paiement` | TEXT | OUI | `'virement'` | `virement`, `cheque`, `especes`, `cb`… |
| `commentaire` | TEXT | OUI | — | Commentaire libre |
| `is_acompte` | BOOLEAN | OUI | `false` | Est un acompte |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |
| `updated_at` | TIMESTAMPTZ | OUI | `now()` | Modification (trigger) |

---

### 2.10 `factures_recurrentes`
Modèles de facturation automatique récurrente.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `client_id` | UUID | NON | — | FK → `clients.id` |
| `objet` | TEXT | NON | — | Objet de la facturation |
| `frequence` | TEXT | NON | — | `hebdomadaire`, `mensuelle`, `trimestrielle`, `annuelle` (CHECK) |
| `prochaine_emission` | DATE | NON | — | Prochaine date d'émission |
| `jour_emission` | INTEGER | OUI | `1` | Jour du mois (1–28) (CHECK) |
| `est_active` | BOOLEAN | OUI | `true` | Modèle actif |
| `total_ht` | NUMERIC | NON | `0` | Total HT du modèle |
| `total_tva` | NUMERIC | NON | `0` | Total TVA |
| `total_ttc` | NUMERIC | NON | `0` | Total TTC |
| `remise_taux` | NUMERIC | NON | `0` | Remise (%) |
| `conditions_reglement` | TEXT | OUI | `''` | Conditions de paiement |
| `notes_publiques` | TEXT | OUI | — | Notes PDF |
| `devise` | TEXT | OUI | `'EUR'` | Devise |
| `nb_factures_generees` | INTEGER | OUI | `0` | Compteur de factures émises |
| `derniere_generation` | TIMESTAMPTZ | OUI | — | Date dernière génération |
| `date_fin` | DATE | OUI | — | Date de fin du modèle récurrent |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |
| `updated_at` | TIMESTAMPTZ | OUI | `now()` | Modification (trigger) |
| `deleted_at` | TIMESTAMPTZ | OUI | NULL | Soft-delete |

**Index :**
- `idx_factures_recurrentes_user` WHERE `deleted_at IS NULL`
- `idx_factures_recurrentes_next` sur `prochaine_emission` WHERE `est_active = true AND deleted_at IS NULL`

---

### 2.11 `lignes_facture_recurrente`
Lignes des modèles de factures récurrentes.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `facture_recurrente_id` | UUID | NON | — | FK → `factures_recurrentes.id` |
| `description` | TEXT | NON | — | Désignation |
| `quantite` | NUMERIC | NON | `1` | Quantité |
| `prix_unitaire` | NUMERIC | NON | `0` | Prix unitaire HT |
| `total_ligne` | NUMERIC | NON | `0` | Total ligne |
| `type_activite` | TEXT | OUI | `'service'` | `service` ou `vente` |
| `unite` | TEXT | OUI | `'u'` | Unité |
| `taux_tva` | NUMERIC | OUI | `20` | Taux TVA (%) |
| `ordre` | INTEGER | OUI | `0` | Ordre d'affichage |

---

### 2.12 `depenses`
Dépenses et charges professionnelles.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `titre` | TEXT | NON | — | Intitulé de la dépense |
| `montant` | NUMERIC | OUI | `0` | Montant |
| `date` | TIMESTAMPTZ | OUI | `now()` | Date de la dépense |
| `categorie` | TEXT | OUI | `'autre'` | Catégorie |
| `fournisseur` | TEXT | OUI | — | Fournisseur |
| `devis_id` | UUID | OUI | — | FK obsolète (utiliser `chantier_devis_id`) |
| `chantier_devis_id` | UUID | OUI | — | FK → `devis.id` (calcul marge réelle) |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |
| `updated_at` | TIMESTAMPTZ | OUI | `now()` | Modification (trigger) |
| `deleted_at` | TIMESTAMPTZ | OUI | NULL | Soft-delete |

**Index :** `idx_depenses_chantier_devis_id` WHERE `chantier_devis_id IS NOT NULL`

---

### 2.13 `temps_activites`
Suivi du temps passé par projet/client.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `client_id` | UUID | OUI | — | FK → `clients.id` |
| `projet` | TEXT | OUI | `''` | Nom du projet/chantier |
| `description` | TEXT | NON | — | Description de l'activité |
| `date_activite` | DATE | NON | — | Date de l'activité |
| `duree_minutes` | INTEGER | NON | `0` | Durée en minutes |
| `taux_horaire` | NUMERIC | OUI | `0` | Taux horaire (€/h) |
| `est_facturable` | BOOLEAN | OUI | `true` | Temps facturable |
| `est_facture` | BOOLEAN | OUI | `false` | Temps déjà facturé |
| `facture_id` | UUID | OUI | — | FK → `factures.id` (si facturé) |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |
| `updated_at` | TIMESTAMPTZ | OUI | `now()` | Modification (trigger) |
| `deleted_at` | TIMESTAMPTZ | OUI | NULL | Soft-delete |

**Index :**
- `idx_temps_activites_user` WHERE `deleted_at IS NULL`
- `idx_temps_activites_client` sur `(client_id, date_activite)` WHERE `deleted_at IS NULL`
- `idx_temps_activites_facturable` WHERE `est_facturable = true AND est_facture = false AND deleted_at IS NULL`

---

### 2.14 `rappels`
Rappels et échéances fiscales/admin.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `titre` | TEXT | NON | — | Titre du rappel |
| `description` | TEXT | OUI | — | Description |
| `type_rappel` | TEXT | NON | — | `urssaf`, `cfe`, `tva`, `impots`, `custom`, `echeance_facture`, `fin_devis` |
| `date_echeance` | DATE | NON | — | Date d'échéance |
| `est_complete` | BOOLEAN | OUI | `false` | Rappel complété |
| `est_recurrent` | BOOLEAN | OUI | `false` | Rappel récurrent |
| `frequence_recurrence` | TEXT | OUI | — | `mensuelle`, `trimestrielle`, `annuelle` |
| `priorite` | TEXT | OUI | `'normale'` | `basse`, `normale`, `haute`, `urgente` |
| `entite_liee_id` | UUID | OUI | — | ID de l'entité liée (facture, devis…) |
| `entite_liee_type` | TEXT | OUI | — | Type de l'entité liée |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |
| `updated_at` | TIMESTAMPTZ | OUI | `now()` | Modification (trigger) |

**Contraintes CHECK :**
- `type_rappel` ∈ {`urssaf`, `cfe`, `tva`, `impots`, `custom`, `echeance_facture`, `fin_devis`}
- `priorite` ∈ {`basse`, `normale`, `haute`, `urgente`}

**Index :**
- `idx_rappels_user` WHERE `est_complete = false`
- `idx_rappels_echeance` sur `date_echeance` WHERE `est_complete = false`

---

### 2.15 `plannings`
Planning des chantiers et interventions.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `titre` | TEXT | NON | — | Titre de l'événement |
| `date_debut` | TIMESTAMPTZ | NON | — | Début |
| `date_fin` | TIMESTAMPTZ | NON | — | Fin |
| `client_id` | UUID | OUI | — | FK → `clients.id` |
| `type` | TEXT | OUI | `'chantier'` | Type d'événement |
| `description` | TEXT | OUI | — | Description |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |

---

### 2.16 `rendez_vous`
Agenda / rendez-vous.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | `auth.uid()` | FK → `auth.users.id` |
| `client_id` | UUID | OUI | — | FK → `clients.id` |
| `titre` | TEXT | NON | — | Titre |
| `date_debut` | TIMESTAMPTZ | NON | — | Début |
| `date_fin` | TIMESTAMPTZ | NON | — | Fin |
| `description` | TEXT | OUI | — | Description |
| `est_fait` | BOOLEAN | OUI | `false` | Marqué comme effectué |

---

### 2.17 `courses`
Liste de courses / achats à faire.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `designation` | TEXT | NON | — | Désignation |
| `quantite` | NUMERIC | OUI | `1` | Quantité |
| `prix_unitaire` | NUMERIC | OUI | `0` | Prix unitaire |
| `unite` | TEXT | OUI | `'u'` | Unité |
| `est_achete` | BOOLEAN | OUI | `false` | Acheté |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |

---

### 2.18 `photos`
Photos liées aux clients/chantiers.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `client_id` | UUID | NON | — | FK → `clients.id` |
| `url` | TEXT | NON | — | URL de la photo (Storage Supabase) |
| `commentaire` | TEXT | OUI | — | Commentaire |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |

---

### 2.19 `compteurs_documents`
Compteurs séquentiels pour la numérotation des documents.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `annee` | INTEGER | NON | — | Année du compteur |
| `type_document` | TEXT | NON | — | `facture`, `devis`, `avoir`, `acompte` |
| `valeur_actuelle` | INTEGER | OUI | `0` | Valeur courante (incrémentée atomiquement) |

**Contrainte UNIQUE :** `(user_id, annee, type_document)` — garantit l'unicité du compteur par type et par an.

> ⚠️ **Critique :** Ce compteur est mis à jour atomiquement par `get_next_document_number_strict()` via verrou de ligne (`SELECT FOR UPDATE`). Ne jamais incrémenter manuellement.

---

### 2.20 `audit_logs`
Journal d'audit automatique (INSERT/UPDATE/DELETE sur les documents).

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `table_name` | TEXT | NON | — | Table concernée |
| `record_id` | UUID | NON | — | ID de l'enregistrement |
| `action` | TEXT | NON | — | `INSERT`, `UPDATE`, `DELETE`, `VALIDATE`, `PAYMENT`, `EMAIL_SENT`, `RELANCE_SENT` |
| `old_data` | JSONB | OUI | — | État avant modification |
| `new_data` | JSONB | OUI | — | État après modification |
| `metadata` | JSONB | OUI | `{}` | Métadonnées additionnelles |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Timestamp de l'événement |

**Index :**
- `idx_audit_logs_user` sur `user_id`
- `idx_audit_logs_record` sur `record_id`
- `idx_audit_logs_table` sur `table_name`
- `idx_audit_logs_created` sur `created_at DESC`

---

### 2.21 `urssaf_configs`
Configuration des taux de cotisations URSSAF/fiscaux (1 ligne par utilisateur).

Table très large (~70 colonnes) stockant tous les taux légaux 2026 :

**Taux micro-entrepreneur :**
- `taux_micro_vente` (12.3%), `taux_micro_prestation_bic` (21.2%), `taux_micro_prestation_bnc` (25.6%)
- `taux_micro_liberal_cipav` (23.2%), `taux_micro_meubles` (6.0%)
- `accre_active` BOOLEAN — ACRE active ; `accre_annee` INTEGER (1–4)
- Plafonds CA : `plafond_ca_micro_vente` (188 700€), `plafond_ca_micro_service` (77 700€)
- Seuils TVA : `seuil_tva_micro_vente` (91 900€), `seuil_tva_micro_service` (36 800€)

**Taux TNS (gérant majoritaire SARL/EURL) :**
- Maladie (0–6.5%), Retraite base (17.75%), Retraite complémentaire (7–8%)
- CSG/CRDS (9.7%), Allocations familiales (0–3.1%)

**Taux salarié (SASU/SAS) :**
- Vieillesse salariale/patronale, Retraite complémentaire AGIRC-ARRCO
- Maladie patronale (7% si ≤2.5 SMIC, 13% sinon)
- Réduction Fillon

**IS et dividendes :**
- `taux_is_reduit` (15% jusqu'à 42 500€), `taux_is_normal` (25%)
- `taux_csg_dividendes` (10.6% — hausse 2026), `taux_pfu_total` (30%)

**Index :**
- `idx_urssaf_configs_acre` sur `accre_active`
- `idx_urssaf_configs_type` sur `type_entreprise`

---

### 2.22 `support_tickets`
Tickets de support utilisateur.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | NON | — | FK → `auth.users.id` |
| `subject` | TEXT | NON | — | Sujet |
| `description` | TEXT | NON | — | Description du problème |
| `status` | TEXT | NON | `'open'` | `open`, `closed` |
| `ai_resolution` | TEXT | OUI | — | Résolution générée par l'IA |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |
| `updated_at` | TIMESTAMPTZ | OUI | `now()` | Modification (trigger) |

---

### 2.23 `crash_logs`
Logs d'erreurs applicatives côté client.

| Colonne | Type | Nullable | Défaut | Description |
|---------|------|----------|--------|-------------|
| `id` | UUID | NON | `gen_random_uuid()` | PK |
| `user_id` | UUID | OUI | — | FK → `auth.users.id` |
| `error_message` | TEXT | NON | — | Message d'erreur |
| `stack_trace` | TEXT | OUI | — | Stack trace |
| `app_version` | VARCHAR | OUI | — | Version de l'app |
| `device_info` | JSONB | OUI | — | Infos navigateur/OS |
| `created_at` | TIMESTAMPTZ | OUI | `now()` | Création |
| `resolved` | BOOLEAN | OUI | `false` | Résolu |

---

## 3. Triggers SQL

### 3.1 Triggers `updated_at` (BEFORE UPDATE)

| Trigger | Table | Fonction |
|---------|-------|---------|
| `trg_clients_updated_at` | `clients` | `set_updated_at()` |
| `trg_devis_updated_at` | `devis` | `set_updated_at()` |
| `trg_depenses_updated_at` | `depenses` | `set_updated_at()` |
| `trg_factures_updated_at` | `factures` | `set_updated_at()` |
| `trg_factures_recurrentes_updated_at` | `factures_recurrentes` | `update_updated_at()` |
| `trg_lignes_chiffrages_updated_at` | `lignes_chiffrages` | `update_lignes_chiffrages_updated_at()` |
| `trg_paiements_updated_at` | `paiements` | `set_updated_at()` |
| `trg_rappels_updated_at` | `rappels` | `update_updated_at()` |
| `trg_support_tickets_updated_at` | `support_tickets` | `set_updated_at()` |
| `trg_temps_activites_updated_at` | `temps_activites` | `update_updated_at()` |

### 3.2 Triggers de numérotation (BEFORE INSERT/UPDATE)

| Trigger | Table | Déclenchement | Logique |
|---------|-------|---------------|---------|
| `trg_generate_devis_number` | `devis` | Passage statut → `envoye`/`signe` | Appelle `get_next_document_number_strict()` |
| `trg_generate_facture_number` | `factures` | Passage `statut_juridique` → `validee`/`payee` | Appelle `get_next_document_number_strict()`, positionne `date_validation` |

### 3.3 Triggers de protection (BEFORE UPDATE/DELETE)

| Trigger | Table | Protection |
|---------|-------|-----------|
| `trig_prevent_devis_mod` | `devis` | Bloque modif financière sur devis non-brouillon ; bloque DELETE si statut ∉ {`brouillon`, `expire`} |
| `trg_protect_validated_facture` | `factures` | Bloque modif champs financiers si `statut_juridique != 'brouillon'` |
| `trig_prevent_facture_mod` | `factures` | Redondance ; même logique que `trg_protect_validated_facture` |

> 💡 Le soft-delete (`updated deleted_at`) est toujours autorisé par tous les triggers de protection.

### 3.4 Triggers d'audit (AFTER INSERT/UPDATE/DELETE)

| Trigger | Table | Fonction |
|---------|-------|---------|
| `trg_audit_devis` | `devis` | `audit_devis_changes()` → `audit_logs` |
| `trg_audit_factures` | `factures` | `audit_facture_changes()` → `audit_logs` |
| `trg_audit_factures_recurrentes` | `factures_recurrentes` | `audit_factures_recurrentes()` → `audit_logs` |
| `trg_audit_paiements` | `paiements` | `audit_paiement_changes()` → `audit_logs` (récupère `user_id` depuis la facture parente) |

---

## 4. Fonctions PostgreSQL

### 4.1 `get_next_document_number_strict(p_user_id, p_type_doc, p_annee) → TEXT`
Génère le prochain numéro de document avec **verrou de ligne atomique**.

**Préfixes :**
| Type | Préfixe | Exemple |
|------|---------|---------|
| `facture` | `F` | `F-2026-0001` |
| `devis` | `D` | `D-2026-0042` |
| `avoir` | `AV` | `AV-2026-0003` |
| `acompte` | `FA` | `FA-2026-0001` |

**Format :** `PREFIXE-ANNEE-NNNN` (4 chiffres avec padding zéro)

**Séquence :**
1. `UPDATE compteurs_documents SET valeur_actuelle = valeur_actuelle + 1 RETURNING valeur_actuelle` (atomique via verrou)
2. Si aucun compteur : INSERT avec valeur 1
3. Retourne le numéro formaté

### 4.2 `get_next_document_number(p_type_document, p_annee) → TEXT` *(Legacy)*
Ancienne version utilisant `auth.uid()`. Conservée pour compatibilité.  
**Préférer `get_next_document_number_strict()`** pour toute nouvelle implémentation.

### 4.3 `expire_devis_depasses() → INTEGER`
Met à jour les devis expirés (`statut = 'expire'` si `statut = 'envoye'` ET `date_validite < NOW()`).  
Retourne le nombre de devis mis à jour. À appeler périodiquement (cron).

### 4.4 `purge_old_deleted_items() → VOID`
Purge physique des enregistrements soft-deletés depuis plus de **30 jours** :
1. Supprime les paiements orphelins, lignes_factures, lignes_chiffrages d'abord (FK)
2. Supprime les factures, devis, clients, dépenses soft-deletés

### 4.5 `get_db_metrics() → JSON`
Retourne la taille de la base de données courante en bytes et MB.

### 4.6 Fonctions de trigger d'audit
- `audit_devis_changes()` — Log INSERT/UPDATE/DELETE sur `devis`
- `audit_facture_changes()` — Log INSERT/UPDATE/DELETE sur `factures`  
- `audit_factures_recurrentes()` — Log INSERT/UPDATE/DELETE sur `factures_recurrentes`
- `audit_paiement_changes()` — Log INSERT/UPDATE/DELETE sur `paiements` (résout le `user_id` depuis la facture parente)

### 4.7 Fonctions de trigger de protection
- `protect_validated_facture()` — Bloque les modifications financières sur factures validées
- `prevent_facture_modification()` — Bloque DELETE sur factures non-brouillon, protège les champs fiscaux
- `prevent_devis_modification()` — Bloque DELETE sur devis validés, protège les champs financiers
- `prevent_invoice_line_modification()` — Bloque toute modification de `lignes_factures` si facture validée
- `prevent_invoice_modification()` — Double protection sur modification des factures

### 4.8 Fonctions de trigger `updated_at`
- `set_updated_at()` — `NEW.updated_at = NOW(); RETURN NEW;`
- `update_updated_at()` — Identique, alias
- `update_lignes_chiffrages_updated_at()` — Identique, spécifique à `lignes_chiffrages`

---

## 5. Row Level Security (RLS)

> Toutes les tables ont RLS activé. Le principe est **`auth.uid() = user_id`** pour les tables avec `user_id` direct.

### Policies par table

| Table | Policy | Opération | Condition |
|-------|--------|-----------|-----------|
| `articles` | Users can all on own articles | ALL | `auth.uid() = user_id` |
| `clients` | Users can all on own clients | ALL | `auth.uid() = user_id` |
| `compteurs_documents` | Users can manage their counters | ALL | `auth.uid() = user_id` |
| `courses` | Users can all on own courses | ALL | `auth.uid() = user_id` |
| `depenses` | Users can all on own depenses | ALL | `auth.uid() = user_id` |
| `devis` | Users can all on own devis | ALL | `auth.uid() = user_id` |
| `entreprises` | Users can all on own entreprise | ALL | `auth.uid() = user_id` |
| `factures` | Users can all on own factures | ALL | `auth.uid() = user_id` |
| `factures_recurrentes` | Users manage own | ALL | `auth.uid() = user_id` |
| `lignes_chiffrages` | Users can all on own chiffrage | ALL | `auth.uid() = user_id` |
| `lignes_devis` | Users can all on own lignes_devis | ALL | Via `EXISTS (SELECT 1 FROM devis WHERE devis.id = lignes_devis.devis_id AND devis.user_id = auth.uid())` |
| `lignes_factures` | Users can all on own lignes_factures | ALL | Via `EXISTS (SELECT 1 FROM factures WHERE factures.id = lignes_factures.facture_id AND factures.user_id = auth.uid())` |
| `lignes_facture_recurrente` | Users can manage via parent | ALL | Via `facture_recurrente_id IN (SELECT id FROM factures_recurrentes WHERE user_id = auth.uid())` |
| `paiements` | Users can all on own paiements | ALL | Via `EXISTS (SELECT 1 FROM factures WHERE factures.id = paiements.facture_id AND factures.user_id = auth.uid())` |
| `photos` | Users can all/insert/select/delete | ALL | `auth.uid() = user_id` |
| `plannings` | Users can all on own plannings | ALL | `auth.uid() = user_id` |
| `rappels` | Users manage own rappels | ALL | `auth.uid() = user_id` |
| `rendez_vous` | Users can all on own rdv | ALL | `auth.uid() = user_id` |
| `temps_activites` | Users manage own | ALL | `auth.uid() = user_id` |
| `urssaf_configs` | Users can all on own urssaf | ALL | `auth.uid() = user_id` |

**Policies spéciales :**
| Table | Policy | Opération | Condition |
|-------|--------|-----------|-----------|
| `audit_logs` | Users can read own audit logs | SELECT | `auth.uid() = user_id` |
| `audit_logs` | Users can insert audit logs | INSERT | `auth.uid() = user_id OR user_id IS NULL` |
| `crash_logs` | Users can insert their own | INSERT | `auth.uid() = user_id OR user_id IS NULL` |
| `crash_logs` | Admins can view all crash logs | SELECT | `auth.uid() IN (SELECT id FROM entreprises WHERE is_admin = true)` |
| `support_tickets` | Users can view/insert/update own | SELECT/INSERT/UPDATE | `auth.uid() = user_id` |

---

## 6. Relations (Diagramme simplifié)

```
auth.users
    │
    ├── entreprises (1:1)
    ├── urssaf_configs (1:1)
    │
    ├── clients (1:N)
    │   ├── devis (N:1)
    │   ├── factures (N:1)
    │   ├── factures_recurrentes (N:1)
    │   ├── temps_activites (N:1)
    │   ├── plannings (N:1)
    │   └── photos (N:1)
    │
    ├── devis (1:N)
    │   ├── lignes_devis (1:N)
    │   ├── lignes_chiffrages (1:N)
    │   ├── devis [auto-référence : avenants] (1:N)
    │   └── depenses [via chantier_devis_id] (1:N)
    │
    ├── factures (1:N)
    │   ├── lignes_factures (1:N)
    │   ├── lignes_chiffrages (1:N)
    │   ├── paiements (1:N)
    │   ├── factures [auto-référence : avoirs] (1:N)
    │   └── temps_activites [si facturé] (1:N)
    │
    ├── factures_recurrentes (1:N)
    │   └── lignes_facture_recurrente (1:N)
    │
    ├── compteurs_documents (1:N par type/année)
    ├── audit_logs (1:N)
    ├── rappels (1:N)
    ├── courses (1:N)
    ├── rendez_vous (1:N)
    ├── depenses (1:N)
    ├── articles (1:N)
    ├── support_tickets (1:N)
    └── crash_logs (1:N)
```

---

## 7. Règles CRUD — BaseRepository

Toute opération passe par `BaseRepository` en Flutter :

```dart
// prepareForInsert : ajoute user_id depuis auth.uid(), retire 'id'
Map<String, dynamic> prepareForInsert(Map<String, dynamic> data) {
  data['user_id'] = supabase.auth.currentUser!.id;
  data.remove('id');
  return data;
}

// prepareForUpdate : retire 'user_id' ET 'id' (RLS bloque sinon)
Map<String, dynamic> prepareForUpdate(Map<String, dynamic> data) {
  data.remove('id');
  data.remove('user_id'); // OBLIGATOIRE sinon RLS bloque
  return data;
}
```

> ⚠️ **Ne jamais tenter de modifier `user_id` en UPDATE.** La policy RLS bloquera systématiquement.

---

## 8. Gestion Soft-Delete et Corbeille

Les tables `clients`, `devis`, `factures`, `depenses`, `temps_activites`, `factures_recurrentes` supportent le soft-delete via `deleted_at`.

**Règles :**
- Un enregistrement est "supprimé" quand `deleted_at IS NOT NULL`
- Toutes les requêtes de liste filtrent `WHERE deleted_at IS NULL`
- La corbeille affiche les enregistrements `WHERE deleted_at IS NOT NULL`
- La purge physique se fait après 30 jours via `purge_old_deleted_items()`
- Les triggers de protection autorisent toujours le soft-delete (même sur facture validée)

---

## 9. Numérotation Séquentielle (Conformité Anti-Fraude)

Le système garantit la numérotation strictement séquentielle par :

1. **Trigger `trg_generate_devis_number`** : déclenché au passage en `envoye`/`signe`
2. **Trigger `trg_generate_facture_number`** : déclenché au passage en `validee`/`payee`
3. **Fonction `get_next_document_number_strict()`** : verrou atomique sur `compteurs_documents`
4. **Index UNIQUE** `idx_devis_numero_unique` et `idx_factures_numero_unique` : empêchent les doublons

**Format :** `{PRÉFIXE}-{ANNÉE}-{NNNN}` (numéro à 4 chiffres, remis à zéro chaque année)

---

## 10. Extensions PostgreSQL utilisées

```sql
-- Vérifier les extensions actives :
SELECT name, installed_version FROM pg_available_extensions WHERE installed_version IS NOT NULL;
```

Extensions clés : `uuid-ossp` (uuid_generate_v4), `pgcrypto` (gen_random_uuid).
