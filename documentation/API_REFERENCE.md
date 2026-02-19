# Référence API — ERP Artisan

> Référence complète de l'API publique de toutes les couches — Dernière mise à jour : 19/02/2026

---

## Table des matières

1. [Core](#core)
2. [Models](#models)
3. [Repositories](#repositories)
4. [ViewModels](#viewmodels)
5. [Services](#services)
6. [Utilitaires](#utilitaires)

---

## Core

### BaseViewModel

**Fichier :** `lib/core/base_viewmodel.dart`

| Propriété / Méthode | Type | Description |
|---|---|---|
| `isLoading` | `bool` (getter) | `true` si au moins une opération est en cours |
| `error` | `String?` (getter) | Message d'erreur de la dernière opération échouée |
| `executeOperation(Future<void> Function())` | `Future<bool>` | Exécute une opération async avec loading + error handling. Retourne `true` si succès |
| `execute(Future<void> Function())` | `Future<void>` | Variante simple pour les chargements (pas de retour booléen) |
| `clearError()` | `void` | Réinitialise le message d'erreur |

### BaseRepository

**Fichier :** `lib/core/base_repository.dart`

| Propriété / Méthode | Type | Description |
|---|---|---|
| `client` | `SupabaseClient` | Instance Supabase via `SupabaseConfig.client` |
| `prepareForInsert(Map<String, dynamic>)` | `Map<String, dynamic>` | Ajoute `user_id` (auth.uid), retire `id` |
| `prepareForUpdate(Map<String, dynamic>)` | `Map<String, dynamic>` | Retire `user_id` et `id` (RLS gère le user) |
| `handleError(String, Object, [StackTrace?])` | `Never` | Lance une exception formatée avec contexte |

### DocumentRepository

**Fichier :** `lib/core/document_repository.dart` — Étend `BaseRepository`

| Méthode | Type | Description |
|---|---|---|
| `uploadSignature(String bucket, String path, Uint8List bytes)` | `Future<String?>` | Upload vers Supabase Storage, retourne l'URL publique |
| `generateNextNumero(String table, String column, String prefix)` | `Future<String>` | Génère `PREFIX-YYYY-NNNN` (numéro séquentiel) |
| `deleteChildLines(String table, String parentColumn, String parentId)` | `Future<void>` | Supprime les lignes enfants avant re-insertion |

### AutoSaveMixin

**Fichier :** `lib/core/autosave_mixin.dart` — Mixin sur `ChangeNotifier`

| Méthode | Type | Description |
|---|---|---|
| `checkLocalDraft(String key)` | `Future<Map<String, dynamic>?>` | Vérifie et retourne un brouillon local |
| `autoSaveDraft(String key, Map<String, dynamic> data)` | `void` | Sauvegarde avec debounce 2s |
| `clearLocalDraft(String key)` | `Future<void>` | Supprime le brouillon |
| `disposeAutoSave()` | `void` | Annule les timers de debounce |
| `hasPendingDraft` | `bool` (getter) | Indique si un brouillon existe |

### PdfGenerationMixin

**Fichier :** `lib/core/pdf_generation_mixin.dart` — Mixin sur `ChangeNotifier`

| Propriété / Méthode | Type | Description |
|---|---|---|
| `pdfBytes` | `Uint8List?` (getter) | Bytes du PDF généré |
| `isRealTimePreview` | `bool` (getter) | Mode preview activé |
| `isPdfGenerating` | `bool` (getter) | Génération en cours |
| `toggleRealTimePreview()` | `void` | Active/désactive le mode preview temps réel |
| `triggerPdfUpdate()` | `void` | Lance la régénération PDF (debounce 1s) |
| `forceRefreshPdf()` | `Future<void>` | Régénération immédiate |
| `clearPdfState()` | `void` | Nettoie le cache PDF et les bytes |
| `_cachedFonts` | `Map<String, Font>` | Cache des polices chargées |

---

## Models

### Client

**Fichier :** `lib/models/client_model.dart` — Table : `clients`

| Champ | Type Dart | Colonne DB | Description |
|---|---|---|---|
| `id` | `String?` | `id` (UUID) | Identifiant unique |
| `userId` | `String?` | `user_id` | Propriétaire (RLS) |
| `nomComplet` | `String` | `nom_complet` | Raison sociale ou nom complet |
| `typeClient` | `String` | `type_client` | `'particulier'` ou `'professionnel'` |
| `nomContact` | `String?` | `nom_contact` | Nom du contact (si pro) |
| `siret` | `String?` | `siret` | SIRET (14 chiffres, pro uniquement) |
| `tvaIntra` | `String?` | `tva_intra` | N° TVA intracommunautaire |
| `adresse` | `String` | `adresse` | Adresse postale |
| `codePostal` | `String` | `code_postal` | Code postal |
| `ville` | `String` | `ville` | Ville |
| `telephone` | `String` | `telephone` | Téléphone |
| `email` | `String` | `email` | Email |
| `notesPrivees` | `String?` | `notes_privees` | Notes internes |

**Méthodes :** `fromMap(Map)`, `toMap()`, `copyWith(...)`

### Facture

**Fichier :** `lib/models/facture_model.dart` — Table : `factures`

| Champ | Type Dart | Colonne DB | Description |
|---|---|---|---|
| `id` | `String?` | `id` (UUID) | Identifiant unique |
| `userId` | `String?` | `user_id` | Propriétaire (RLS) |
| `numeroFacture` | `String` | `numero_facture` | Numéro auto généré (FA-YYYY-NNNN) |
| `objet` | `String` | `objet` | Objet de la facture |
| `clientId` | `String` | `client_id` (FK) | Client associé |
| `devisSourceId` | `String?` | `devis_source_id` | Devis d'origine (si transformation) |
| `factureSourceId` | `String?` | `facture_source_id` | Facture source (pour avoirs) |
| `parentDocumentId` | `String?` | `parent_document_id` | Lien parent avoir → facture |
| `typeDocument` | `String` | `type_document` | `'facture'` ou `'avoir'` |
| `dateEmission` | `DateTime` | `date_emission` | Date d'émission |
| `dateEcheance` | `DateTime` | `date_echeance` | Date d'échéance |
| `dateValidation` | `DateTime?` | `date_validation` | Date de passage en validée |
| `statut` | `String` | `statut` | `brouillon`, `validee`, `envoyee`, `payee` |
| `statutJuridique` | `String` | `statut_juridique` | `brouillon`, `validee` (pour immutabilité) |
| `estArchive` | `bool` | `est_archive` | Archivé (soldée + > 12 mois) |
| `type` | `String` | `type` | `standard`, `acompte`, `situation`, `solde` |
| `avancementGlobal` | `Decimal?` | `avancement_global` | % avancement (situation) |
| `signatureUrl` | `String?` | `signature_url` | URL signature Supabase Storage |
| `dateSignature` | `DateTime?` | `date_signature` | Date de signature |
| `totalHt` | `Decimal` | `total_ht` | Total HT |
| `totalTva` | `Decimal` | `total_tva` | Total TVA |
| `totalTtc` | `Decimal` | `total_ttc` | Total TTC |
| `remiseTaux` | `Decimal` | `remise_taux` | Taux de remise (%) |
| `acompteDejaRegle` | `Decimal` | `acompte_deja_regle` | Montant d'acompte déjà réglé |
| `conditionsReglement` | `String` | `conditions_reglement` | Conditions de règlement |
| `notesPubliques` | `String?` | `notes_publiques` | Notes visibles sur le PDF |
| `tvaIntra` | `String?` | `tva_intra` | N° TVA intracommunautaire |
| `numeroBonCommande` | `String?` | `numero_bon_commande` | Référence bon de commande |
| `motifAvoir` | `String?` | `motif_avoir` | Motif de l'avoir |
| `tauxPenalitesRetard` | `double` | `taux_penalites_retard` | Taux pénalités de retard |
| `escompteApplicable` | `bool` | `escompte_applicable` | Escompte applicable |
| `mentionsLegales` | `String?` | `mentions_legales` | Mentions légales complètes |
| `devise` | `String` | `devise` | Devise (EUR, USD, GBP, CHF) — défaut EUR |
| `tauxChange` | `double` | `taux_change` | Taux de change vs EUR — défaut 1.0 |
| `notesPrivees` | `String?` | `notes_privees` | Notes internes (non imprimées) |
| `lignes` | `List<LigneFacture>` | — (join) | Lignes de la facture |
| `paiements` | `List<Paiement>` | — (join) | Paiements associés |

**Getters calculés :**

| Getter | Type | Description |
|---|---|---|
| `totalPaye` | `Decimal` | Somme des paiements |
| `resteAPayer` | `Decimal` | totalTtc - totalPaye |
| `estSoldee` | `bool` | resteAPayer <= 0 |
| `isAvoir` | `bool` | typeDocument == 'avoir' |
| `montantAvoir` | `Decimal` | Montant positif de l'avoir |

### LigneFacture

**Table :** `lignes_facture`

| Champ | Type Dart | Colonne DB | Description |
|---|---|---|---|
| `id` | `String?` | `id` (UUID) | Identifiant |
| `description` | `String` | `description` | Description de la ligne |
| `quantite` | `Decimal` | `quantite` | Quantité |
| `prixUnitaire` | `Decimal` | `prix_unitaire` | Prix unitaire HT |
| `totalLigne` | `Decimal` | `total_ligne` | Total HT de la ligne |
| `typeActivite` | `String` | `type_activite` | `'service'` ou `'commerce'` |
| `unite` | `String` | `unite` | Unité (`u`, `h`, `m²`, etc.) |
| `type` | `String` | `type` | `'article'`, `'titre'`, `'sous-titre'` |
| `ordre` | `int` | `ordre` | Position dans la facture |
| `estGras` | `bool` | `est_gras` | Mise en forme gras |
| `estItalique` | `bool` | `est_italique` | Mise en forme italique |
| `estSouligne` | `bool` | `est_souligne` | Mise en forme souligné |
| `avancement` | `Decimal` | `avancement` | % avancement (situation) |
| `tauxTva` | `Decimal` | `taux_tva` | Taux TVA applicable |

### Devis

**Fichier :** `lib/models/devis_model.dart` — Table : `devis`

Structure très similaire à Facture, avec en plus :

| Champ spécifique | Type Dart | Description |
|---|---|---|
| `numeroDevis` | `String` | Numéro auto (DV-YYYY-NNNN) |
| `dureeValidite` | `int` | Durée de validité en jours |
| `tauxAcompte` | `Decimal` | Taux d'acompte demandé |
| `devisParentId` | `String?` | Devis parent (avenants) |
| `versionAvenant` | `int` | N° de version avenant |
| `configCharges` | `ConfigCharges?` | Configuration charges sociales (local) |
| `devise` | `String` | Devise (EUR, USD, GBP, CHF) — défaut EUR |
| `tauxChange` | `double` | Taux de change vs EUR — défaut 1.0 |
| `notesPrivees` | `String?` | Notes internes (non imprimées) |

**Statuts :** `brouillon`, `envoye`, `accepte`, `refuse`, `expire`, `facture`, `avenant`

### LigneDevis

Identique à `LigneFacture` avec un champ supplémentaire `uiKey` (UUID v4 pour la gestion dans le stepper).

### Paiement

**Fichier :** `lib/models/paiement_model.dart` — Table : `paiements`

| Champ | Type Dart | Colonne DB | Description |
|---|---|---|---|
| `id` | `String?` | `id` (UUID) | Identifiant |
| `factureId` | `String` | `facture_id` (FK) | Facture associée |
| `montant` | `Decimal` | `montant` | Montant du paiement |
| `datePaiement` | `DateTime` | `date_paiement` | Date du paiement |
| `typePaiement` | `String` | `type_paiement` | `virement`, `cheque`, `especes`, `cb` |
| `commentaire` | `String` | `commentaire` | Note libre |
| `isAcompte` | `bool` | `is_acompte` | Paiement d'acompte |

### ProfilEntreprise

**Fichier :** `lib/models/entreprise_model.dart` — Table : `entreprises`

| Champ | Type Dart | Colonne DB | Description |
|---|---|---|---|
| `id` | `String?` | `id` (UUID) | Identifiant |
| `userId` | `String?` | `user_id` | Propriétaire |
| `nomEntreprise` | `String` | `nom_entreprise` | Raison sociale |
| `nomGerant` | `String` | `nom_gerant` | Nom du gérant |
| `adresse` | `String` | `adresse` | Adresse |
| `codePostal` | `String` | `code_postal` | Code postal |
| `ville` | `String` | `ville` | Ville |
| `siret` | `String` | `siret` | SIRET (14 chiffres) |
| `email` | `String` | `email` | Email professionnel |
| `telephone` | `String?` | `telephone` | Téléphone |
| `iban` | `String?` | `iban` | IBAN (paiement) |
| `bic` | `String?` | `bic` | BIC (paiement) |
| `frequenceCotisation` | `FrequenceCotisation` | `frequence_cotisation` | Mensuelle ou trimestrielle |
| `logoUrl` | `String?` | `logo_url` | URL logo entreprise |
| `signatureUrl` | `String?` | `signature_url` | URL signature par défaut |
| `mentionsLegales` | `String?` | `mentions_legales` | Mentions légales personnalisées |
| `typeEntreprise` | `TypeEntreprise` | `type_entreprise` | Type juridique |
| `regimeFiscal` | `RegimeFiscal?` | `regime_fiscal` | Régime fiscal |
| `caisseRetraite` | `CaisseRetraite` | `caisse_retraite` | Caisse retraite |
| `tvaApplicable` | `bool` | `tva_applicable` | TVA applicable |
| `numeroTvaIntra` | `String?` | `numero_tva_intra` | N° TVA intracommunautaire |
| `pdfTheme` | `PdfTheme` | `pdf_theme` | Thème PDF (classique/moderne/minimaliste) |
| `pdfPrimaryColor` | `String?` | `pdf_primary_color` | Couleur hex personnalisée PDF |
| `logoFooterUrl` | `String?` | `logo_footer_url` | Logo footer PDF (certifications) |
| `modeFacturation` | `ModeFacturation` | `mode_facturation` | Global ou détaillé |
| `modeDiscret` | `bool` | `mode_discret` | Mode discret (cacher CA) |
| `tauxPenalitesRetard` | `double` | `taux_penalites_retard` | Défaut 11.62% |
| `escompteApplicable` | `bool` | `escompte_applicable` | Escompte applicable |
| `estImmatricule` | `bool` | `est_immatricule` | Si false → "Dispensé d'immatriculation" |

### Depense

**Fichier :** `lib/models/depense_model.dart` — Table : `depenses`

| Champ | Type Dart | Description |
|---|---|---|
| `id` | `String?` | Identifiant |
| `userId` | `String?` | Propriétaire |
| `description` | `String` | Description de la dépense |
| `montant` | `Decimal` | Montant TTC |
| `dateDepense` | `DateTime` | Date de la dépense |
| `categorie` | `String` | Catégorie (fournitures, déplacement, etc.) |
| `estDeductible` | `bool` | Déductible fiscalement |
| `justificatif` | `String?` | URL du justificatif |

### Article

**Fichier :** `lib/models/article_model.dart` — Table : `articles`

| Champ | Type Dart | Description |
|---|---|---|
| `id` | `String?` | Identifiant |
| `userId` | `String?` | Propriétaire |
| `designation` | `String` | Nom de l'article |
| `prixUnitaire` | `Decimal` | Prix unitaire HT |
| `unite` | `String` | Unité (u, h, m², etc.) |
| `typeActivite` | `String` | Service ou commerce |
| `categorie` | `String?` | Catégorie |
| `description` | `String?` | Description longue |

### CotisationUrssaf

**Fichier :** `lib/models/urssaf_model.dart` — Table : `cotisations`

| Champ | Type Dart | Description |
|---|---|---|
| `id` | `String?` | Identifiant |
| `userId` | `String?` | Propriétaire |
| `periode` | `String` | Période (ex: "2026-T1") |
| `montantCa` | `Decimal` | CA de la période |
| `tauxCotisation` | `Decimal` | Taux applicable |
| `montantCotisation` | `Decimal` | Montant calculé |
| `datePaiement` | `DateTime?` | Date de règlement |
| `estPaye` | `bool` | Cotisation réglée |

### FactureRecurrente

**Fichier :** `lib/models/facture_recurrente_model.dart` — Table : `factures_recurrentes`

| Champ | Type Dart | Colonne DB | Description |
|---|---|---|---|
| `id` | `String?` | `id` (UUID) | Identifiant |
| `userId` | `String?` | `user_id` | Propriétaire (RLS) |
| `clientId` | `String` | `client_id` (FK) | Client associé |
| `objet` | `String` | `objet` | Objet de la facture |
| `frequence` | `FrequenceRecurrence` | `frequence` | Hebdomadaire, mensuel, trimestriel, annuel |
| `prochaineEmission` | `DateTime` | `prochaine_emission` | Date prochaine génération |
| `estActive` | `bool` | `est_active` | Toggle actif/inactif |
| `nbFacturesGenerees` | `int` | `nb_factures_generees` | Compteur factures générées |
| `totalHt` | `Decimal` | `total_ht` | Total HT |
| `totalTva` | `Decimal` | `total_tva` | Total TVA |
| `totalTtc` | `Decimal` | `total_ttc` | Total TTC |
| `devise` | `String` | `devise` | Devise (défaut EUR) |
| `remiseTaux` | `Decimal` | `remise_taux` | Taux de remise |
| `conditionsReglement` | `String` | `conditions_reglement` | Conditions |
| `lignes` | `List<LigneFactureRecurrente>` | — (join) | Lignes |

**Méthodes :** `fromMap(Map)`, `toMap()`, `copyWith(...)`

### LigneFactureRecurrente

**Table :** `lignes_facture_recurrente`

| Champ | Type Dart | Colonne DB | Description |
|---|---|---|---|
| `id` | `String?` | `id` (UUID) | Identifiant |
| `factureRecurrenteId` | `String?` | `facture_recurrente_id` (FK) | Facture récurrente parente |
| `description` | `String` | `description` | Description |
| `quantite` | `Decimal` | `quantite` | Quantité |
| `prixUnitaire` | `Decimal` | `prix_unitaire` | Prix unitaire HT |
| `totalLigne` | `Decimal` | `total_ligne` | Total HT de la ligne |
| `typeActivite` | `String` | `type_activite` | Service ou commerce |
| `tauxTva` | `Decimal` | `taux_tva` | Taux TVA applicable |

### TempsActivite

**Fichier :** `lib/models/temps_activite_model.dart` — Table : `temps_activites`

| Champ | Type Dart | Colonne DB | Description |
|---|---|---|---|
| `id` | `String?` | `id` (UUID) | Identifiant |
| `userId` | `String?` | `user_id` | Propriétaire (RLS) |
| `clientId` | `String?` | `client_id` (FK) | Client associé |
| `projet` | `String` | `projet` | Nom du projet |
| `description` | `String?` | `description` | Description activité |
| `dateActivite` | `DateTime` | `date_activite` | Date de l'activité |
| `dureeMinutes` | `int` | `duree_minutes` | Durée en minutes |
| `tauxHoraire` | `Decimal` | `taux_horaire` | Taux horaire HT |
| `montant` | `Decimal` | — (calculé) | duréeMinutes / 60 × tauxHoraire |
| `estFacturable` | `bool` | `est_facturable` | Facturable au client |
| `estFacture` | `bool` | `est_facture` | Déjà facturé |
| `factureId` | `String?` | `facture_id` (FK) | Facture liée |

**Getters calculés :**

| Getter | Type | Description |
|---|---|---|
| `dureeFormatee` | `String` | Format "Xh Ymin" |
| `montant` | `Decimal` | Montant = durée × taux horaire |

**Méthodes :** `fromMap(Map)`, `toMap()`, `copyWith(...)`

### Rappel

**Fichier :** `lib/models/rappel_model.dart` — Table : `rappels`

| Champ | Type Dart | Colonne DB | Description |
|---|---|---|---|
| `id` | `String?` | `id` (UUID) | Identifiant |
| `userId` | `String?` | `user_id` | Propriétaire (RLS) |
| `titre` | `String` | `titre` | Titre du rappel |
| `description` | `String?` | `description` | Description détaillée |
| `typeRappel` | `TypeRappel` | `type_rappel` | urssaf, cfe, impots, tva, echeanceFacture, echeanceDevis, autre |
| `dateEcheance` | `DateTime` | `date_echeance` | Date d'échéance |
| `estComplete` | `bool` | `est_complete` | Complété |
| `priorite` | `PrioriteRappel` | `priorite` | basse, normale, haute, urgente |
| `estRecurrent` | `bool` | `est_recurrent` | Récurrent |
| `frequenceRecurrence` | `String?` | `frequence_recurrence` | Fréquence si récurrent |
| `entiteLieeId` | `String?` | `entite_liee_id` | Entité liée (facture, devis) |
| `entiteLieeType` | `String?` | `entite_liee_type` | Type entité liée |

**Getters calculés :**

| Getter | Type | Description |
|---|---|---|
| `joursRestants` | `int` | Jours avant l'échéance |
| `estEnRetard` | `bool` | Date dépassée et non complété |
| `estProche` | `bool` | Échéance dans les 7 jours |

**Méthodes :** `fromMap(Map)`, `toMap()`, `copyWith(...)`

### TypeChiffrage (Enum)

**Fichier :** `lib/models/chiffrage_model.dart`

| Valeur | DB Value | Label | Description |
|---|---|---|---|
| `materiel` | `materiel` | Matériel / Fourniture | Coût matériel binaire (acheté / pas acheté) |
| `mainDoeuvre` | `main_doeuvre` | Main d'œuvre | Coût MO progressif (slider 0–100%) |

### LigneChiffrage

**Fichier :** `lib/models/chiffrage_model.dart` — Table : `lignes_chiffrages`

| Champ | Type Dart | Colonne DB | Description |
|---|---|---|---|
| `id` | `String?` | `id` (UUID) | Identifiant |
| `userId` | `String?` | `user_id` | Propriétaire (RLS) |
| `devisId` | `String?` | `devis_id` (FK) | Devis parent |
| `factureId` | `String?` | `facture_id` (FK) | Facture liée (optionnel) |
| `designation` | `String` | `designation` | Désignation du coût |
| `quantite` | `Decimal` | `quantite` | Quantité |
| `unite` | `String` | `unite` | Unité (u, h, m², etc.) |
| `prixAchatUnitaire` | `Decimal` | `prix_achat_unitaire` | Prix d'achat unitaire HT |
| `prixVenteUnitaire` | `Decimal` | `prix_vente_unitaire` | Prix de vente unitaire HT |
| `linkedLigneDevisId` | `String?` | `linked_ligne_devis_id` (FK) | Ligne de devis parente (progress billing) |
| `typeChiffrage` | `TypeChiffrage` | `type_chiffrage` | `materiel` ou `main_doeuvre` |
| `estAchete` | `bool` | `est_achete` | Matériel acheté (toggle binaire) |
| `avancementMo` | `Decimal` | `avancement_mo` | Avancement main d'œuvre 0–100% |
| `prixVenteInterne` | `Decimal` | `prix_vente_interne` | Prix vente interne (poids dans l'avancement) |

**Getters calculés :**

| Getter | Type | Description |
|---|---|---|
| `totalAchat` | `Decimal` | `quantite × prixAchatUnitaire` |
| `totalVente` | `Decimal` | `quantite × prixVenteUnitaire` |
| `valeurRealisee` | `Decimal` | Matériel : `estAchete ? prixVenteInterne : 0` / MO : `prixVenteInterne × avancementMo / 100` |
| `avancementPourcent` | `Decimal` | Matériel : `estAchete ? 100 : 0` / MO : `avancementMo` |

**Méthodes :** `fromMap(Map)`, `toMap()`, `copyWith(...)`

---

## Repositories

### IFactureRepository

**Fichier :** `lib/repositories/facture_repository.dart`

| Méthode | Retour | Description |
|---|---|---|
| `getFactures()` | `Future<List<Facture>>` | Toutes les factures avec lignes et paiements |
| `getFacture(String id)` | `Future<Facture>` | Facture par ID avec relations |
| `createFacture(Facture, List<LigneFacture>)` | `Future<Facture>` | Crée facture + lignes |
| `updateFacture(Facture, List<LigneFacture>)` | `Future<void>` | Met à jour facture + recrée lignes |
| `deleteFacture(String id)` | `Future<void>` | Supprime facture et lignes |
| `validateFacture(String id)` | `Future<void>` | Passe en statut validée |
| `markAsSent(String id)` | `Future<void>` | Passe en statut envoyée |
| `addPaiement(Paiement)` | `Future<void>` | Ajoute un paiement |
| `deletePaiement(String id)` | `Future<void>` | Supprime un paiement |
| `createAvoir(Facture, List<LigneFacture>)` | `Future<Facture>` | Crée un avoir lié |
| `archiveFacture(String id)` | `Future<void>` | Marque comme archivée |
| `unarchiveFacture(String id)` | `Future<void>` | Désarchive |
| `uploadSignature(String path, Uint8List)` | `Future<String?>` | Upload signature |
| `getChiffreAffaires(int annee)` | `Future<Decimal>` | CA annuel |
| `getFacturesImpayes()` | `Future<List<Facture>>` | Factures non soldées |

### IDevisRepository

**Fichier :** `lib/repositories/devis_repository.dart`

| Méthode | Retour | Description |
|---|---|---|
| `getDevisList()` | `Future<List<Devis>>` | Tous les devis avec lignes |
| `getDevis(String id)` | `Future<Devis>` | Devis par ID |
| `createDevis(Devis, List<LigneDevis>)` | `Future<Devis>` | Crée devis + lignes |
| `updateDevis(Devis, List<LigneDevis>)` | `Future<void>` | Met à jour devis + lignes |
| `deleteDevis(String id)` | `Future<void>` | Supprime devis et lignes |
| `accepterDevis(String id)` | `Future<void>` | Passe en statut accepté |
| `refuserDevis(String id)` | `Future<void>` | Passe en statut refusé |
| `annulerDevis(String id)` | `Future<void>` | Annule le devis |
| `transformerEnFacture(String id)` | `Future<String>` | Crée facture depuis devis |
| `creerAvenant(String devisParentId)` | `Future<Devis>` | Crée un avenant |
| `uploadSignature(String path, Uint8List)` | `Future<String?>` | Upload signature |

### IClientRepository

**Fichier :** `lib/repositories/client_repository.dart`

| Méthode | Retour | Description |
|---|---|---|
| `getClients()` | `Future<List<Client>>` | Tous les clients |
| `getClient(String id)` | `Future<Client>` | Client par ID |
| `createClient(Client)` | `Future<Client>` | Crée un client |
| `updateClient(Client)` | `Future<void>` | Met à jour un client |
| `deleteClient(String id)` | `Future<void>` | Supprime un client |
| `searchClients(String query)` | `Future<List<Client>>` | Recherche textuelle |

### IDashboardRepository

**Fichier :** `lib/repositories/dashboard_repository.dart`

| Méthode | Retour | Description |
|---|---|---|
| `getFactures()` | `Future<List<Facture>>` | Factures pour calculs KPI |
| `getDevis()` | `Future<List<Devis>>` | Devis pour statistiques |
| `getClients()` | `Future<List<Client>>` | Clients pour top clients |
| `getDepenses()` | `Future<List<Depense>>` | Dépenses pour graphiques |
| `getRecentActivity()` | `Future<List<Map>>` | Activité récente cross-table |

### IEntrepriseRepository

**Fichier :** `lib/repositories/entreprise_repository.dart`

| Méthode | Retour | Description |
|---|---|---|
| `getProfil()` | `Future<ProfilEntreprise?>` | Profil de l'entreprise connectée |
| `saveProfil(ProfilEntreprise)` | `Future<void>` | Crée ou met à jour le profil |
| `uploadLogo(Uint8List)` | `Future<String?>` | Upload logo entreprise |

### IDepenseRepository

| Méthode | Retour | Description |
|---|---|---|
| `getDepenses()` | `Future<List<Depense>>` | Toutes les dépenses |
| `createDepense(Depense)` | `Future<Depense>` | Crée une dépense |
| `updateDepense(Depense)` | `Future<void>` | Met à jour |
| `deleteDepense(String id)` | `Future<void>` | Supprime |
| `getDepensesByPeriode(DateTime, DateTime)` | `Future<List<Depense>>` | Filtre par période |

### IUrssafRepository

| Méthode | Retour | Description |
|---|---|---|
| `getCotisations()` | `Future<List<CotisationUrssaf>>` | Toutes les cotisations |
| `createCotisation(CotisationUrssaf)` | `Future<void>` | Déclare une cotisation |
| `markAsPaid(String id)` | `Future<void>` | Marque comme payée |
| `getPlafonds()` | `Future<Map<String, Decimal>>` | Plafonds micro-entreprise |

### IArticleRepository

| Méthode | Retour | Description |
|---|---|---|
| `getArticles()` | `Future<List<Article>>` | Tous les articles |
| `createArticle(Article)` | `Future<Article>` | Crée un article |
| `updateArticle(Article)` | `Future<void>` | Met à jour |
| `deleteArticle(String id)` | `Future<void>` | Supprime |
| `searchArticles(String query)` | `Future<List<Article>>` | Recherche |

### IAuthRepository

| Méthode | Retour | Description |
|---|---|---|
| `signIn(String email, String password)` | `Future<void>` | Connexion |
| `signUp(String email, String password)` | `Future<void>` | Inscription |
| `signOut()` | `Future<void>` | Déconnexion |
| `getCurrentUser()` | `User?` | Utilisateur courant (Supabase Auth) |
| `isAuthenticated` | `bool` | Session active |

### Autres Repositories

| Repository | Interface | Méthodes principales |
|---|---|---|
| `GlobalSearchRepository` | `IGlobalSearchRepository` | `search(String query)` → résultats cross-table |
| `PlanningRepository` | `IPlanningRepository` | CRUD événements calendrier |
| `ShoppingRepository` | `IShoppingRepository` | CRUD items liste courses |

### IFactureRecurrenteRepository

**Fichier :** `lib/repositories/facture_recurrente_repository.dart`

| Méthode | Retour | Description |
|---|---|---|
| `getFacturesRecurrentes()` | `Future<List<FactureRecurrente>>` | Toutes les factures récurrentes avec lignes |
| `createFactureRecurrente(FactureRecurrente, List<LigneFactureRecurrente>)` | `Future<FactureRecurrente>` | Crée une facture récurrente + lignes |
| `updateFactureRecurrente(FactureRecurrente, List<LigneFactureRecurrente>)` | `Future<void>` | Met à jour |
| `deleteFactureRecurrente(String id)` | `Future<void>` | Supprime |
| `toggleActive(String id, bool estActive)` | `Future<void>` | Active/désactive |
| `incrementCompteur(String id)` | `Future<void>` | Incrémente le compteur de génération |

### ITempsRepository

**Fichier :** `lib/repositories/temps_repository.dart`

| Méthode | Retour | Description |
|---|---|---|
| `getTempsActivites()` | `Future<List<TempsActivite>>` | Toutes les entrées de temps |
| `createTempsActivite(TempsActivite)` | `Future<TempsActivite>` | Crée une entrée |
| `updateTempsActivite(TempsActivite)` | `Future<void>` | Met à jour |
| `deleteTempsActivite(String id)` | `Future<void>` | Supprime |
| `getByPeriode(DateTime debut, DateTime fin)` | `Future<List<TempsActivite>>` | Filtre par période |
| `marquerFacture(String id, String factureId)` | `Future<void>` | Lie à une facture |

### IRappelRepository

**Fichier :** `lib/repositories/rappel_repository.dart`

| Méthode | Retour | Description |
|---|---|---|
| `getRappels()` | `Future<List<Rappel>>` | Tous les rappels |
| `createRappel(Rappel)` | `Future<Rappel>` | Crée un rappel |
| `updateRappel(Rappel)` | `Future<void>` | Met à jour |
| `deleteRappel(String id)` | `Future<void>` | Supprime |
| `completerRappel(String id)` | `Future<void>` | Marque comme complété |
| `createMany(List<Rappel>)` | `Future<void>` | Crée plusieurs rappels (génération batch) |

### IChiffrageRepository

**Fichier :** `lib/repositories/chiffrage_repository.dart`

| Méthode | Retour | Description |
|---|---|---|
| `getByDevisId(String devisId)` | `Future<List<LigneChiffrage>>` | Toutes les lignes de chiffrage d'un devis |
| `getByLigneDevisId(String ligneDevisId)` | `Future<List<LigneChiffrage>>` | Lignes liées à une ligne de devis spécifique |
| `create(LigneChiffrage)` | `Future<LigneChiffrage>` | Crée une ligne de chiffrage (retourne avec ID) |
| `update(LigneChiffrage)` | `Future<void>` | Met à jour une ligne complète (auto-save) |
| `updateEstAchete(String id, bool)` | `Future<void>` | Toggle rapide statut d'achat matériel |
| `updateAvancementMo(String id, Decimal)` | `Future<void>` | Mise à jour slider avancement MO |
| `delete(String id)` | `Future<void>` | Supprime une ligne de chiffrage |
| `deleteAllForDevis(String devisId)` | `Future<void>` | Supprime toutes les lignes d'un devis |

---

## ViewModels

### FactureViewModel

**Fichier :** `lib/viewmodels/facture_viewmodel.dart` (458 lignes)
**Mixins :** `PdfGenerationMixin`, `AutoSaveMixin`
**Repository :** `IFactureRepository`

#### État

| Propriété | Type | Description |
|---|---|---|
| `factures` | `List<Facture>` | Liste de toutes les factures |
| `selectedFacture` | `Facture?` | Facture en cours d'édition |
| `isLoading` | `bool` | Opération en cours |
| `error` | `String?` | Dernière erreur |
| `pdfBytes` | `Uint8List?` | PDF généré (via mixin) |

#### Méthodes publiques

| Méthode | Retour | Description |
|---|---|---|
| `loadFactures()` | `Future<void>` | Charge toutes les factures |
| `loadFacture(String id)` | `Future<void>` | Charge une facture par ID |
| `createFacture(Facture, List<LigneFacture>)` | `Future<bool>` | Crée une facture + lignes |
| `updateFacture(Facture, List<LigneFacture>)` | `Future<bool>` | Met à jour facture + lignes |
| `deleteFacture(String id)` | `Future<bool>` | Supprime une facture |
| `validateFacture(String id)` | `Future<bool>` | Valide (brouillon → validée) |
| `markAsSent(String id)` | `Future<bool>` | Marque comme envoyée |
| `addPaiement(Paiement)` | `Future<bool>` | Ajoute un paiement |
| `deletePaiement(String id)` | `Future<bool>` | Supprime un paiement |
| `createAvoir(Facture source, String motif)` | `Future<bool>` | Crée un avoir correctif |
| `archiveFacture(String id)` | `Future<bool>` | Archive la facture |
| `unarchiveFacture(String id)` | `Future<bool>` | Désarchive |
| `uploadSignature(Uint8List bytes)` | `Future<bool>` | Upload signature |
| `generatePdf(Facture, Client, ProfilEntreprise)` | `Future<Uint8List?>` | Génère le PDF |
| `getChiffreAffaires(int annee)` | `Future<Decimal>` | CA de l'année |
| `getFacturesImpayes()` | `List<Facture>` | Factures non soldées |
| `getFacturesByStatut(String statut)` | `List<Facture>` | Filtre par statut |

### DevisViewModel

**Fichier :** `lib/viewmodels/devis_viewmodel.dart` (458 lignes)
**Mixins :** `PdfGenerationMixin`, `AutoSaveMixin`
**Repository :** `IDevisRepository`

#### État

| Propriété | Type | Description |
|---|---|---|
| `devisList` | `List<Devis>` | Liste de tous les devis |
| `selectedDevis` | `Devis?` | Devis en cours d'édition |
| `pendingDraftFacture` | `Map?` | Données pour transformation devis → facture |

#### Méthodes publiques

| Méthode | Retour | Description |
|---|---|---|
| `loadDevisList()` | `Future<void>` | Charge tous les devis |
| `loadDevis(String id)` | `Future<void>` | Charge un devis par ID |
| `createDevis(Devis, List<LigneDevis>)` | `Future<bool>` | Crée un devis |
| `updateDevis(Devis, List<LigneDevis>)` | `Future<bool>` | Met à jour |
| `deleteDevis(String id)` | `Future<bool>` | Supprime |
| `accepterDevis(String id)` | `Future<bool>` | Marque comme accepté |
| `refuserDevis(String id)` | `Future<bool>` | Marque comme refusé |
| `annulerDevis(String id)` | `Future<bool>` | Annule |
| `transformerEnFacture(String id)` | `Future<bool>` | Transformation devis → facture |
| `creerAvenant(String devisParentId)` | `Future<bool>` | Crée un avenant |
| `checkExpiredDevis()` | `Future<void>` | Vérifie les devis expirés |
| `generatePdf(Devis, Client, ProfilEntreprise)` | `Future<Uint8List?>` | Génère le PDF |
| `uploadSignature(Uint8List bytes)` | `Future<bool>` | Upload signature |
| `prepareFacture(Devis, String type, Decimal, bool, {Decimal? dejaRegle, Map<String, Decimal>? avancementsChiffrage})` | `Facture` | Prépare une facture depuis un devis (acompte/situation/solde). `avancementsChiffrage` injecte les avancements du progress billing |

### DashboardViewModel

**Fichier :** `lib/viewmodels/dashboard_viewmodel.dart` (390 lignes)
**Repositories :** `IDashboardRepository`, `IFactureRepository`

#### État

| Propriété | Type | Description |
|---|---|---|
| `caTotal` | `Decimal` | Chiffre d'affaires total |
| `caMensuel` | `Map<int, Decimal>` | CA par mois |
| `nbFactures` | `int` | Nombre total de factures |
| `nbDevis` | `int` | Nombre total de devis |
| `nbClients` | `int` | Nombre total de clients |
| `tauxConversion` | `double` | Taux de conversion devis → facture |
| `topClients` | `List<MapEntry>` | Top clients par CA |
| `facturesEnRetard` | `List<Facture>` | Factures en retard de paiement |
| `analyseTva` | `AnalyseTva?` | Analyse seuils TVA |
| `relancesEnCours` | `List<RelanceInfo>` | Relances à effectuer |
| `suggestionsArchivage` | `List<Facture>` | Factures archivables |
| `depensesParCategorie` | `Map<String, Decimal>` | Ventilation dépenses |

#### Méthodes publiques

| Méthode | Retour | Description |
|---|---|---|
| `loadDashboard()` | `Future<void>` | Charge toutes les données du dashboard |
| `refreshKpis()` | `Future<void>` | Rafraîchit les KPIs uniquement |
| `getFacturesParMois(int annee)` | `Map<int, Decimal>` | CA ventilé par mois |
| `getTopClients(int limit)` | `List<MapEntry>` | Top N clients |
| `analyserTva()` | `AnalyseTva` | Calcule l'analyse TVA |
| `analyserRelances()` | `List<RelanceInfo>` | Détecte les relances |
| `detecterArchivage()` | `List<Facture>` | Détecte les factures archivables |

### Autres ViewModels

| ViewModel | Méthodes principales |
|---|---|
| `ClientViewModel` | `loadClients()`, `createClient()`, `updateClient()`, `deleteClient()`, `searchClients()` |
| `DepenseViewModel` | `loadDepenses()`, `createDepense()`, `updateDepense()`, `deleteDepense()`, `filterByPeriode()` |
| `EntrepriseViewModel` | `loadProfil()`, `saveProfil()`, `uploadLogo()`, `isOnboardingComplete` |
| `UrssafViewModel` | `loadCotisations()`, `declarerCotisation()`, `calculerMontant()`, `getPlafonds()` |
| `ArticleViewModel` | `loadArticles()`, `createArticle()`, `updateArticle()`, `deleteArticle()`, `searchArticles()` |
| `AuthViewModel` | `signIn()`, `signUp()`, `signOut()`, `checkSession()`, `isAuthenticated` |
| `RelanceViewModel` | `loadRelances()`, `envoyerRelance()`, `analyserRelances()` |
| `GlobalSearchViewModel` | `search(String query)`, `results`, `isSearching` |
| `PlanningViewModel` | `loadEvents()`, `createEvent()`, `updateEvent()`, `deleteEvent()` |
| `ShoppingViewModel` | `loadItems()`, `addItem()`, `toggleItem()`, `deleteItem()` |
| `CorbeilleViewModel` | `loadAll()`, `restoreFacture()`, `restoreDevis()`, `restoreClient()`, `restoreDepense()`, `supprimerDefinitivement()` |
| `FactureRecurrenteViewModel` | `loadRecurrentes()`, `createRecurrente()`, `updateRecurrente()`, `deleteRecurrente()`, `toggleActive()`, `genererFacture()` |
| `TempsViewModel` | `loadTemps()`, `createTemps()`, `updateTemps()`, `deleteTemps()`, `getTotalHeures()`, `getMontantTotal()`, `filterByPeriode()` |
| `RappelViewModel` | `loadRappels()`, `createRappel()`, `updateRappel()`, `deleteRappel()`, `completerRappel()`, `genererRappelsFiscaux()` |
| `RentabiliteViewModel` | `loadDevis()`, `selectDevis()`, `selectLigneDevis()`, `toggleEstAchete()`, `updateAvancementMo()`, `ajouterChiffrage()`, `supprimerChiffrage()`, `updateChiffrage()` |

### RentabiliteViewModel

**Fichier :** `lib/viewmodels/rentabilite_viewmodel.dart` (298 lignes)
**Repositories :** `IChiffrageRepository`, `IDevisRepository`

#### Data Class : LigneDevisAvancement

| Propriété | Type | Description |
|---|---|---|
| `ligne` | `LigneDevis` | Ligne de devis source |
| `avancement` | `Decimal` | Avancement calculé 0–100% |
| `valeurRealisee` | `Decimal` | Somme des valeurs réalisées des chiffrages enfants |
| `prixTotal` | `Decimal` | Prix total de la ligne (quantité × prix unitaire) |
| `chiffrages` | `List<LigneChiffrage>` | Chiffrages rattachés |
| `isComplete` | `bool` | `avancement >= 100` |

#### État

| Propriété | Type | Description |
|---|---|---|
| `devisList` | `List<Devis>` | Devis actifs (non archivés) |
| `selectedDevis` | `Devis?` | Devis sélectionné dans le panneau gauche |
| `selectedLigneDevis` | `LigneDevis?` | Ligne de devis sélectionnée |
| `chiffrages` | `List<LigneChiffrage>` | Chiffrages du devis sélectionné |
| `avancements` | `Map<String, Decimal>` | Avancement par ligneDevisId (0–100) |
| `avancementGlobal` | `Decimal` | Avancement global du devis |
| `expandedDevisIds` | `Set<String>` | IDs des devis expandus dans l'arbre |
| `isDirty` | `bool` | Changements en attente de sauvegarde |

#### Méthodes publiques

| Méthode | Retour | Description |
|---|---|---|
| `loadDevis()` | `Future<void>` | Charge tous les devis actifs |
| `selectDevis(Devis)` | `Future<void>` | Sélectionne un devis et charge ses chiffrages |
| `toggleDevisExpanded(String id)` | `void` | Toggle expansion dans le panneau gauche |
| `selectLigneDevis(LigneDevis)` | `void` | Sélectionne une ligne pour le panneau droit |
| `ajouterChiffrage(LigneChiffrage)` | `Future<bool>` | Ajoute un coût lié à la ligne sélectionnée |
| `supprimerChiffrage(String id)` | `Future<bool>` | Supprime un coût |
| `toggleEstAchete(String id)` | `void` | Toggle achat matériel (auto-save immédiat) |
| `updateAvancementMo(String id, Decimal)` | `void` | Met à jour avancement MO (auto-save debounce 400ms) |
| `updateChiffrage(LigneChiffrage)` | `Future<bool>` | Met à jour un chiffrage complet |
| `getAvancementsForFactureSituation()` | `Map<String, Decimal>` | Map avancements pour facturation de situation |

#### Getters calculés

| Getter | Type | Description |
|---|---|---|
| `chiffragesForSelectedLigne` | `List<LigneChiffrage>` | Chiffrages filtrés pour la ligne sélectionnée |
| `lignesAvancement` | `List<LigneDevisAvancement>` | Avancements détaillés de chaque ligne (exclut titres/sous-titres) |

---

## Services

### TvaService

**Fichier :** `lib/services/tva_service.dart`

| Méthode | Signature | Description |
|---|---|---|
| `analyserActivite` | `static StatutTva analyserActivite(Decimal caYtd, String typeActivite)` | Analyse le statut TVA d'une activité |
| `analyser` | `static AnalyseTva analyser(Decimal caService, Decimal caCommerce)` | Analyse complète service + commerce |
| `calculerCaYtd` | `static BilanTva calculerCaYtd(List<Facture> factures, int annee)` | Calcule le CA year-to-date par type d'activité |
| `simulerAvecMontant` | `static AnalyseTva simulerAvecMontant(AnalyseTva current, Decimal montant, String type)` | Simule l'impact d'un montant sur les seuils |

**Types retournés :**

- `StatutTva` : enum `sousFranchise`, `approcheSeuil`, `depassementBasSeuil`, `depassementHautSeuil`
- `AnalyseTva` : `{ statutService, statutCommerce, caService, caCommerce, seuilService, seuilCommerce, pourcentageService, pourcentageCommerce }`
- `BilanTva` : `{ caService, caCommerce, caTotal }`

**Seuils légaux :**

| Type | Franchise | Majoration |
|---|---|---|
| Service | 36 800 € | 39 100 € |
| Commerce | 91 900 € | 101 000 € |

### RelanceService

**Fichier :** `lib/services/relance_service.dart`

| Méthode | Signature | Description |
|---|---|---|
| `analyserRelances` | `static List<RelanceInfo> analyserRelances(List<Facture> factures)` | Détecte toutes les factures nécessitant une relance |
| `genererTexteRelance` | `static String genererTexteRelance(RelanceInfo relance, ProfilEntreprise profil)` | Génère le texte de la relance (email) |

**Niveaux de relance :**

| Niveau | Délai | Ton |
|---|---|---|
| `relance1` | J+7 | Courtois — rappel de paiement |
| `relance2` | J+15 | Ferme — seconde relance |
| `relance3` | J+30 | Dernier avertissement |
| `miseDemeure` | J+45 | Mise en demeure formelle |

### ArchivageService

**Fichier :** `lib/services/archivage_service.dart`

| Méthode | Signature | Description |
|---|---|---|
| `detecterArchivables` | `static List<Facture> detecterArchivables(List<Facture> factures)` | Factures soldées + non archivées + > 12 mois |

### EmailService

**Fichier :** `lib/services/email_service.dart`

| Méthode | Signature | Description |
|---|---|---|
| `envoyerDevis` | `static Future<EmailResult> envoyerDevis(Devis, Client, ProfilEntreprise)` | Ouvre mailto: pour envoi devis |
| `envoyerFacture` | `static Future<EmailResult> envoyerFacture(Facture, Client, ProfilEntreprise)` | Ouvre mailto: pour envoi facture |
| `envoyerRelance` | `static Future<EmailResult> envoyerRelance(RelanceInfo, Client, ProfilEntreprise)` | Ouvre mailto: pour relance |

Retourne `EmailResult` : `{ success: bool, message: String }`

### AuditService

**Fichier :** `lib/services/audit_service.dart`

| Méthode | Signature | Description |
|---|---|---|
| `logEnvoiEmail` | `static Future<void> logEnvoiEmail(String userId, String recordId, String type)` | Log envoi email dans audit_logs |
| `logRelance` | `static Future<void> logRelance(String userId, String recordId, int niveau)` | Log relance dans audit_logs |

**Fail-safe :** catch all — ne lance jamais d'exception

### ExportService

**Fichier :** `lib/services/export_service.dart`

| Méthode | Signature | Description |
|---|---|---|
| `exportComptabilite` | `static Future<void> exportComptabilite(List<Facture>, List<Depense>)` | Exporte 2 CSV (recettes + dépenses) |
| `exportFactures` | `static Future<void> exportFactures(List<Facture>)` | CSV de toutes les factures |
| `exportDepenses` | `static Future<void> exportDepenses(List<Depense>)` | CSV de toutes les dépenses |

### PdfService

**Fichier :** `lib/services/pdf_service.dart`

| Méthode | Signature | Description |
|---|---|---|
| `generatePdf` | `static Future<Uint8List> generatePdf(PdfGenerationRequest request)` | Génère un PDF à partir d'un request objet |

**PdfGenerationRequest :**

```dart
class PdfGenerationRequest {
  final dynamic document;       // Facture ou Devis
  final Client client;
  final ProfilEntreprise profil;
  final List<dynamic> lignes;   // LigneFacture ou LigneDevis
  final List<Facture> facturesPrecedentes; // Factures précédentes (situations/acomptes) pour déductions PDF
}
```

**Facturation de situation (2 blocs PDF) :**
Quand `facturesPrecedentes` n'est pas vide, le PDF affiche :
1. **Bloc 1 — Travaux à date** : lignes avec avancements individuels
2. **Bloc 2 — Déductions** : factures/acomptes précédents déduits du total

### PdfThemeBase

**Fichier :** `lib/services/pdf_themes/pdf_theme_base.dart`

| Méthode | Type | Description |
|---|---|---|
| `buildHeader(...)` | **abstract** | En-tête du PDF (logo, infos entreprise) |
| `buildAddresses(...)` | **abstract** | Bloc adresses émetteur/destinataire |
| `buildTitle(...)` | **abstract** | Titre du document (FACTURE, DEVIS, etc.) |
| `buildHeaderCell(...)` | concrète | Cellule d'en-tête de tableau |
| `buildSectionTitle(...)` | concrète | Titre de section |
| `buildLineTable(...)` | concrète | Tableau des lignes |
| `buildTotals(...)` | concrète | Bloc totaux (HT, TVA, TTC) |
| `buildFooter(...)` | concrète | Pied de page (mentions légales) |
| `setCustomPrimaryColor(String hex)` | concrète | Change la couleur primaire |
| `primaryColor` | `PdfColor` | Couleur primaire du thème |

**Implémentations :** `ClassiqueTheme`, `ModerneTheme`, `MinimalisteTheme`

### LocalStorageService

**Fichier :** `lib/services/local_storage_service.dart`

| Méthode | Signature | Description |
|---|---|---|
| `saveDraft` | `static Future<void> saveDraft(String key, Map<String, dynamic> data)` | Sauvegarde brouillon en JSON |
| `getDraft` | `static Future<Map<String, dynamic>?> getDraft(String key)` | Récupère un brouillon |
| `clearDraft` | `static Future<void> clearDraft(String key)` | Supprime un brouillon |
| `generateKey` | `static String generateKey(String type, [String? id])` | Génère la clé de stockage |

### PreferencesService

**Fichier :** `lib/services/preferences_service.dart`

| Méthode | Signature | Description |
|---|---|---|
| `getConfigCharges` | `static Future<ConfigCharges> getConfigCharges()` | Récupère la config charges sociales |
| `saveConfigCharges` | `static Future<void> saveConfigCharges(ConfigCharges config)` | Sauvegarde la config |
| `resetConfigCharges` | `static Future<void> resetConfigCharges()` | Réinitialise aux valeurs par défaut |

### EcheanceService

**Fichier :** `lib/services/echeance_service.dart`

| Méthode | Signature | Description |
|---|---|---|
| `genererTousRappels` | `static List<Rappel> genererTousRappels({int annee, bool urssafTrimestriel, bool tvaApplicable, List<Facture>?, List<Devis>?})` | Génère tous les rappels fiscaux et commerciaux pour une année |

**Rappels générés :**

| Type | Fréquence | Description |
|---|---|---|
| URSSAF | Mensuel ou trimestriel | Déclarations selon config entreprise |
| CFE | Annuel (15 décembre) | Cotisation foncière des entreprises |
| Impôts | Mensuel ou trimestriel | Versement libératoire |
| TVA | Mensuel (si applicable) | Déclaration TVA |
| Factures échues | Automatique | Rappels pour factures impayées |
| Devis expirants | Automatique | Alertes devis proches expiration |

---

## Utilitaires

### CalculationsUtils

**Fichier :** `lib/utils/calculations_utils.dart`

| Méthode | Signature | Description |
|---|---|---|
| `calculateLineTotal` | `static Decimal calculateLineTotal(Decimal prix, Decimal qte, Decimal avancement)` | Total HT d'une ligne |
| `calculateDiscount` | `static Decimal calculateDiscount(Decimal totalHt, Decimal taux)` | Montant de la remise |
| `calculateTva` | `static Decimal calculateTva(Decimal montantHt, Decimal tauxTva)` | Montant TVA |
| `calculateCharges` | `static Decimal calculateCharges(Decimal base, Decimal taux)` | Charges sociales |
| `calculateNet` | `static Decimal calculateNet(Decimal brut, Decimal charges)` | Net après charges |
| `calculateTotalHt` | `static Decimal calculateTotalHt(List<LigneFacture> lignes)` | Total HT de toutes les lignes |
| `calculateTotalTva` | `static Decimal calculateTotalTva(List<LigneFacture> lignes)` | Total TVA de toutes les lignes |
| `calculateTotalTtc` | `static Decimal calculateTotalTtc(Decimal ht, Decimal tva)` | Total TTC |
| `calculateLigneDevisAvancement` | `static Decimal calculateLigneDevisAvancement({List<LigneChiffrage> chiffrageEnfants, Decimal prixTotalLigneDevis})` | Avancement d'une ligne de devis (0–100%) à partir de ses chiffrages enfants |
| `calculateDevisAvancementGlobal` | `static Decimal calculateDevisAvancementGlobal({List<LigneChiffrage> tousChiffrages})` | Avancement global pondéré d'un devis (Σ valeurRealisée / Σ prixVenteInterne × 100) |
| `calculateAllLignesAvancement` | `static Map<String, Decimal> calculateAllLignesAvancement({List<dynamic> lignesDevis, List<LigneChiffrage> tousChiffrages})` | Map ligneDevisId → avancement pour toutes les lignes d'un devis |
| `calculateTotalBrutTravauxADate` | `static Decimal calculateTotalBrutTravauxADate(List<dynamic> lignesFacture)` | Total brut des travaux à date pour une facture de situation |
| `generateDeductionLines` | `static List<Map<String, dynamic>> generateDeductionLines({List<dynamic> facturesPrecedentes})` | Génère les lignes de déduction (acomptes/situations précédentes) pour le PDF |

> **Règle absolue :** Division → `.toDecimal()` obligatoire. Multiplication → pas de `.toDecimal()`.

### FormatUtils

**Fichier :** `lib/utils/format_utils.dart`

| Méthode | Signature | Description |
|---|---|---|
| `formatCurrency` | `static String formatCurrency(Decimal montant)` | "1 234,56 €" |
| `formatDate` | `static String formatDate(DateTime date)` | "15/02/2026" |
| `formatDateLong` | `static String formatDateLong(DateTime date)` | "15 février 2026" |
| `formatNumero` | `static String formatNumero(String numero)` | Formatage numéro document |
| `formatPercentage` | `static String formatPercentage(Decimal taux)` | "21,00 %" |

### ValidationUtils

**Fichier :** `lib/utils/validation_utils.dart`

| Méthode | Signature | Description |
|---|---|---|
| `validateRequired` | `static String? validateRequired(String? value, String field)` | Champ obligatoire |
| `validateEmail` | `static String? validateEmail(String? value)` | Format email valide |
| `validateSiret` | `static String? validateSiret(String? value)` | SIRET 14 chiffres |
| `validatePhone` | `static String? validatePhone(String? value)` | Téléphone français |
| `validatePositiveDecimal` | `static String? validatePositiveDecimal(String? value, String field)` | Nombre positif |
| `validateCodePostal` | `static String? validateCodePostal(String? value)` | Code postal 5 chiffres |
| `validateIban` | `static String? validateIban(String? value)` | Format IBAN |
| `validateTvaIntra` | `static String? validateTvaIntra(String? value)` | Numéro TVA intracommunautaire |
