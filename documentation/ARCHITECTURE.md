# Architecture — CraftOS

> Document de référence architecture — Dernière mise à jour : 26/02/2026

---

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Stack technique](#stack-technique)
3. [Pattern MVVM](#pattern-mvvm)
4. [Arborescence du projet](#arborescence-du-projet)
5. [Couche Core](#couche-core)
6. [Couche Models](#couche-models)
7. [Couche Repositories](#couche-repositories)
8. [Couche ViewModels](#couche-viewmodels)
9. [Couche Services](#couche-services)
10. [Couche Views & Widgets](#couche-views--widgets)
11. [Configuration](#configuration)
12. [Utilitaires](#utilitaires)
13. [Patterns clés](#patterns-clés)
14. [Diagramme de flux](#diagramme-de-flux)

---

## Vue d'ensemble

**CraftOS** est un SaaS Flutter Web de gestion commerciale destiné aux artisans du BTP. Il intègre 8 modules de nouvelle génération :

- **Module 0** : Écosystème Web d'Acquisition (craftos.fr)
- **Module 1** : Support Client (SAV) Autonome par I.A. via Gemini Flash et Supabase Edge Functions
- **Module 2** : CRM Magique & OCR (Auto-complétion B2B Pappers/BAN, OCR Dépenses)
- **Module 3** : Le Cycle de Vente "Aitise ton Devis" (Génération contextuelle RAG par Speech-to-Text, Bouclier de marge, Signature tactile)
- **Module 4** : Le Cockpit Chantier (Progress Billing avec split Vente/Pose et optimisation comptable URSSAF)
- **Module 5** : Moteur Légal & Fiscal (Régime Fiscal Multi, Assistant d'échéances)
- **Module 6** : Génération PDF & Encaissement Premium (QR Code SEPA EPC, Badges RGE/Décennale)
- **Module 7** : Infrastructure, Envois (Marque blanche Resend) et Mode Hors-Ligne (flutter_secure_storage)
- **Module 8** : Super-Cockpit Admin "God Mode" (Route /admin-panel, RPC Métriques DB, Kanban Tickets, Crashlytics sur mesure)

---

## Stack technique

| Composant | Technologie | Version |
|---|---|---|
| Framework | Flutter (Web + Windows) | 3.38.9 |
| Langage | Dart | 3.10.8 |
| Backend | Supabase (PostgreSQL 17) | Cloud |
| Auth | Supabase Auth | Email/Password |
| State Management | Provider + ChangeNotifier | 6.x |
| Routing | GoRouter | 14.x |
| PDF | pdf + printing | 3.x |
| Monétaire | decimal (package) | 3.x |
| Tests | flutter_test + mocktail | 761 tests (100% pass) |
| Fonts | google_fonts | 6.x |
| Charts | fl_chart | 0.x |
| UUID | uuid | 4.x |
| Local Storage | shared_preferences | 2.x |
| URL Launch | url_launcher | 6.x |

---

## Pattern MVVM

```
┌──────────────────────────────────────────────────────────────────┐
│                           VIEWS                                  │
│  (Widgets Flutter — affichage uniquement, aucune logique)        │
│    ↕ Consumer<ViewModel> / context.read<ViewModel>()             │
├──────────────────────────────────────────────────────────────────┤
│                        VIEWMODELS                                │
│  (ChangeNotifier — logique métier, état, orchestration)          │
│  extends BaseViewModel · + AutoSaveMixin · + PdfGenerationMixin  │
│    ↕ Interface IXxxRepository (injection constructeur)           │
├──────────────────────────────────────────────────────────────────┤
│                       REPOSITORIES                               │
│  (Abstraction accès données — interface + implémentation)        │
│  extends BaseRepository / DocumentRepository                     │
│    ↕ Supabase Client (REST + Realtime)                          │
├──────────────────────────────────────────────────────────────────┤
│                        SERVICES                                  │
│  (Classes statiques — calculs purs, pas d'état)                 │
│  TvaService · RelanceService · ArchivageService · EmailService   │
│  AuditService · ExportService · PdfService · EcheanceService     │
└──────────────────────────────────────────────────────────────────┘
```

**Principes :**

1. Les **Views** ne contiennent aucune logique métier — uniquement de l'affichage
2. Les **ViewModels** orchestrent tout via `executeOperation()` / `execute()`
3. Les **Repositories** sont injectés via interfaces (testabilité)
4. Les **Services** sont statiques et sans état (fonctions pures)
5. L'**injection** se fait par constructeur optionnel avec fallback vers l'implémentation concrète

---

## Arborescence du projet

```
lib/
├── main.dart                          # Point d'entrée, initialisation Supabase
├── config/
│   ├── dependency_injection.dart      # 18 Providers enregistrés (MultiProvider)
│   ├── router.dart                    # ~30 routes GoRouter + auth guard
│   ├── supabase_config.dart           # URL + anon key Supabase
│   └── theme.dart                     # AppTheme Artisan Forge 2030 : design tokens + glassmorphism dark mode
├── core/
│   ├── base_viewmodel.dart            # BaseViewModel : loading réentrant
│   ├── base_repository.dart           # BaseRepository : CRUD helpers Supabase
│   ├── document_repository.dart       # DocumentRepository : signatures, numéros
│   ├── autosave_mixin.dart            # AutoSaveMixin : brouillons SharedPreferences
│   └── pdf_generation_mixin.dart      # PdfGenerationMixin : preview temps réel
├── models/
│   ├── enums/
│   │   └── entreprise_enums.dart      # 8 enums métier + extensions
│   ├── client_model.dart              # Client : particulier ou professionnel
│   ├── facture_model.dart             # Facture + LigneFacture (Decimal)
│   ├── devis_model.dart               # Devis + LigneDevis (Decimal)
│   ├── paiement_model.dart            # Paiement (montant Decimal)
│   ├── entreprise_model.dart          # ProfilEntreprise (config complète)
│   ├── depense_model.dart             # Dépense comptable
│   ├── urssaf_model.dart              # Cotisation URSSAF
│   ├── article_model.dart             # Article (bibliothèque de prix)
│   ├── chiffrage_model.dart           # Chiffrage détaillé
│   ├── config_charges_model.dart      # Configuration charges sociales
│   ├── photo_model.dart               # Photo chantier
│   ├── facture_recurrente_model.dart   # Facture récurrente + LigneFactureRecurrente
│   ├── temps_activite_model.dart       # Suivi du temps (durée, taux, projet)
│   ├── rappel_model.dart              # Rappel/échéance (7 types, 4 priorités)
│   ├── planning_model.dart            # Événement planning
│   └── shopping_model.dart            # Liste courses / matériaux
├── repositories/                      # 16 repositories (interface + impl)
│   ├── facture_repository.dart        # IFactureRepository + FactureRepository
│   ├── devis_repository.dart          # IDevisRepository + DevisRepository
│   ├── client_repository.dart         # IClientRepository + ClientRepository
│   ├── dashboard_repository.dart      # IDashboardRepository + DashboardRepository
│   ├── entreprise_repository.dart     # IEntrepriseRepository + EntrepriseRepository
│   ├── depense_repository.dart        # IDepenseRepository + DepenseRepository
│   ├── urssaf_repository.dart         # IUrssafRepository + UrssafRepository
│   ├── article_repository.dart        # IArticleRepository + ArticleRepository
│   ├── auth_repository.dart           # IAuthRepository + AuthRepository
│   ├── chiffrage_repository.dart      # IChiffrageRepository + ChiffrageRepository (progress billing)
│   ├── global_search_repository.dart  # IGlobalSearchRepository + impl
│   ├── planning_repository.dart       # IPlanningRepository + PlanningRepository
│   ├── facture_recurrente_repository.dart # IFactureRecurrenteRepository + impl
│   ├── temps_repository.dart          # ITempsRepository + TempsRepository
│   ├── rappel_repository.dart         # IRappelRepository + RappelRepository
│   └── shopping_repository.dart       # IShoppingRepository + ShoppingRepository
│   ├── services/
│   │   ├── gemini_service.dart            # Intégration Gemini 2.0 Flash (OCR, AI Quotes)
│   │   ├── ai_support_service.dart        # Liaison Edge Functions pour le SAV
│   │   ├── tva_service.dart               # Analyse TVA, seuils franchise
│   │   ├── relance_service.dart           # Analyse relances multi-niveaux
│   │   ├── archivage_service.dart         # Détection factures archivables
│   │   ├── email_service.dart             # Envoi via mailto: ou API Resend
│   │   ├── audit_service.dart             # Logs audit (loi anti-fraude)
│   │   ├── export_service.dart            # Export CSV comptabilité
│   │   ├── pdf_service.dart               # Génération PDF isolate-ready + QR Code SEPA
│   │   │                                  #  → _configPrimaryColor / _configAccentLight dynamiques
│   │   ├── local_storage_service.dart     # Brouillons SharedPreferences / Mode Offline
│   │   ├── preferences_service.dart       # Préférences charges sociales
│   │   ├── echeance_service.dart          # Rappels fiscaux auto (URSSAF, CFE, TVA, Impôts)
│   │   └── pdf_themes/
│   │       ├── pdf_theme_base.dart        # PdfThemeBase : primaryColor / secondaryColor / accentColor dynamiques
│   │       ├── classique_theme.dart       # Thème classique sobre (couleurs config)
│   │       ├── moderne_theme.dart         # Thème moderne coloré (couleurs config)
│   │       ├── minimaliste_theme.dart     # Thème épuré minimal
│   │       └── pdf_themes.dart            # Barrel export
├── viewmodels/                        # 21 ViewModels
│   ├── facture_viewmodel.dart         # Cycle facture complet (458 lignes)
│   ├── devis_viewmodel.dart           # Cycle devis complet (458 lignes)
│   ├── dashboard_viewmodel.dart       # KPI, graphiques, alertes (390 lignes)
│   ├── client_viewmodel.dart          # CRUD clients
│   ├── depense_viewmodel.dart         # CRUD dépenses
│   ├── entreprise_viewmodel.dart      # Profil entreprise / onboarding
│   ├── urssaf_viewmodel.dart          # Cotisations URSSAF
│   ├── article_viewmodel.dart         # Bibliothèque de prix
│   ├── auth_viewmodel.dart            # Authentification Supabase
│   ├── relance_viewmodel.dart         # Relances client
│   ├── global_search_viewmodel.dart   # Recherche globale
│   ├── planning_viewmodel.dart        # Planning / agenda
│   ├── shopping_viewmodel.dart        # Listes courses
│   ├── corbeille_viewmodel.dart       # Corbeille soft-delete (4 entités)
│   ├── facture_recurrente_viewmodel.dart # Gérer factures récurrentes
│   ├── temps_viewmodel.dart           # Suivi du temps
│   ├── rappel_viewmodel.dart          # Rappels & échéances
│   ├── rentabilite_viewmodel.dart     # Progress billing + auto-save (298 lignes)
│   ├── pdf_studio_viewmodel.dart      # PDF Design Studio : config + preview live (compute)
│   └── editor_state_provider.dart     # État éditeur partagé
├── views/                             # ~26 vues
│   ├── tableau_de_bord_view.dart      # Dashboard principal
│   ├── liste_factures_view.dart       # Liste factures avec filtres
│   ├── liste_devis_view.dart          # Liste devis avec filtres
│   ├── liste_clients_view.dart        # Liste clients
│   ├── liste_depenses_view.dart       # Liste dépenses
│   ├── facture/stepper/               # Stepper facture 4 étapes
│   ├── devis/stepper/                 # Stepper devis 4 étapes
│   ├── ajout_client_view.dart         # Formulaire client
│   ├── ajout_depense_view.dart        # Formulaire dépense
│   ├── detail_client_view.dart        # Fiche client détaillée
│   ├── profil_entreprise_view.dart    # Configuration entreprise
│   ├── parametres_view.dart           # Paramètres application
│   ├── settings_root_view.dart        # Menu paramètres (hub)
│   ├── pdf_studio_view.dart           # PDF Design Studio (split view + live preview)
│   ├── relances_view.dart             # Gestion relances
│   ├── archives_view.dart             # Documents archivés
│   ├── rentabilite_view.dart          # Analyse rentabilité
│   ├── bibliotheque_prix_view.dart    # Catalogue articles
│   ├── planning_view.dart             # Planning / calendrier
│   ├── shopping_list_view.dart        # Liste courses
│   ├── global_search_view.dart        # Recherche globale
│   ├── signature_view.dart            # Capture signature
│   ├── onboarding_view.dart           # Assistant première utilisation
│   ├── login_view.dart                # Connexion
│   ├── landing_view.dart              # Page d'accueil publique
│   └── splash_view.dart               # Écran de chargement
├── widgets/                           # ~29 widgets réutilisables
│   ├── base_screen.dart               # Layout commun (drawer + app bar)
│   ├── custom_drawer.dart             # Navigation latérale avec badges
│   ├── custom_app_bar.dart            # Barre d'application personnalisée
│   ├── custom_text_field.dart         # Champ texte stylisé
│   ├── app_card.dart                  # Carte Material élevée
│   ├── statut_badge.dart              # Badge statut coloré
│   ├── ligne_editor.dart              # Éditeur de ligne document
│   ├── split_editor_scaffold.dart     # Layout split éditeur/preview
│   ├── chiffrage_editor.dart          # Éditeur de chiffrage
│   ├── rentabilite_card.dart          # Carte rentabilité
│   ├── tva_alert_banner.dart          # Bannière alerte TVA
│   ├── article_selection_dialog.dart  # Sélection article catalogue
│   ├── client_selection_dialog.dart   # Sélection client existant
│   ├── dashboard/                     # 11 widgets dashboard (KPI, charts...)
│   ├── aurora/                         # Widgets Artisan Forge 2030 (glass, ForgeBackground Concept)
│   └── dialogs/                       # 5 dialogs (paiement, signature, chiffrage, etc.)
└── utils/
    ├── calculations_utils.dart        # Calculs financiers 100% Decimal
    ├── format_utils.dart              # Formatage dates, montants, numéros
    └── validation_utils.dart          # Validations formulaires
```

**Total : ~165+ fichiers Dart**

---

## Couche Core

### BaseViewModel (`lib/core/base_viewmodel.dart`)

Classe abstraite dont tous les ViewModels héritent. Implémente un **loading réentrant** :

```dart
abstract class BaseViewModel extends ChangeNotifier {
  int _loadingDepth = 0;
  bool get isLoading => _loadingDepth > 0;
  String? _error;
  String? get error => _error;

  // Opération avec gestion d'erreur — retourne true si succès
  Future<bool> executeOperation(Future<void> Function() operation) async {
    _loadingDepth++;
    _error = null;
    notifyListeners();
    try {
      await operation();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loadingDepth--;
      notifyListeners();
    }
  }

  // Chargement simple sans retour booléen
  Future<void> execute(Future<void> Function() operation);
}
```

**Pourquoi réentrant ?** Plusieurs opérations async peuvent se chevaucher (ex: sauvegarder + générer PDF). Le compteur `_loadingDepth` garantit que `isLoading` reste `true` tant qu'au moins une opération est en cours.

### BaseRepository (`lib/core/base_repository.dart`)

```dart
abstract class BaseRepository {
  final client = SupabaseConfig.client;

  // Ajoute user_id, retire id (pour INSERT)
  Map<String, dynamic> prepareForInsert(Map<String, dynamic> data);

  // Retire user_id et id (pour UPDATE — RLS gère l'user)
  Map<String, dynamic> prepareForUpdate(Map<String, dynamic> data);

  // Gestion centralisée des erreurs Supabase
  Never handleError(String operation, Object error, [StackTrace? stack]);
}
```

### DocumentRepository (`lib/core/document_repository.dart`)

Extension de BaseRepository pour les documents (factures, devis) :

```dart
abstract class DocumentRepository extends BaseRepository {
  // Upload signature vers Supabase Storage
  Future<String?> uploadSignature(String bucket, String path, Uint8List bytes);

  // Génère le prochain numéro : PREFIX-YYYY-NNNN
  Future<String> generateNextNumero(String table, String column, String prefix);

  // Supprime les lignes enfants avant re-création
  Future<void> deleteChildLines(String table, String parentColumn, String parentId);
}
```

### AutoSaveMixin (`lib/core/autosave_mixin.dart`)

Mixin pour la sauvegarde automatique de brouillons via SharedPreferences :

- `checkLocalDraft(String key)` — Vérifie s'il existe un brouillon local
- `autoSaveDraft(String key, Map data)` — Sauvegarde avec debounce 2 secondes
- `clearLocalDraft(String key)` — Supprime le brouillon
- `disposeAutoSave()` — Annule les timers

### PdfGenerationMixin (`lib/core/pdf_generation_mixin.dart`)

Mixin pour la prévisualisation PDF en temps réel :

- `toggleRealTimePreview()` — Active/désactive le mode preview
- `triggerPdfUpdate()` — Régénère le PDF (debounce 1 seconde)
- `forceRefreshPdf()` — Régénération immédiate
- `clearPdfState()` — Nettoie le cache PDF
- Cache des polices (`_cachedFonts`) pour éviter le rechargement

---

## Couche Models

Tous les modèles suivent le pattern : `fromMap()` + `toMap()` + `copyWith()`.

| Modèle | Table Supabase | Description | Champs clés |
|---|---|---|---|
| `Facture` | `factures` | Facture ou avoir | `numeroFacture`, `totalHt/Tva/Ttc` (Decimal), `statut`, `statutJuridique`, `typeDocument`, `estArchive`, `devise`, `tauxChange`, `notesPrivees` |
| `LigneFacture` | `lignes_facture` | Ligne de facture | `description`, `quantite`, `prixUnitaire`, `totalLigne` (Decimal), `tauxTva`, `avancement` |
| `Devis` | `devis` | Devis commercial | `numeroDevis`, `totalHt/Tva/Ttc` (Decimal), `statut`, `dureeValidite`, `tauxAcompte`, `devise`, `tauxChange`, `notesPrivees` |
| `LigneDevis` | `lignes_devis` | Ligne de devis | Mêmes champs que LigneFacture + `uiKey` (UUID) |
| `Client` | `clients` | Client (part./pro.) | `nomComplet`, `typeClient`, `siret`, `tvaIntra`, adresse complète |
| `Paiement` | `paiements` | Paiement unitaire | `montant` (Decimal), `datePaiement`, `typePaiement`, `isAcompte` |
| `ProfilEntreprise` | `entreprises` | Config entreprise | SIRET, enums (type, régime, caisse), PDF theme, TVA, mentions légales |
| `Depense` | `depenses` | Dépense déductible | `montant` (Decimal), `categorie`, `dateDepense`, `estDeductible` |
| `Article` | `articles` | Bibliothèque prix | `designation`, `prixUnitaire` (Decimal), `unite`, `typeActivite` |
| `CotisationUrssaf` | `urssaf_configs` | Config URSSAF+fiscal (70+ colonnes) | Taux cotisations, plafonds CA, seuils TVA 2026, taux IS, ACRE |
| `ConfigCharges` | — (local) | Config charges sociales | Taux par type d'activité, impôt libératoire |
| `Chiffrage` | `lignes_chiffrages` | Ligne chiffrage interne | TypeChiffrage (materiel/mainDoeuvre), linkedLigneDevisId, estAchete, avancementMo, prixVenteInterne, `valeurRealisee`, `avancementPourcent` |
| `Planning` | `plannings` | Événement calendrier | `titre`, `dateDebut`, `dateFin`, `clientId` |
| `Shopping` | `courses` | Item liste courses | `designation`, `quantite`, `prixUnitaire`, `estAchete` |
| `FactureRecurrente` | `factures_recurrentes` | Facture récurrente | `frequence` (FrequenceRecurrence), `prochaineEmission`, `estActive`, `nbFacturesGenerees`, `totalHt/Tva/Ttc`, `devise`, `remiseTaux` |
| `LigneFactureRecurrente` | `lignes_facture_recurrente` | Ligne facture récurrente | `description`, `quantite`, `prixUnitaire`, `totalLigne`, `tauxTva`, `typeActivite` |
| `TempsActivite` | `temps_activites` | Suivi du temps | `dureeMinutes`, `tauxHoraire`, `montant` (Decimal), `projet`, `estFacturable`, `estFacture`, `dureeFormatee` |
| `Rappel` | `rappels` | Rappel/échéance | `typeRappel` (7 types), `priorite` (4 niveaux), `dateEcheance`, `estComplete`, `estRecurrent`, `joursRestants`, `estEnRetard` |

### Enums (`lib/models/enums/entreprise_enums.dart`)

8 enums avec extensions `dbValue` / `fromDbValue` pour la sérialisation Supabase :

| Enum | Valeurs |
|---|---|
| `TypeEntreprise` | microEntrepreneurService, microEntrepreneurCommerce, microEntrepreneurMixte, autoEntrepreneur |
| `StatutEntrepreneur` | actif, enSommeil, cesse |
| `TypeActiviteMicro` | service, commerce, mixte, liberal |
| `FrequenceCotisation` | mensuelle, trimestrielle |
| `RegimeFiscal` | microFiscal, microFiscalSimplifiee, reelSimplifie |
| `CaisseRetraite` | ssi, cipav, carmf, carpimko |
| `PdfTheme` | classique, moderne, minimaliste |
| `ModeFacturation` | global, detaille |
| `TypeChiffrage` | materiel, mainDoeuvre |
| `FrequenceRecurrence` | hebdomadaire, mensuel, trimestriel, annuel |
| `TypeRappel` | urssaf, cfe, impots, tva, echeanceFacture, echeanceDevis, autre |
| `PrioriteRappel` | basse, normale, haute, urgente |

---

## Couche Repositories

Chaque repository suit le pattern **interface abstraite + implémentation concrète** :

```dart
// Interface (pour injection et mocking)
abstract class IFactureRepository {
  Future<List<Facture>> getFactures();
  Future<Facture> getFacture(String id);
  Future<void> createFacture(Facture facture, List<LigneFacture> lignes);
  Future<void> updateFacture(Facture facture, List<LigneFacture> lignes);
  Future<void> deleteFacture(String id);
  // ... méthodes spécifiques
}

// Implémentation
class FactureRepository extends DocumentRepository implements IFactureRepository {
  @override
  Future<List<Facture>> getFactures() async {
    final data = await client.from('factures')
        .select('*, lignes_facture(*)')
        .order('created_at', ascending: false);
    return data.map((e) => Facture.fromMap(e)).toList();
  }
  // ...
}
```

| Repository | Interface | Tables | Hérite de |
|---|---|---|---|
| `FactureRepository` | `IFactureRepository` | `factures`, `lignes_factures`, `paiements` | `DocumentRepository` |
| `DevisRepository` | `IDevisRepository` | `devis`, `lignes_devis` | `DocumentRepository` |
| `ClientRepository` | `IClientRepository` | `clients` | `BaseRepository` |
| `DashboardRepository` | `IDashboardRepository` | `factures`, `devis`, `depenses`, `clients` | `BaseRepository` |
| `EntrepriseRepository` | `IEntrepriseRepository` | `entreprises` | `BaseRepository` |
| `DepenseRepository` | `IDepenseRepository` | `depenses` | `BaseRepository` |
| `UrssafRepository` | `IUrssafRepository` | `urssaf_configs` | `BaseRepository` |
| `ArticleRepository` | `IArticleRepository` | `articles` | `BaseRepository` |
| `AuthRepository` | `IAuthRepository` | `auth.users` | `BaseRepository` |
| `GlobalSearchRepository` | `IGlobalSearchRepository` | toutes tables publiques | `BaseRepository` |
| `PlanningRepository` | `IPlanningRepository` | `plannings` | `BaseRepository` |
| `ShoppingRepository` | `IShoppingRepository` | `courses` | `BaseRepository` |
| `FactureRecurrenteRepository` | `IFactureRecurrenteRepository` | `factures_recurrentes`, `lignes_facture_recurrente` | `BaseRepository` |
| `TempsRepository` | `ITempsRepository` | `temps_activites` | `BaseRepository` |
| `RappelRepository` | `IRappelRepository` | `rappels` | `BaseRepository` |
| `ChiffrageRepository` | `IChiffrageRepository` | `lignes_chiffrages` | `BaseRepository` |
| `SupportRepository` | `ISupportRepository` | `support_tickets` | `BaseRepository` |

---

## Couche ViewModels

Tous les ViewModels suivent le pattern d'injection par constructeur :

```dart
class FactureViewModel extends BaseViewModel
    with PdfGenerationMixin, AutoSaveMixin {
  final IFactureRepository _repository;

  FactureViewModel({IFactureRepository? repository})
      : _repository = repository ?? FactureRepository();
}
```

### ViewModels principaux

| ViewModel | Lignes | Mixins | Repository | Responsabilités |
|---|---|---|---|---|
| `FactureViewModel` | 458 | PdfGeneration, AutoSave | IFactureRepository | CRUD factures, lignes, paiements, avoirs, PDF, archivage, envoi |
| `DevisViewModel` | 458 | PdfGeneration, AutoSave | IDevisRepository | CRUD devis, lignes, transformation devis→facture, avenants, PDF |
| `DashboardViewModel` | 390 | — | IDashboard + IFacture | KPI, graphiques CA, top clients, relances, TVA, archivage |
| `ClientViewModel` | ~150 | — | IClientRepository | CRUD clients, recherche, validation |
| `DepenseViewModel` | ~120 | — | IDepenseRepository | CRUD dépenses, filtrage par période |
| `EntrepriseViewModel` | ~200 | — | IEntrepriseRepository | Profil entreprise, onboarding, mentions légales |
| `UrssafViewModel` | ~180 | — | IUrssafRepository | Cotisations, plafonds, calculs URSSAF |
| `ArticleViewModel` | ~100 | — | IArticleRepository | Bibliothèque articles/tarifs |
| `AuthViewModel` | ~100 | — | IAuthRepository | Login, logout, inscription, session |
| `RelanceViewModel` | ~120 | — | IFactureRepository | Relances multi-niveaux via RelanceService |
| `GlobalSearchViewModel` | ~80 | — | IGlobalSearchRepository | Recherche cross-table |
| `PlanningViewModel` | ~100 | — | IPlanningRepository | CRUD événements calendrier |
| `ShoppingViewModel` | ~80 | — | IShoppingRepository | Liste de courses |
| `CorbeilleViewModel` | ~150 | — | IFacture + IDevis + IClient + IDepense | Corbeille soft-delete, restauration |
| `FactureRecurrenteViewModel` | ~200 | — | IFactureRecurrenteRepository | CRUD factures récurrentes, toggle actif, génération |
| `TempsViewModel` | ~150 | — | ITempsRepository | CRUD temps, KPIs, filtrage périodes |
| `RappelViewModel` | ~200 | — | IRappelRepository | CRUD rappels, génération fiscale, complétion |
| `RentabiliteViewModel` | 298 | — | IChiffrage + IDevis | Arbre devis→lignes→chiffrages, toggle/slider, auto-save debounce, avancement temps réel |
| `EditorStateProvider` | ~50 | — | — | État partagé de l'éditeur |

---

## Couche Services

Les services sont **statiques** et **sans état** — ils fournissent des fonctions pures.

### TvaService (`lib/services/tva_service.dart`)

Analyse du statut TVA par rapport aux seuils de franchise :

```dart
class TvaService {
  // Seuils légaux
  static const seuilFranchiseService = 36800;
  static const seuilMajorationService = 39100;
  static const seuilFranchiseCommerce = 91900;
  static const seuilMajorationCommerce = 101000;

  static StatutTva analyserActivite(Decimal caYtd, String typeActivite);
  static AnalyseTva analyser(Decimal caService, Decimal caCommerce);
  static BilanTva calculerCaYtd(List<Facture> factures, int annee);
  static AnalyseTva simulerAvecMontant(AnalyseTva current, Decimal montant, String type);
}
```

`StatutTva` : `sousFranchise`, `approcheSeuil` (< 90%), `depassementBasSeuil`, `depassementHautSeuil`

### RelanceService (`lib/services/relance_service.dart`)

Génération automatique de relances graduées :

```dart
class RelanceService {
  static List<RelanceInfo> analyserRelances(List<Facture> factures);
  static String genererTexteRelance(RelanceInfo relance, ProfilEntreprise profil);
}
```

`NiveauRelance` (4 niveaux) : `relance1` (J+7), `relance2` (J+15), `relance3` (J+30), `miseDemeure` (J+45)

### ArchivageService (`lib/services/archivage_service.dart`)

```dart
class ArchivageService {
  static List<Facture> detecterArchivables(List<Facture> factures);
  // Retourne les factures : soldées + non archivées + > 12 mois
}
```

### EmailService (`lib/services/email_service.dart`)

Envoi d'emails via `url_launcher` (mailto:) :

```dart
class EmailService {
  static Future<EmailResult> envoyerDevis(Devis devis, Client client, ProfilEntreprise profil);
  static Future<EmailResult> envoyerFacture(Facture facture, Client client, ProfilEntreprise profil);
  static Future<EmailResult> envoyerRelance(RelanceInfo relance, Client client, ProfilEntreprise profil);
}
```

### AuditService (`lib/services/audit_service.dart`)

Logging d'audit pour la conformité loi anti-fraude :

```dart
class AuditService {
  static Future<void> logEnvoiEmail(String userId, String recordId, String type);
  static Future<void> logRelance(String userId, String recordId, int niveau);
  // Insert dans audit_logs — fail-safe (catch all)
}
```

### PdfService (`lib/services/pdf_service.dart`)

Génération PDF isolate-ready via `PdfGenerationRequest` :

```dart
class PdfGenerationRequest {
  final dynamic document;      // Facture ou Devis
  final Client client;
  final ProfilEntreprise profil;
  final List<dynamic> lignes;
  final List<Map<String, dynamic>>? facturesPrecedentes; // Pour PDF situation (déductions)
}

class PdfService {
  static Future<Uint8List> generatePdf(PdfGenerationRequest request);
  // Résout le thème dynamiquement depuis profil.pdfTheme
  // Mode situation : 2 blocs (État d'avancement + Récapitulatif financier avec déductions)
}
```

### PDF Themes — Strategy Pattern

```
PdfThemeBase (abstraite)
├── ClassiqueTheme     — Sobre, professionnel, bordures fines
├── ModerneTheme       — Coloré, header gradient, arrondi
└── MinimalisteTheme   — Épuré, minimal, lignes fines
```

Méthodes abstraites : `buildHeader()`, `buildAddresses()`, `buildTitle()`
Méthodes concrètes héritées : `buildHeaderCell()`, `buildSectionTitle()`, `buildLineTable()`
Personnalisation : `setCustomPrimaryColor(String hex)` change la couleur primaire du thème

### Autres Services

| Service | Fichier | Méthodes clés |
|---|---|---|
| `ExportService` | `export_service.dart` | `exportComptabilite()` (2 CSVs), `exportFactures()`, `exportDepenses()` |
| `LocalStorageService` | `local_storage_service.dart` | `saveDraft()`, `getDraft()`, `clearDraft()`, `generateKey()` |
| `PreferencesService` | `preferences_service.dart` | `getConfigCharges()`, `saveConfigCharges()`, `resetConfigCharges()` |
| `EcheanceService` | `echeance_service.dart` | `genererTousRappels(annee, config)` : URSSAF mens/trim, CFE, Impôts, TVA, factures échues, devis expirants |

---

## Couche Views & Widgets

### Views principales

| Vue | Route | Description |
|---|---|---|
| `TableauDeBordView` | `/app/dashboard` | Dashboard avec KPIs, graphiques, alertes |
| `ListeFacturesView` | `/app/factures` | Liste factures filtrable + tri |
| `FactureStepperView` | `/app/factures/new`, `/app/factures/edit/:id` | Stepper 4 étapes création/édition |
| `ListeDevisView` | `/app/devis` | Liste devis filtrable + tri |
| `DevisStepperView` | `/app/devis/new`, `/app/devis/edit/:id` | Stepper 4 étapes création/édition |
| `ListeClientsView` | `/app/clients` | Liste clients avec recherche |
| `AjoutClientView` | `/app/clients/new`, `/app/clients/edit/:id` | Formulaire client |
| `DetailClientView` | `/app/clients/:id` | Fiche client + historique |
| `ListeDepensesView` | `/app/depenses` | Liste dépenses par période |
| `RelancesView` | `/app/relances` | Relances en cours + envoi |
| `ArchivesView` | `/app/archives` | Documents archivés |
| `RentabiliteView` | `/app/rentabilite` | Analyse de rentabilité |
| `ProfilEntrepriseView` | `/app/profil` | Configuration entreprise |
| `ParametresView` | `/app/parametres` | Paramètres application |
| `OnboardingView` | `/onboarding` | Assistant première configuration |
| `LoginView` | `/login` | Authentification |
| `CorbeilleView` | `/app/corbeille` | Corbeille soft-delete (4 onglets) |
| `FacturesRecurrentesView` | `/app/recurrentes` | Factures récurrentes + toggle actif |
| `SuiviTempsView` | `/app/temps` | Suivi du temps + saisie + KPIs |
| `RappelsEcheancesView` | `/app/rappels` | Rappels & échéances (3 onglets) |

### Widgets Dashboard (11)

| Widget | Rôle |
|---|---|
| `GradientKpiCard` | Carte KPI premium (double ombre colorée, orbe lumineux, glass) |
| `KpiCard` | Carte KPI simple |
| `RevenueChart` | Graphique CA mensuel (fl_chart) |
| `ExpensePieChart` | Camembert dépenses par catégorie |
| `TopClientsCard` | Top clients par CA |
| `PlafondCard` | Barre de progression plafond micro |
| `CotisationDetailCard` | Détail cotisations URSSAF |
| `RecentActivityList` | Activité récente (factures, devis) |
| `FacturesRetardCard` | Factures en retard de paiement |
| `SuiviSeuilTvaCard` | Suivi seuils franchise TVA |
| `ArchivageSuggestionCard` | Suggestions d'archivage |

| `GlassContainer` | `widgets/aurora/glass_container.dart` | Conteneur givré réutilisable (BackdropFilter optionnel, ombre colorée, bordure lumineuse adaptative) |
| `AuroraBackground` | `widgets/aurora/aurora_background.dart` | Fond Mesh animée Artisan Forge (Orbes Fire, Gold, Tech Indigo sur Dark Stone) |
| `GlowIcon` | `widgets/aurora/glow_icon.dart` | Icône avec halo lumineux contextuel (actif/inactif, rayon et couleur configurables) |

### Widgets réutilisables (19+)

| Widget | Rôle |
|---|---|
| `BaseScreen` | Layout commun avec drawer + AuroraBackground |
| `CustomDrawer` | Sidebar glassmorphique (BackdropFilter, glow sur sélection) |
| `CustomAppBar` | App bar avec pilule glass recherche |
| `CustomTextField` | Champ texte avec validation |
| `AppCard` | Carte glass à ombres colorées (plus d'élévation Material) |
| `StatutBadge` | Badge luminescent avec micro-glow |
| `LigneEditor` | Éditeur de ligne de document |
| `SplitEditorScaffold` | Layout split formulaire/preview PDF |
| `ChiffrageEditor` | Éditeur de chiffrage détaillé |
| `RentabiliteCard` | Carte indicateur rentabilité |
| `TvaAlertBanner` | Bannière d'alerte seuil TVA |
| `ArticleSelectionDialog` | Dialog sélection article catalogue |
| `ClientSelectionDialog` | Dialog sélection client |
| `PaiementDialog` | Dialog ajout de paiement |
| `SignatureDialog` | Dialog capture signature |
| `TransformationDialog` | Dialog transformation devis → facture |

---

## Configuration

### Injection de dépendances (`lib/config/dependency_injection.dart`)

20 providers enregistrés via `MultiProvider` :

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthViewModel()),
    ChangeNotifierProvider(create: (_) => FactureViewModel()),
    ChangeNotifierProvider(create: (_) => DevisViewModel()),
    ChangeNotifierProvider(create: (_) => ClientViewModel()),
    ChangeNotifierProvider(create: (_) => DashboardViewModel()),
    ChangeNotifierProvider(create: (_) => DepenseViewModel()),
    ChangeNotifierProvider(create: (_) => EntrepriseViewModel()),
    ChangeNotifierProvider(create: (_) => UrssafViewModel()),
    ChangeNotifierProvider(create: (_) => ArticleViewModel()),
    ChangeNotifierProvider(create: (_) => GlobalSearchViewModel()),
    ChangeNotifierProvider(create: (_) => PlanningViewModel()),
    ChangeNotifierProvider(create: (_) => ShoppingViewModel()),
    ChangeNotifierProvider(create: (_) => RelanceViewModel()),
    ChangeNotifierProvider(create: (_) => EditorStateProvider()),
    ChangeNotifierProvider(create: (_) => CorbeilleViewModel()),
    ChangeNotifierProvider(create: (_) => FactureRecurrenteViewModel()),
    ChangeNotifierProvider(create: (_) => TempsViewModel()),
    ChangeNotifierProvider(create: (_) => RappelViewModel()),
    ChangeNotifierProvider(create: (_) => RentabiliteViewModel()),
  ],
)
```

### Routing (`lib/config/router.dart`)

GoRouter avec ~30 routes et un auth guard :

- Routes publiques : `/`, `/login`, `/onboarding`, `/splash`
- Routes protégées : `/app/*` — redirigées vers `/login` si non connecté
- Passage d'objets via `state.extra`

### Theme (`lib/config/theme.dart`)

`AppTheme` — Design system **Artisan Forge 2030** complet :

- **Palette chromatique Forge** : Dark Stone (#0F172A), Vivid Fire (#EA580C), Radiant Gold (#F59E0B), Tech Indigo (#6366F1)
- **Surfaces glass** : `surfaceGlass` (72% opacité), `surfaceGlassBright` (85%), `surfaceGlassSubtle` (50%)
- **Spacing grid** : base 4px (`spacing4=4, spacing8=8, spacing16=16, spacing24=24, spacing32=32, spacing48=48`)
- **Border radius** : `small=12, medium=16, large=20, xlarge=28` (généreux, organique)
- **Ombres "Forge Glow"** : teintées par `primary` — `shadowSmall` (6%), `shadowMedium` (8%), `shadowLarge` (12%), `shadowGlow` (18%)
- **Dégradés** : `forgeGradient` (Fire→Gold), `primaryGradient` (Indigo→Violet), `goldGradient`
- **Glass decorations** : `glassDecoration`, `glassDecorationSubtle` — BoxDecoration réutilisables dark-first
- **Typographie** : Space Grotesk (titres, weight 700, letter-spacing -0.5) + Inter (corps, weight 400-500)
- **ThemeData** : Material 3, Dark Mode par défaut, bouton Forge adaptatifs, inputs glow.

---

## Utilitaires

### CalculationsUtils (`lib/utils/calculations_utils.dart`)

**100% Decimal** — Aucun double pour les calculs monétaires :

```dart
class CalculationsUtils {
  // Total HT d'une ligne : prix × quantité × (avancement / 100)
  static Decimal calculateLineTotal(Decimal prix, Decimal quantite, Decimal avancement);

  // Montant remise
  static Decimal calculateDiscount(Decimal totalHt, Decimal tauxRemise);

  // Total TVA
  static Decimal calculateTva(Decimal montantHt, Decimal tauxTva);

  // Charges sociales
  static Decimal calculateCharges(Decimal base, Decimal taux);

  // Net après charges
  static Decimal calculateNet(Decimal brut, Decimal charges);
}
```

### FormatUtils (`lib/utils/format_utils.dart`)

```dart
class FormatUtils {
  static String formatCurrency(Decimal montant);      // "1 234,56 €"
  static String formatDate(DateTime date);              // "15/02/2026"
  static String formatDateLong(DateTime date);          // "15 février 2026"
  static String formatNumero(String numero);            // "FA-2026-0001"
}
```

### ValidationUtils (`lib/utils/validation_utils.dart`)

```dart
class ValidationUtils {
  static String? validateRequired(String? value, String field);
  static String? validateEmail(String? value);
  static String? validateSiret(String? value);
  static String? validatePhone(String? value);
  static String? validatePositiveDecimal(String? value, String field);
  static String? validateCodePostal(String? value);
  static String? validateIban(String? value);
}
```

---

## Patterns clés

### 1. Loading réentrant

```dart
// _loadingDepth++ au début, _loadingDepth-- dans finally
// Permet plusieurs opérations async simultanées
await viewModel.executeOperation(() async {
  await repo.save(facture);    // loadingDepth = 1
  await repo.saveLignes(ids);  // loadingDepth toujours = 1
});
// loadingDepth = 0, isLoading = false
```

### 2. Injection constructeur optionnel

```dart
class FactureViewModel extends BaseViewModel {
  final IFactureRepository _repository;
  FactureViewModel({IFactureRepository? repository})
      : _repository = repository ?? FactureRepository();
}

// En production : fourni par Provider (pas d'argument)
// En test : mock injecté directement
final vm = FactureViewModel(repository: mockRepo);
```

### 3. Strategy Pattern PDF

Sélection dynamique du thème PDF depuis la configuration entreprise :

```dart
PdfThemeBase resolveTheme(ProfilEntreprise profil) {
  switch (profil.pdfTheme) {
    case PdfTheme.classique: return ClassiqueTheme();
    case PdfTheme.moderne: return ModerneTheme();
    case PdfTheme.minimaliste: return MinimalisteTheme();
  }
}
// Puis : theme.setCustomPrimaryColor(profil.pdfPrimaryColor);
```

### 4. Sécurité async (mounted check)

Obligatoire après chaque `await` avant d'utiliser `context` :

```dart
await viewModel.save();
if (!mounted) return;           // Dans un State<Widget>
if (!context.mounted) return;   // Quand context est paramètre
ScaffoldMessenger.of(context).showSnackBar(...);
```

### 5. Decimal obligatoire pour l'argent

```dart
// ❌ JAMAIS
double prix = 19.99;

// ✅ TOUJOURS
Decimal prix = Decimal.parse('19.99');

// Division → Rational → .toDecimal()
final prixUnit = (totalHt / quantite).toDecimal();

// Multiplication → Decimal direct
final total = prix * quantite;  // Pas de .toDecimal()
```

### 6. Auto-save avec debounce (Progress Billing)

Pattern utilisé dans `RentabiliteViewModel` pour l'auto-save transparent :

```dart
// Toggle binaire (matériel acheté/non acheté) → save immédiat
void toggleEstAchete(String id) {
  _updateLocally(id);
  _recalculerAvancements();
  _autoSave(() => _repo.updateEstAchete(id, newValue));  // Immédiat
}

// Slider progressif (avancement MO 0-100%) → debounce 400ms
void updateAvancementMo(String id, Decimal value) {
  _updateLocally(id);
  _recalculerAvancements();
  _debounceSave(() => _repo.updateAvancementMo(id, value));
}
```

Principe : mise à jour locale immédiate (UI réactive), persistance réseau différée (debounce 400ms pour sliders).

---

## Diagramme de flux

### Cycle de vie d'une facture

```
  Brouillon ──→ Validée ──→ Envoyée ──→ Payée
      │              │           │          │
      │              │           │          └── Archivage auto (>12 mois)
      │              │           └── Relance (J+7, J+15, J+30, J+45)
      │              └── Avoir (si correction nécessaire)
      └── Sauvegarde auto (SharedPreferences)
```

### Cycle de vie d'un devis

```
  Brouillon ──→ Envoyé ──→ Accepté ──→ Facturé
      │              │         │
      │              │         └── Transformation → Facture
      │              └── Refusé / Expiré
      └── Sauvegarde auto (SharedPreferences)
```

### Flux d'authentification

```
  Splash ──→ Auth Check ──→ Non connecté ──→ Login ──→ Dashboard
                    │                                       ↑
                    └── Connecté ────────────────────────────┘
                    └── Nouveau ──→ Onboarding ──→ Dashboard
```
