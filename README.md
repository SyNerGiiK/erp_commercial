# ERP Artisan 3.0 — SaaS de Gestion Commerciale

[![Flutter](https://img.shields.io/badge/Flutter-3.38.9-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.8-blue?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-green?logo=supabase)](https://supabase.com)
[![Tests](https://img.shields.io/badge/Tests-385%20passed-brightgreen)]()
[![Analyze](https://img.shields.io/badge/Analyze-0%20issues-brightgreen)]()

**ERP Artisan** est une solution SaaS moderne développée en **Flutter Web**, conçue pour simplifier la gestion quotidienne des **artisans, micro-entrepreneurs et TPE du bâtiment**.

L'application couvre l'intégralité du cycle commercial : Clients, Devis, Factures, Acomptes, Avoirs, Paiements, Dépenses, Planning, Relances, Tableaux de bord financiers et Suivi URSSAF.

---

## Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Stack Technique](#-stack-technique)
- [Architecture](#-architecture)
- [Structure du Projet](#-structure-du-projet)
- [Modèles de Données](#-modèles-de-données)
- [Services](#-services)
- [Utilitaires](#-utilitaires)
- [Routes & Navigation](#-routes--navigation)
- [Sécurité & Conformité](#-sécurité--conformité)
- [Tests](#-tests)
- [Installation & Démarrage](#-installation--démarrage)
- [Changelog — Optimisation Février 2026](#-changelog--optimisation-février-2026)

---

## 🚀 Fonctionnalités

### 📄 Gestion Commerciale Complète

| Module | Description |
|--------|-------------|
| **Clients** | Fichier client complet (particulier/professionnel), SIRET, TVA intra, notes privées |
| **Devis** | Création par stepper 4 étapes, calculs automatiques HT/TVA/TTC, remises, acomptes |
| **Factures** | Cycle complet brouillon → validée → envoyée → payée, paiements partiels, historique |
| **Acomptes** | Gestion native déduite automatiquement du solde facture |
| **Avoirs** | Création d'avoir depuis une facture validée avec inversion automatique des montants |
| **Duplication** | Duplication en 1 clic de devis et factures (copie brouillon avec nouvelles dates) |
| **Dépenses** | Suivi des dépenses professionnelles par catégorie |
| **Articles** | Bibliothèque de produits/services réutilisables pour saisie rapide |
| **Liste de courses** | Gestion des achats matériaux avec calcul des quantités |

### 🎨 Éditeur de Documents Riche

- **Mise en page avancée** : Titres, sous-titres, textes libres, sauts de page, lignes de chiffrage
- **Formatage** : Gras, italique, souligné par ligne
- **Calculs temps réel** : Aperçu immédiat des totaux, TVA multi-taux, net commercial
- **Rendu PDF** : Génération professionnelle avec logo, couleurs entreprise, mentions légales
- **Signature électronique** : Signature directe à l'écran (tablette/souris)
- **Auto-save** : Sauvegarde automatique des brouillons en local (`SharedPreferences`)

### 📊 Pilotage & Tableau de Bord

- **KPIs Financiers** : CA réalisé, CA en attente, trésorerie, impayés, volume facturation
- **Top Clients** : Classement des meilleurs clients par chiffre d'affaires
- **Graphiques** : Évolution CA mensuel/annuel (`fl_chart`)
- **Répartition dépenses** : Camembert par catégorie
- **Activité récente** : Dernières factures, devis et paiements

### 📅 Planning

- **Calendrier** : Vue mensuelle/semaine/jour (`table_calendar`)
- **Événements manuels** : RDV, chantiers avec CRUD complet
- **Événements auto-générés** : Échéances factures et fin de validité devis
- **Filtres** : Par type (chantier, RDV, facture, devis)

### 💰 Suivi URSSAF & Charges

- **Simulation URSSAF** : Calcul automatique des cotisations micro-entrepreneur
- **Multi-statuts** : Micro-entreprise, TNS, SASU
- **Plafonds** : Suivi des plafonds CA avec alertes
- **Détail par caisse** : Ventilation CIPAV, URSSAF, CSG/CRDS

### 📬 Relances Impayés

- **Analyse automatique** : Détection des factures en retard de paiement
- **4 niveaux de relance** : Amiable (1-14j) → Ferme (15-30j) → Mise en demeure (31-60j) → Contentieux (60j+)
- **Génération de textes** : Courriers professionnels pré-rédigés par niveau
- **Statistiques** : Montant total impayé, retard moyen, répartition par niveau

### 🔍 Recherche Globale

- **5 entités** : Recherche simultanée dans clients, factures, devis, dépenses et articles
- **Recherche temps réel** : Résultats instantanés dès 2 caractères
- **Navigation directe** : Accès en 1 clic au résultat trouvé

### 📤 Export & Archivage

- **Export CSV** : Factures (14 colonnes), devis (12 colonnes), clients (7 colonnes), dépenses (5 colonnes)
- **Archives** : Archivage/désarchivage des documents obsolètes
- **Annulation** : Annulation de devis avec protection des devis signés

---

## 🛠️ Stack Technique

| Composant | Technologie | Version |
|-----------|-------------|---------|
| **Frontend** | Flutter Web | 3.38.9 (Stable) |
| **Langage** | Dart | 3.10.8 |
| **Backend / BDD** | Supabase (PostgreSQL 15+) | ^2.3.0 |
| **State Management** | Provider | ^6.1.1 |
| **Navigation** | GoRouter | ^13.0.0 |
| **Calculs financiers** | Decimal | ^2.3.0 |
| **PDF** | pdf + printing | ^3.10.0 / ^5.11.1 |
| **Graphiques** | fl_chart | ^1.1.1 |
| **Calendrier** | table_calendar | ^3.1.0 |
| **Export** | csv + file_saver | ^6.0.0 / ^0.2.0 |
| **Tests** | flutter_test + mocktail | ^1.0.0 |

---

## 🏗️ Architecture

**Pattern : MVVM + Provider + GoRouter**

```
┌─────────────┐     ┌──────────────┐     ┌──────────────────┐     ┌───────────┐
│   Views     │────▶│  ViewModels  │────▶│  Repositories    │────▶│ Supabase  │
│  (Widgets)  │◀────│ (Provider)   │◀────│  (Interface +    │◀────│ (Backend) │
│             │     │              │     │   Implémentation) │     │           │
└─────────────┘     └──────────────┘     └──────────────────┘     └───────────┘
                           │
                    ┌──────┴──────┐
                    │  Services   │
                    │  (PDF, CSV, │
                    │   Relance)  │
                    └─────────────┘
```

### Principes clés

- **ViewModels** héritent de `BaseViewModel` (extends `ChangeNotifier`) avec pattern `_loadingDepth` réentrant
- **Repositories** : Interface abstraite (`IXxxRepository`) + implémentation concrète pour faciliter les tests
- **Injection** : Les repositories sont injectés via constructeur dans les ViewModels
- **Mixins** : `AutoSaveMixin` (brouillons) et `PdfGenerationMixin` (génération PDF) sur les documents
- **Decimal obligatoire** : Jamais de `double` pour les montants financiers
- **Sécurité async** : `if (!mounted) return;` après chaque `await` dans les widgets

---

## 📁 Structure du Projet

```
lib/                          (~108 fichiers Dart)
├── config/                   # Configuration (4 fichiers)
│   ├── dependency_injection.dart   # 13 Providers enregistrés
│   ├── router.dart                 # 22 routes (GoRouter + auth guard)
│   ├── supabase_config.dart        # Connexion Supabase
│   └── theme.dart                  # Thème Material 3
│
├── core/                     # Classes de base (5 fichiers)
│   ├── base_viewmodel.dart         # ChangeNotifier + loading/error pattern
│   ├── base_repository.dart        # Accès Supabase centralisé
│   ├── document_repository.dart    # Repository abstrait documents
│   ├── autosave_mixin.dart         # Sauvegarde auto brouillons
│   └── pdf_generation_mixin.dart   # Génération PDF partagée
│
├── models/                   # Modèles de données (14 fichiers)
│   ├── article_model.dart          # Article catalogue
│   ├── chiffrage_model.dart        # Ligne de chiffrage (achats/marge)
│   ├── client_model.dart           # Client (particulier/pro)
│   ├── config_charges_model.dart   # Config charges sociales
│   ├── depense_model.dart          # Dépense professionnelle
│   ├── devis_model.dart            # Devis + LigneDevis
│   ├── entreprise_model.dart       # Profil entreprise
│   ├── facture_model.dart          # Facture + LigneFacture
│   ├── paiement_model.dart         # Paiement (partiel/total)
│   ├── photo_model.dart            # Photo chantier
│   ├── planning_model.dart         # Événement planning
│   ├── shopping_model.dart         # Liste de courses
│   ├── urssaf_model.dart           # Déclaration URSSAF
│   └── enums/                      # Énumérations
│
├── repositories/             # Accès données (12 fichiers)
│   ├── article_repository.dart
│   ├── auth_repository.dart
│   ├── client_repository.dart
│   ├── dashboard_repository.dart
│   ├── depense_repository.dart
│   ├── devis_repository.dart
│   ├── entreprise_repository.dart
│   ├── facture_repository.dart
│   ├── global_search_repository.dart
│   ├── planning_repository.dart
│   ├── shopping_repository.dart
│   └── urssaf_repository.dart
│
├── viewmodels/               # Logique métier (13 fichiers)
│   ├── article_viewmodel.dart
│   ├── auth_viewmodel.dart
│   ├── client_viewmodel.dart
│   ├── dashboard_viewmodel.dart
│   ├── depense_viewmodel.dart
│   ├── devis_viewmodel.dart
│   ├── editor_state_provider.dart
│   ├── entreprise_viewmodel.dart
│   ├── facture_viewmodel.dart
│   ├── global_search_viewmodel.dart
│   ├── planning_viewmodel.dart
│   ├── shopping_viewmodel.dart
│   └── urssaf_viewmodel.dart
│
├── services/                 # Services métier (5 fichiers)
│   ├── export_service.dart         # Export CSV multi-entités
│   ├── local_storage_service.dart  # Auto-save brouillons
│   ├── pdf_service.dart            # Génération PDF avec isolates
│   ├── preferences_service.dart    # Préférences utilisateur
│   └── relance_service.dart        # Analyse relances impayés
│
├── utils/                    # Utilitaires (3 fichiers)
│   ├── calculations_utils.dart     # Calculs financiers (Decimal)
│   ├── format_utils.dart           # Formatage FR (monnaie, dates, %)
│   └── validation_utils.dart       # Validation formulaires
│
├── views/                    # Écrans (~31 fichiers)
│   ├── tableau_de_bord_view.dart
│   ├── liste_factures_view.dart
│   ├── liste_devis_view.dart
│   ├── liste_clients_view.dart
│   ├── liste_depenses_view.dart
│   ├── planning_view.dart
│   ├── global_search_view.dart
│   ├── archives_view.dart
│   ├── facture/stepper/            # Stepper facture 4 étapes
│   ├── devis/stepper/              # Stepper devis 4 étapes
│   └── ...
│
├── widgets/                  # Composants réutilisables (~25 fichiers)
│   ├── dashboard/                  # Widgets tableau de bord (8)
│   ├── dialogs/                    # Dialogues spécialisés (4)
│   └── ...                         # Widgets partagés (13)
│
└── main.dart                 # Point d'entrée
```

---

## 📦 Modèles de Données

Tous les modèles implémentent `fromMap()`, `toMap()` et `copyWith()`.

| Modèle | Table Supabase | Description |
|--------|---------------|-------------|
| `Client` | `clients` | Fiche client complète (nom, SIRET, TVA intra, adresse, contact) |
| `Facture` | `factures` | Facture avec lignes, paiements, chiffrage, multi-statut |
| `LigneFacture` | `lignes_factures` | Ligne de facture (description, qté, PU, TVA, formatage) |
| `Paiement` | `paiements` | Paiement partiel/total rattaché à une facture |
| `Devis` | `devis` | Devis avec analyse de rentabilité intégrée |
| `LigneDevis` | `lignes_devis` | Ligne de devis (idem LigneFacture) |
| `LigneChiffrage` | `lignes_chiffrages` | Chiffrage matières (achat, marge, fournisseur) |
| `Depense` | `depenses` | Dépense professionnelle catégorisée |
| `Article` | `articles` | Article catalogue réutilisable |
| `Entreprise` | `entreprises` | Profil entreprise (logo, couleurs, mentions légales) |
| `PlanningEvent` | `planning_events` | Événement calendrier (manuel ou auto-généré) |
| `ShoppingItem` | `shopping_items` | Article liste de courses |
| `UrssafDeclaration` | `urssaf_declarations` | Déclaration trimestrielle URSSAF |
| `ConfigCharges` | — | Configuration charges sociales (model local) |

### Règles Decimal

```dart
// ❌ JAMAIS double pour l'argent
// ✅ TOUJOURS Decimal du package 'decimal'

// Division → retourne Rational → .toDecimal() obligatoire
final prixUnitaire = (totalHt / quantite).toDecimal();

// Multiplication → retourne Decimal → pas de .toDecimal()
final totalLigne = prixUnitaire * quantite;
```

---

## ⚙️ Services

### PdfService
Génération de PDF professionnels pour factures et devis avec :
- Logo et couleurs de l'entreprise
- Calcul des totaux, TVA multi-taux, net commercial
- Mentions légales obligatoires
- Exécution en isolate pour les calculs lourds

### ExportService
Export CSV compatible comptabilité :
- `exportFactures()` — 14 colonnes (n° facture, client, dates, montants HT/TVA/TTC, statut...)
- `exportDevis()` — 12 colonnes
- `exportClients()` — 7 colonnes
- `exportDepenses()` — 5 colonnes

### RelanceService
Gestion automatisée des impayés :
- `analyserRelances(factures, clients)` — Détecte et classe les factures en retard
- `getStatistiquesRelances(relances)` — Montant total, retard moyen, répartition par niveau
- `genererTexteRelance(relance)` — Texte professionnel adapté au niveau (amiable → contentieux)

### LocalStorageService
Sauvegarde automatique des brouillons en cours d'édition via `SharedPreferences`.

### PreferencesService
Gestion des préférences utilisateur (thème, paramètres d'affichage).

---

## 🔧 Utilitaires

### CalculationsUtils
Calculs financiers avec précision `Decimal` :
- `calculateHT`, `calculateTVA`, `calculateTTC` — Calculs de base
- `calculateCharges` — Calcul des charges sur un montant
- `calculateNetCommercial` — HT après remise commerciale
- `calculateResteAPayer` — Solde restant dû (TTC - acompte - paiements)
- `calculateTauxMarge` — Marge en % entre prix vente et prix achat
- `calculateTotalTva` — TVA totale multi-taux depuis liste de lignes
- `roundDecimal` — Arrondi configurable à N décimales

### FormatUtils
Formatage locale française (`fr_FR`) :
- `currency(value)` — Format monétaire (1 250,50 €)
- `amount(Decimal)` — Format montant compact
- `percentage(value)` — Format pourcentage (12,50 %)
- `phone(String)` — Format téléphone français
- `shortDate(DateTime)` — Date courte (17/02/2026)
- `monthYear(DateTime)` — Mois et année (Février 2026)
- `relativeDate(DateTime)` — Date relative (il y a 3 jours, dans 2h...)
- `truncate(String, maxLength)` — Troncature avec ellipsis

### ValidationUtils
12 validateurs pour formulaires Flutter :
- `validateEmail` / `validateEmailRequired` — Email optionnel/obligatoire
- `validatePhone` / `validatePhoneRequired` — Téléphone français
- `validateSiret` — SIRET 14 chiffres
- `validateTvaIntra` — TVA intracommunautaire (FR + 11 chiffres)
- `validateRequired(value, fieldName)` — Champ obligatoire
- `validateMontant(value, allowZero)` — Montant Decimal positif
- `validateCodePostal` — Code postal français 5 chiffres
- `validateDateEcheance(echeance, emission)` — Date postérieure à émission
- `validatePourcentage` — Valeur entre 0 et 100
- `validateQuantite` — Quantité Decimal strictement positive

---

## 🗺️ Routes & Navigation

**22 routes** gérées par GoRouter avec guard d'authentification.

### Routes publiques
| Route | Vue | Description |
|-------|-----|-------------|
| `/` | `LandingView` | Page d'accueil / marketing |
| `/login` | `LoginView` | Connexion / inscription Supabase Auth |

### Routes privées (`/app/*`)
| Route | Vue | Description |
|-------|-----|-------------|
| `/app/home` | `TableauDeBordView` | Dashboard KPIs et graphiques |
| `/app/planning` | `PlanningView` | Calendrier et événements |
| `/app/devis` | `ListeDevisView` | Liste des devis |
| `/app/factures` | `ListeFacturesView` | Liste des factures |
| `/app/clients` | `ListeClientsView` | Liste des clients |
| `/app/depenses` | `ListeDepensesView` | Liste des dépenses |
| `/app/courses` | `ShoppingListView` | Liste de courses |
| `/app/bibliotheque` | `BibliothequePrixView` | Catalogue articles |
| `/app/archives` | `ArchivesView` | Documents archivés |
| `/app/search` | `GlobalSearchView` | Recherche globale 5 entités |
| `/app/parametres` | `SettingsRootView` | Paramètres généraux |
| `/app/config_urssaf` | `ParametresView` | Configuration charges URSSAF |
| `/app/profil` | `ProfilEntrepriseView` | Profil entreprise |
| `/app/ajout_devis` | `DevisStepperView` | Création devis (stepper 4 étapes) |
| `/app/ajout_devis/:id` | `DevisStepperView` | Édition devis existant |
| `/app/ajout_facture` | `FactureStepperView` | Création facture (stepper 4 étapes) |
| `/app/ajout_facture/:id` | `FactureStepperView` | Édition facture existante |
| `/app/ajout_client` | `AjoutClientView` | Création client |
| `/app/ajout_client/:id` | `AjoutClientView` | Édition client existant |
| `/app/ajout_depense` | `AjoutDepenseView` | Création dépense |
| `/app/ajout_depense/:id` | `AjoutDepenseView` | Édition dépense existante |

---

## 🔐 Sécurité & Conformité

- [x] **RLS (Row Level Security)** : Isolation stricte — chaque utilisateur ne voit que ses propres données
- [x] **Protection Anti-Injection** : Usage exclusif des méthodes Query paramétrées Supabase
- [x] **Droit à l'oubli** : CASCADE DELETE configuré
- [x] **Numérotation certifiée** : Séquences sans trou (conformité anti-fraude TVA)
- [x] **Contraintes SQL** : Prix positifs, emails valides, quantités cohérentes
- [x] **Validation côté client** : `ValidationUtils` avec 12 validateurs
- [x] **Type Safety** : `Decimal` obligatoire pour tous les montants financiers

---

## ✅ Tests

**385 tests — 100% passés** | **0 issue d'analyse statique**

```
flutter test   → 385 tests passed
flutter analyze → No issues found!
```

### Couverture des tests

| Catégorie | Fichiers | Tests | Détail |
|-----------|----------|-------|--------|
| **ViewModels** | 12 | ~280 | CRUD, logique métier, duplication, avoir, relance |
| **Models** | 3 | ~40 | `fromMap`, `toMap`, `copyWith`, getters calculés |
| **Utils** | 3 | ~35 | Calculs Decimal, formatage FR, validation |
| **Services** | 1 | ~25 | RelanceService (niveaux, stats, textes) |
| **Widgets** | 2 | ~5 | Rendu, navigation |
| **Intégration** | 3 | ~10 | Workflows complets (client → devis → facture) |

### Stack de test
- **Framework** : `flutter_test`
- **Mocking** : `mocktail` — Mocks centralisés dans `test/mocks/repository_mocks.dart`
- **Pattern** : Interface repository → Mock → injection constructeur ViewModel

---

## 🏁 Installation & Démarrage

### Pré-requis
- Flutter SDK ≥ 3.2.2
- Compte Supabase configuré avec les tables/RLS

### Configuration

1. Cloner le dépôt
2. Configurer les clés Supabase dans `lib/config/supabase_config.dart` :
   ```dart
   static const String supabaseUrl = 'https://xxx.supabase.co';
   static const String supabaseAnonKey = 'eyJxxx...';
   ```

3. Installer les dépendances :
   ```bash
   flutter pub get
   ```

### Lancer l'application
```bash
flutter run -d chrome
```

### Lancer les tests
```bash
flutter test                 # 385 tests unitaires + intégration
flutter analyze              # Analyse statique (0 issues)
```

---

## 📋 Changelog — Optimisation Février 2026

### Bugs critiques corrigés

| # | Bug | Fichier | Correction |
|---|-----|---------|------------|
| 1 | `getFacturesPeriod` ne filtrait pas par dates | `dashboard_repository.dart` | Ajout filtres `.gte()` / `.lte()` sur `date_emission` |
| 2 | CRUD Planning ne rafraîchissait pas la liste | `planning_viewmodel.dart` | `addEvent`/`updateEvent`/`deleteEvent` re-fetch + `_applyFilters()` |
| 3 | Top Clients retournait une liste vide | `dashboard_viewmodel.dart` | Implémentation calcul CA clients depuis paiements |
| 4 | `calculateHistoriqueReglements` contournait le repository | `facture_viewmodel.dart` | Suppression import Supabase, utilisation `_repository.getLinkedFactures()` |

### Nouvelles fonctionnalités

| Fonctionnalité | Fichier(s) | Description |
|----------------|-----------|-------------|
| **Duplication facture** | `facture_viewmodel.dart` | `duplicateFacture()` — Copie brouillon avec nouvelles dates, lignes dupliquées sans ID |
| **Avoir (credit note)** | `facture_viewmodel.dart` | `createAvoir()` — Facture avoir avec montants inversés, référence source |
| **Factures en retard** | `facture_viewmodel.dart` | Getter `facturesEnRetard` + `retardMoyen` (jours moyens de retard) |
| **Duplication devis** | `devis_viewmodel.dart` | `duplicateDevis()` — Copie brouillon avec dates reset |
| **Annulation devis** | `devis_viewmodel.dart` | `annulerDevis()` — Avec protection des devis signés |
| **Recherche 5 entités** | `global_search_repository.dart`, `global_search_viewmodel.dart` | +Dépenses, +Articles, getter `totalResults` |
| **RelanceService** | `relance_service.dart` | Service complet d'analyse des impayés (4 niveaux, textes, stats) |
| **ValidationUtils** | `validation_utils.dart` | 12 validateurs formulaires (email, SIRET, TVA, montant, etc.) |
| **Export CSV enrichi** | `export_service.dart` | 4 exports (factures, devis, clients, dépenses) avec helpers centralisés |

### Enrichissements utilitaires

| Méthode | Fichier | Description |
|---------|---------|-------------|
| `calculateNetCommercial` | `calculations_utils.dart` | HT après remise commerciale |
| `calculateResteAPayer` | `calculations_utils.dart` | Solde dû = TTC - acompte - paiements |
| `calculateTauxMarge` | `calculations_utils.dart` | Marge % entre vente et achat |
| `calculateTotalTva` | `calculations_utils.dart` | TVA totale multi-taux |
| `roundDecimal` | `calculations_utils.dart` | Arrondi à N décimales |
| `amount`, `percentage`, `phone` | `format_utils.dart` | Formatage montant, %, téléphone |
| `shortDate`, `monthYear` | `format_utils.dart` | Dates courtes et mois/année |
| `relativeDate`, `truncate` | `format_utils.dart` | Date relative, troncature texte |

### Corrections d'analyse

- Ajout `const` sur constructeurs `AuthException` dans les tests
- Conversion lambda → déclaration de fonction (`shopping_viewmodel_test.dart`)
- Renommage `mise_en_demeure` → `miseEnDemeure` (convention lowerCamelCase)
- Ajout accolades sur tous les `if` mono-ligne (`format_utils.dart`)
- Utilisation interpolation string au lieu de concaténation (`calculations_utils.dart`)

### Résultat final

```
flutter analyze → No issues found!
flutter test    → 385 tests passed (257 existants + 128 nouveaux)
```

---

*ERP Artisan 3.0 — Dernière mise à jour : 17 février 2026*
