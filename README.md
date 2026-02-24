# CraftOS (Ex-ERP Artisan 3.0) — Le SaaS BTP Ultime

[![Flutter](https://img.shields.io/badge/Flutter-3.38.9-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.8-blue?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-green?logo=supabase)](https://supabase.com)
[![Tests](https://img.shields.io/badge/Tests-662%20passed-brightgreen)]()
[![Analyze](https://img.shields.io/badge/Analyze-0%20issues-brightgreen)]()

**CraftOS** est la source de vérité absolue pour la gestion des artisans, avec un design "Apple", une automatisation "Tesla", et une infrastructure "Zéro" (Full Free Tiers).

L'application couvre 8 modules fondamentaux allant de l'acquisition web au CRM intelligent (OCR, Pappers), la vente "Magique" assistée par l'I.A. Gemini 2.0 Flash, l'encaissement via QR Code SEPA, le pilotage chantier (Progress Billing), jusqu'à l'automatisation intégrale du SAV et de l'infrastructure via Supabase Edge Functions.

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

---

## 🚀 Les 8 Modules Fondamentaux (Édition 2026)

### 🌐 MODULE 0 : L'Écosystème Web (Acquisition)
- Site vitrine **craftos.fr** (Cloudflare Pages / Vercel en Free Tier).
- UX/UI au design System Aurora (Glassmorphism), animations Lottie.

### 🤖 MODULE 1 : Support Client (SAV) Autonome par I.A.
- Support 24/7 in-app via **Gemini 2.0 Flash**.
- **Edge Function Supabase** pour le tri et l'auto-résolution des tickets.
- Escalade vers le God Mode pour les cas complexes.

### 🏗️ MODULE 2 : CRM Magique & OCR
- **Auto-complétion B2B / B2C** : Intégration Pappers (SIRET), Base Adresse Nationale (BAN) et API VIES (TVA Euro).
- **OCR Intelligent** : Scan de tickets compressé, extrait (Marchand, TTC, TVA) via Gemini Flash.

### 💰 MODULE 3 : Le Cycle de Vente (AITISE TON DEVIS)
- **Speech-To-Text** : Création de devis par reconnaissance vocale.
- **IA RAG** : Génération structurelle logique de devis (Titres, Vente, Pose) basée sur le catalogue de l'artisan. Lignes estimées flaguées `is_ai_estimated` avec icône orange (⚠️).
- **Bouclier de Marge** : Alerte si marge nette < 30%.
- **Signature Électronique** : Tactile in-app, stockée sur Supabase Storage.

### 📊 MODULE 4 : Le Cockpit Chantier (Progress Billing)
- **Tableau de bord financier** : Cartes animées (`flutter_animate`), widgets Météo (OpenWeather).
- **Progress Billing** : Arborescence Devis → Lignes → Chiffrage (Split interne Vente / Pose avec curseurs) pour l'optimisation légale des cotisations URSSAF.

### 🏛️ MODULE 5 : Le Moteur Légal & Fiscal
- Gère la comptabilité sans y penser.
- **Sélecteur Régime Fiscal** et **Assistant Échéances** avec injection de rappels automatiques (URSSAF, CFE, TVA).

### 🎨 MODULE 6 : Génération PDF & Encaissement Premium
- Rendu digne d'une multinationale avec 3 thèmes interchangeables.
- **QR Code SEPA (EPC)** : Généré via `qr_flutter` pour un paiement en 1 clic.
- **Badges de Réassurance** : Insertion dynamique RGE / Décennale en bas de facture.

### 🚀 MODULE 7 & 8 : Infrastructure, Offline & GOD MODE
- **Emails en Marque Blanche** : Edge Functions Supabase + Resend.
- **Mode Hors-Ligne** : Cache local via `flutter_secure_storage` et synchro différée.
- **Route Secrète Admin** (`/admin-panel`) par RLS pour piloter le SaaS : métriques DB (RPC), Kanban des tickets SAV, et Tracker de bugs avec surcharge de `FlutterError.onError`.

---

## 🛠️ Stack Technique

| Composant | Technologie | Version |
|-----------|-------------|---------|
| **Frontend** | Flutter Web | 3.38.9 (Stable) |
| **Langage** | Dart | 3.10.8 |
| **Backend / BDD** | Supabase (PostgreSQL 17) | ^2.3.0 |
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
                    │ (PDF, TVA,  │
                    │  Relance,   │
                    │  Archivage) │
                    └─────────────┘
```

### Principes clés

- **ViewModels** héritent de `BaseViewModel` (`lib/core/base_viewmodel.dart`) avec pattern `_loadingDepth` réentrant + `executeOperation()` pour tout appel async
- **Repositories** : interface abstraite `IXxxRepository` + implémentation concrète héritant de `BaseRepository` (`lib/core/base_repository.dart`) avec `prepareForInsert()`/`prepareForUpdate()`
- **Injection** : repositories injectés via constructeur optionnel dans les VMs (`IFactureRepository? repository`) → fallback vers impl concrète. 20 Providers enregistrés dans `lib/config/dependency_injection.dart`
- **Navigation** : GoRouter avec auth guard (redirige `/app/*` → `/login` si non connecté). Objets passés via `state.extra`
- **Mixins** : `AutoSaveMixin` (brouillons SharedPreferences) et `PdfGenerationMixin` (génération PDF) sur DevisViewModel/FactureViewModel
- **Calculs financiers** : 100% `Decimal` (jamais `double` pour l'argent) — référence `lib/utils/calculations_utils.dart`
- **Sécurité async** : `if (!mounted) return;` / `if (!context.mounted) return;` après chaque `await` dans les widgets
- **PDF** : Strategy Pattern — `PdfThemeBase` → `ClassiqueTheme`, `ModerneTheme`, `MinimalisteTheme`. Isolate-ready via `PdfGenerationRequest`

---

## 📁 Structure du Projet

```
lib/                          (155+ fichiers Dart)
├── config/                   # Configuration (4 fichiers)
│   ├── dependency_injection.dart   # 20 Providers enregistrés
│   ├── router.dart                 # ~28 routes (GoRouter + auth guard)
│   ├── supabase_config.dart        # Connexion Supabase
│   └── theme.dart                  # AppTheme Aurora 2030 (glassmorphism + design tokens)
│
├── core/                     # Classes de base (5 fichiers)
│   ├── base_viewmodel.dart         # ChangeNotifier + _loadingDepth + executeOperation
│   ├── base_repository.dart        # prepareForInsert/Update + handleError
│   ├── document_repository.dart    # Repository abstrait documents
│   ├── autosave_mixin.dart         # Sauvegarde auto brouillons
│   └── pdf_generation_mixin.dart   # Génération PDF partagée
│
├── models/                   # Modèles de données (17 fichiers)
│   ├── article_model.dart          # Article catalogue
│   ├── chiffrage_model.dart        # Ligne de chiffrage (achats/marge)
│   ├── client_model.dart           # Client (particulier/pro)
│   ├── config_charges_model.dart   # Config charges sociales
│   ├── depense_model.dart          # Dépense professionnelle
│   ├── devis_model.dart            # Devis + LigneDevis + devise/tauxChange/notesPrivees
│   ├── entreprise_model.dart       # ProfilEntreprise (identité, TVA, PDF, mentions)
│   ├── facture_model.dart          # Facture + LigneFacture + devise/tauxChange/notesPrivees
│   ├── facture_recurrente_model.dart # FactureRecurrente + LigneFactureRecurrente
│   ├── paiement_model.dart         # Paiement (partiel/total, acompte/solde)
│   ├── photo_model.dart            # Photo chantier
│   ├── planning_model.dart         # Événement planning
│   ├── rappel_model.dart           # Rappel (7 types, 4 priorités)
│   ├── shopping_model.dart         # Liste de courses
│   ├── temps_activite_model.dart   # Suivi du temps (durée, taux horaire, CA)
│   ├── urssaf_model.dart           # Déclaration URSSAF + UrssafConfig
│   └── enums/                      # Énumérations (TypeEntreprise, PdfTheme, etc.)
│
├── repositories/             # Accès données (16 fichiers)
│   ├── article_repository.dart     # IArticleRepository + impl
│   ├── auth_repository.dart        # IAuthRepository + impl (Supabase Auth)
│   ├── chiffrage_repository.dart   # IChiffrageRepository + impl (progress billing)
│   ├── client_repository.dart      # IClientRepository + impl
│   ├── dashboard_repository.dart   # IDashboardRepository + impl
│   ├── depense_repository.dart     # IDepenseRepository + impl
│   ├── devis_repository.dart       # IDevisRepository + impl
│   ├── entreprise_repository.dart  # IEntrepriseRepository + impl
│   ├── facture_repository.dart     # IFactureRepository + impl
│   ├── facture_recurrente_repository.dart # IFactureRecurrenteRepository + impl
│   ├── global_search_repository.dart # IGlobalSearchRepository + impl
│   ├── planning_repository.dart    # IPlanningRepository + impl
│   ├── rappel_repository.dart      # IRappelRepository + impl
│   ├── shopping_repository.dart    # IShoppingRepository + impl
│   ├── temps_repository.dart       # ITempsRepository + impl
│   └── urssaf_repository.dart      # IUrssafRepository + impl
│
├── viewmodels/               # Logique métier (20 fichiers)
│   ├── article_viewmodel.dart      # CRUD articles
│   ├── auth_viewmodel.dart         # Auth (login, signup, logout)
│   ├── client_viewmodel.dart       # CRUD clients
│   ├── corbeille_viewmodel.dart    # Corbeille (restore, purge, soft-delete)
│   ├── dashboard_viewmodel.dart    # KPIs, top clients, graphiques, archivage
│   ├── depense_viewmodel.dart      # CRUD dépenses
│   ├── devis_viewmodel.dart        # CRUD devis + duplication + PDF + autosave
│   ├── editor_state_provider.dart  # État éditeur (onglet courant)
│   ├── entreprise_viewmodel.dart   # Profil entreprise + logo/signature
│   ├── facture_viewmodel.dart      # CRUD factures + avoir + duplication + PDF
│   ├── facture_recurrente_viewmodel.dart # CRUD factures récurrentes + toggle actif
│   ├── global_search_viewmodel.dart # Recherche multi-entités
│   ├── planning_viewmodel.dart     # CRUD événements + filtres
│   ├── rappel_viewmodel.dart       # CRUD rappels + génération auto fiscale
│   ├── relance_viewmodel.dart      # Relances impayés + envoi email
│   ├── rentabilite_viewmodel.dart  # Suivi avancement + progress billing + auto-save
│   ├── shopping_viewmodel.dart     # CRUD liste de courses
│   ├── temps_viewmodel.dart        # Suivi temps + CA potentiel + groupement
│   └── urssaf_viewmodel.dart       # Simulation URSSAF + config seuils TVA
│
├── services/                 # Services métier (15 fichiers)
│   ├── archivage_service.dart      # Détection factures archivables (> 12 mois)
│   ├── audit_service.dart          # Logging audit_logs (EMAIL_SENT, RELANCE_SENT)
│   ├── echeance_service.dart       # Génération auto rappels fiscaux (URSSAF, CFE, TVA)
│   ├── email_service.dart          # Envoi email via url_launcher (mailto:)
│   ├── export_service.dart         # Export CSV multi-entités
│   ├── local_storage_service.dart  # Auto-save brouillons (SharedPreferences)
│   ├── pdf_service.dart            # Génération PDF isolate-ready
│   ├── preferences_service.dart    # Préférences utilisateur
│   ├── relance_service.dart        # Analyse relances impayés (4 niveaux)
│   ├── tva_service.dart            # TvaService (StatutTva, AnalyseTva, seuils)
│   └── pdf_themes/                 # Thèmes PDF (Strategy Pattern)
│       ├── pdf_theme_base.dart     # Classe abstraite + couleur custom
│       ├── classique_theme.dart    # Thème classique
│       ├── moderne_theme.dart      # Thème moderne
│       ├── minimaliste_theme.dart  # Thème minimaliste
│       └── pdf_themes.dart         # Barrel export
│
├── utils/                    # Utilitaires (3 fichiers)
│   ├── calculations_utils.dart     # Calculs financiers 100% Decimal
│   ├── format_utils.dart           # Formatage FR (monnaie, dates, %)
│   └── validation_utils.dart       # Validation formulaires (12 validateurs + Luhn SIRET)
│
├── views/                    # Écrans (37 fichiers)
│   ├── tableau_de_bord_view.dart   # Dashboard KPIs + graphiques + widgets
│   ├── liste_factures_view.dart    # Liste factures + actions email/paiement
│   ├── liste_devis_view.dart       # Liste devis + actions envoi/duplication
│   ├── liste_clients_view.dart     # Liste clients + recherche
│   ├── liste_depenses_view.dart    # Liste dépenses
│   ├── planning_view.dart          # Calendrier + événements
│   ├── global_search_view.dart     # Recherche globale 5 entités
│   ├── archives_view.dart          # Documents archivés
│   ├── corbeille_view.dart         # Corbeille soft-delete (4 onglets)
│   ├── relances_view.dart          # Relances impayés + stats + email
│   ├── factures_recurrentes_view.dart # Factures récurrentes + toggle
│   ├── suivi_temps_view.dart       # Suivi du temps + KPIs + saisie
│   ├── rappels_echeances_view.dart # Rappels fiscaux + onglets + génération
│   ├── profil_entreprise_view.dart # 7 sections profil (identité → PDF)
│   ├── onboarding_view.dart        # Assistant 4 étapes première connexion
│   ├── settings_root_view.dart     # Paramètres URSSAF + thème PDF
│   ├── rentabilite_view.dart       # Outil interne chiffrage/rentabilité
│   ├── facture/stepper/            # Stepper facture 4 étapes
│   ├── devis/stepper/              # Stepper devis 4 étapes
│   └── ...                         # Autres vues (client, dépense, login, etc.)
│
├── widgets/                  # Composants réutilisables (33 fichiers)
│   ├── aurora/                     # Widgets Aurora 2030
│   │   ├── glass_container.dart    # Conteneur givré réutilisable (BackdropFilter)
│   │   ├── aurora_background.dart  # Fond mesh gradient ambiant (3 orbes)
│   │   └── glow_icon.dart          # Icône à halo lumineux contextuel
│   ├── base_screen.dart            # Layout responsive avec drawer + AuroraBackground
│   ├── custom_drawer.dart          # Sidebar glassmorphique (BackdropFilter, glow)
│   ├── ligne_editor.dart           # Éditeur de lignes documents
│   ├── tva_alert_banner.dart       # Alerte TVA (seuils approchés/dépassés)
│   ├── dashboard/                  # 11 widgets tableau de bord
│   │   ├── gradient_kpi_card.dart  # KPI premium (ombres colorées, orbe lumineux)
│   │   ├── revenue_chart.dart
│   │   ├── suivi_seuil_tva_card.dart
│   │   ├── factures_retard_card.dart
│   │   ├── archivage_suggestion_card.dart
│   │   └── ...
│   └── dialogs/                    # Dialogues spécialisés (5)
│       ├── chiffrage_dialog.dart        # Dialog chiffrage (MAT/MO, bibliothèque)
│
└── main.dart                 # Point d'entrée

test/                         (43 fichiers)
├── viewmodels/               # 18 tests ViewModels
├── services/                 # 8 tests Services
├── models/                   # 6 tests Models
├── utils/                    # 3 tests Utilitaires
├── widgets/                  # 3 tests Widgets
├── integration/              # 3 tests Workflows
└── mocks/                    # Mocks partagés (Mocktail)
```

---

## 📦 Modèles de Données

Tous les modèles implémentent `fromMap()`, `toMap()` et `copyWith()`.

| Modèle | Table Supabase | Description |
|--------|---------------|-------------|
| `Client` | `clients` | Fiche client complète (nom, SIRET, TVA intra, adresse, contact) |
| `Facture` | `factures` | Facture avec lignes, paiements, chiffrage, multi-statut, n° bon commande, motif avoir, devise, taux change, notes privées |
| `LigneFacture` | `lignes_factures` | Ligne de facture (description, qté, PU, TVA multi-taux, formatage) |
| `Paiement` | `paiements` | Paiement partiel/total rattaché à une facture, flag acompte/solde |
| `Devis` | `devis` | Devis avec analyse de rentabilité, devise, taux change, notes privées |
| `LigneDevis` | `lignes_devis` | Ligne de devis (idem LigneFacture) |
| `LigneChiffrage` | `lignes_chiffrages` | Chiffrage avec type (matériel/MO), avancement, prix vente interne |
| `Depense` | `depenses` | Dépense professionnelle catégorisée |
| `Article` | `articles` | Article catalogue réutilisable |
| `ProfilEntreprise` | `entreprises` | Profil entreprise (logo, couleurs custom, thème PDF, mentions légales, TVA) |
| `FactureRecurrente` | `factures_recurrentes` | Facture récurrente (fréquence, prochaine émission, lignes, toggle actif) |
| `TempsActivite` | `temps_activites` | Suivi temps (durée, taux horaire, montant calculé, projet) |
| `Rappel` | `rappels` | Rappel/échéance (7 types, 4 priorités, jours restants, récurrence) |
| `PlanningEvent` | `plannings` | Événement calendrier (manuel ou auto-généré) |
| `ShoppingItem` | `courses` | Article liste de courses |
| `UrssafConfig` | `urssaf_configs` | Configuration taux URSSAF, seuils TVA 2026 (70+ colonnes) |
| `RendezVous` | `rendez_vous` | Rendez-vous / agenda |
| `Photo` | `photos` | Photos chantier liées aux clients |
| `CompteurDocument` | `compteurs_documents` | Compteurs séquentiels numérotation (anti-fraude) |
| `AuditLog` | `audit_logs` | Journal d'audit automatique (INSERT/UPDATE/DELETE) |
| `SupportTicket` | `support_tickets` | Ticket SAV client |
| `CrashLog` | `crash_logs` | Log d'erreurs applicatives |

### Règles Decimal

```dart
// ❌ JAMAIS double pour l'argent
// ✅ TOUJOURS Decimal du package 'decimal'

// Division → retourne Rational → .toDecimal() obligatoire
final prixUnitaire = (totalHt / quantite).toDecimal();

// Multiplication → retourne Decimal → pas de .toDecimal()
final totalLigne = prixUnitaire * quantite;

// Parsing depuis Supabase
final montant = Decimal.parse(json['montant'].toString());
```

---

## ⚙️ Services

### PdfService (`lib/services/pdf_service.dart`)
Génération de PDF professionnels pour factures et devis :
- 3 thèmes interchangeables (Strategy Pattern) : `ClassiqueTheme`, `ModerneTheme`, `MinimalisteTheme`
- Couleur primaire custom configurable par utilisateur
- Logo header + footer, mentions légales obligatoires (pénalités, indemnité 40€, escompte)
- Référence facture source dans les avoirs
- **PDF Situation 2 blocs** : Bloc "État d'avancement" (total marché, % avancement, travaux réalisés) + Bloc "Récapitulatif financier" (brut, TVA, déductions détaillées par facture précédente, NET À PAYER)
- `PdfGenerationRequest` enrichi avec `facturesPrecedentes` pour le calcul des déductions
- Exécution isolate-ready via `PdfGenerationRequest`

### TvaService (`lib/services/tva_service.dart`)
Analyse TVA pour micro-entrepreneurs :
- `StatutTva` : enFranchise / approcheSeuil / seuilBaseDepasse / seuilMajoreDepasse
- `AnalyseTva`, `BilanTva`, `calculerCaYtd` (ventilation vente/service par lignes)
- `simulerAvecMontant` : simulation avec montant hypothétique

### ArchivageService (`lib/services/archivage_service.dart`)
Détection intelligente des factures archivables (soldées depuis > 12 mois).

### EmailService (`lib/services/email_service.dart`)
Envoi email via `url_launcher` (mailto:) avec sujet/corps pré-remplis pour devis, factures et relances.

### AuditService (`lib/services/audit_service.dart`)
Logging dans `audit_logs` : `EMAIL_SENT`, `RELANCE_SENT`.

### RelanceService (`lib/services/relance_service.dart`)
Gestion automatisée des impayés : 4 niveaux, statistiques, textes professionnels pré-rédigés.

### ExportService (`lib/services/export_service.dart`)
Export CSV : factures (14 col), devis (12 col), clients (7 col), dépenses (5 col).

### LocalStorageService (`lib/services/local_storage_service.dart`)
Sauvegarde automatique des brouillons en cours d'édition via `SharedPreferences`.

### EcheanceService (`lib/services/echeance_service.dart`)
Génération automatique de rappels fiscaux et commerciaux :
- **URSSAF** : mensuel ou trimestriel selon configuration
- **CFE** : échéance annuelle au 15 décembre
- **Impôts** : versement libératoire mensuel/trimestriel
- **TVA** : si applicable, rappels mensuels
- **Factures échues** : rappels automatiques pour impayés
- **Devis expirants** : alertes sur devis proches de l'expiration

### PreferencesService (`lib/services/preferences_service.dart`)
Gestion de la configuration des charges sociales via `SharedPreferences`.

---

## 🔧 Utilitaires

### CalculationsUtils (`lib/utils/calculations_utils.dart`)
Calculs financiers avec précision `Decimal` :
- `calculateCharges`, `calculateNetCommercial`, `calculateResteAPayer`
- `calculateTotalLigne` (gestion mode situation/avancement)
- `calculateTauxMarge`, `calculateTotalTva` (multi-taux)
- `roundDecimal`, `ventilerCA` (vente/service)
- **Progress Billing** : `calculateLigneDevisAvancement`, `calculateDevisAvancementGlobal`, `calculateAllLignesAvancement`, `calculateTotalBrutTravauxADate`, `generateDeductionLines`

### FormatUtils (`lib/utils/format_utils.dart`)
Formatage locale française (`fr_FR`) :
- `currency(value)` → `1 250,50 €`
- `amount(Decimal)`, `percentage(value)`, `phone(String)`
- `shortDate`, `monthYear`, `relativeDate`, `truncate`

### ValidationUtils (`lib/utils/validation_utils.dart`)
12+ validateurs pour formulaires Flutter :
- `validateSiret` (Luhn standard + cas La Poste)
- `validateEmail`, `validatePhone`, `validateTvaIntra`
- `validateMontant`, `validateCodePostal`, `validatePourcentage`, `validateQuantite`
- `validateDateEcheance`, `validateRequired`

---

## 🗺️ Routes & Navigation

**~30 routes** gérées par GoRouter avec guard d'authentification.

### Routes publiques
| Route | Vue | Description |
|-------|-----|-------------|
| `/` | `LandingView` | Page d'accueil / marketing |
| `/login` | `LoginView` | Connexion / inscription Supabase Auth |

### Routes privées (`/app/*`)
| Route | Vue | Description |
|-------|-----|-------------|
| `/app/onboarding` | `OnboardingView` | Assistant première connexion (4 étapes) |
| `/app/home` | `TableauDeBordView` | Dashboard KPIs, graphiques, widgets |
| `/app/planning` | `PlanningView` | Calendrier et événements |
| `/app/devis` | `ListeDevisView` | Liste des devis |
| `/app/factures` | `ListeFacturesView` | Liste des factures |
| `/app/clients` | `ListeClientsView` | Liste des clients |
| `/app/depenses` | `ListeDepensesView` | Liste des dépenses |
| `/app/courses` | `ShoppingListView` | Liste de courses |
| `/app/rentabilite` | `RentabiliteView` | Outil chiffrage/rentabilité |
| `/app/parametres` | `SettingsRootView` | Paramètres généraux + thème PDF |
| `/app/config_urssaf` | `ParametresView` | Configuration charges URSSAF |
| `/app/profil` | `ProfilEntrepriseView` | Profil entreprise (7 sections) |
| `/app/bibliotheque` | `BibliothequePrixView` | Catalogue articles |
| `/app/archives` | `ArchivesView` | Documents archivés |
| `/app/relances` | `RelancesView` | Relances impayés + stats |
| `/app/search` | `GlobalSearchView` | Recherche globale 5 entités |
| `/app/recurrentes` | `FacturesRecurrentesView` | Factures récurrentes (toggle, fréquence) |
| `/app/temps` | `SuiviTempsView` | Suivi du temps + saisie + KPIs |
| `/app/rappels` | `RappelsEcheancesView` | Rappels & échéances fiscales (3 onglets) |
| `/app/corbeille` | `CorbeilleView` | Corbeille soft-delete (4 onglets) |
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
- [x] **Immutabilité factures** : Trigger SQL `protect_validated_facture` bloque toute modification post-validation
- [x] **Piste d'audit** : Table `audit_logs` + triggers sur factures/devis/paiements
- [x] **Numérotation certifiée** : Séquences sans trou par trigger SQL (conformité anti-fraude TVA art. 286 I-3° bis CGI)
- [x] **Protection suppression** : Triggers `BEFORE DELETE` bloquent la suppression des documents non-brouillon
- [x] **Mentions légales** : Pénalités de retard, indemnité forfaitaire 40€, escompte (CGI art. 289, Code Commerce L441-10)
- [x] **Contraintes SQL** : Prix positifs, emails valides, quantités cohérentes
- [x] **Validation côté client** : `ValidationUtils` avec 12+ validateurs dont Luhn SIRET
- [x] **Type Safety** : `Decimal` obligatoire pour tous les montants financiers — jamais `double`
- [x] **Sécurité async** : `mounted` / `context.mounted` vérifié après chaque `await`

---

## ✅ Tests

**662 tests — 100% passés** | **0 issue d'analyse statique**

```bash
flutter test    → 662 tests passed
flutter analyze → No issues found!
```

### Couverture des tests

| Catégorie | Fichiers | Tests | Détail |
|-----------|----------|-------|--------|
| **ViewModels** | 18 | ~420 | CRUD, logique métier, duplication, avoir, relance, dashboard, archivage, corbeille, récurrence, temps, rappels |
| **Services** | 8 | ~100 | RelanceService, TvaService, EmailService, AuditService, ArchivageService, EcheanceService, design system Aurora, PDF themes |
| **Models** | 6 | ~75 | `fromMap`, `toMap`, `copyWith`, getters calculés, champs complets, FactureRecurrente, TempsActivite, Rappel |
| **Utils** | 3 | ~35 | Calculs Decimal, formatage FR, validation (Luhn SIRET, TVA, etc.) |
| **Widgets** | 3 | ~12 | FacturesRetardCard, ListeClientsView, LoginView |
| **Intégration** | 3 | ~10 | Workflows complets (client → devis → facture, articles) |

### Stack de test
- **Framework** : `flutter_test`
- **Mocking** : `mocktail` — mocks dans `test/mocks/`
- **Pattern** : interface repository → mock → injection constructeur ViewModel
- **Nommage** : descriptions en français dans `test()` et `group()`

---

## 🏁 Installation & Démarrage

### Pré-requis
- Flutter SDK ≥ 3.2.2
- Compte Supabase configuré avec les tables, RLS, triggers

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

### Commandes

```bash
flutter run -d chrome           # Dev web
flutter build windows           # Build Windows (production)
flutter test                    # 662 tests unitaires + intégration
flutter analyze                 # Analyse statique (0 issues)
flutter clean                   # Si fichiers éphémères corrompus
```

*CraftOS — Dernière mise à jour : 24 février 2026*
