# ERP Artisan — Instructions Copilot

**Langue:** Toujours répondre en **FRANÇAIS**.  
Flutter Web SaaS de gestion commerciale (devis, factures, avoirs, relances, URSSAF) pour micro-entrepreneurs. Backend Supabase (PostgreSQL + RLS).

## Architecture MVVM

```
Views → ViewModels (Provider/ChangeNotifier) → Repositories (Interface + Impl) → Supabase
                         ↓
                    Services (PDF, CSV, Relance, Archivage)
```

- **ViewModels** héritent de `BaseViewModel` (`lib/core/base_viewmodel.dart`) : pattern `_loadingDepth` réentrant + `executeOperation()` pour tout appel async
- **Repositories** : interface abstraite `IXxxRepository` + implémentation concrète héritant de `BaseRepository` (`lib/core/base_repository.dart`)
- **Injection** : constructeur optionnel dans les VMs (`IFactureRepository? repository`) → fallback vers impl concrète. Enregistrés dans `lib/config/dependency_injection.dart` via `ChangeNotifierProvider`
- **Navigation** : GoRouter dans `lib/config/router.dart`, auth guard redirige `/app/*` → `/login` si non connecté. Objets passés via `state.extra`
- **Mixins** : `AutoSaveMixin` (brouillons SharedPreferences) et `PdfGenerationMixin` (génération PDF) sur DevisViewModel/FactureViewModel

## Règles Decimal (package `decimal`)

**❌ JAMAIS `double` pour l'argent.** Référence : `lib/utils/calculations_utils.dart`

```dart
// Division → Rational, OBLIGATOIRE .toDecimal()
final prix = (totalHt / quantite).toDecimal();

// Multiplication → Decimal, PAS de .toDecimal()
final total = prix * quantite;

// Parsing Supabase
final montant = Decimal.parse(json['montant'].toString());

// Affichage
montant.toDouble().toStringAsFixed(2)
```

## Sécurité Async

Après **chaque** `await` dans un widget, avant d'utiliser `context` :

```dart
await viewModel.save();
if (!mounted) return;           // Dans un State
if (!context.mounted) return;   // Quand context est un paramètre
ScaffoldMessenger.of(context)...
```

## Conventions Supabase

- **Tables** : pluriel (`clients`, `factures`, `devis`, `paiements`)
- **FK** : singulier + `_id` (`client_id`, `user_id`)
- **Insert** : `BaseRepository.prepareForInsert()` ajoute `user_id`, retire `id`
- **Update** : `BaseRepository.prepareForUpdate()` retire `user_id` (RLS) et `id`
- **Dates** : `DateTime.parse()` en lecture, `.toIso8601String()` en écriture
- **Numérotation** : gérée par trigger SQL (pas de génération côté Dart)
- **Immutabilité** : trigger `protect_validated_facture` bloque modification des factures validées

## Patterns UI Flutter

- **DropdownButtonFormField** : `initialValue` + `key: ValueKey(val)` — jamais `value:`
- **Couleurs** : `.withValues(alpha: 0.5)` — jamais `.withOpacity()`
- **RadioListTile** : wrapper `RadioGroup<T>(groupValue:, onChanged:, child:)` — pas groupValue/onChanged sur le tile
- **Switch** : `activeTrackColor:` — jamais `activeColor:`
- **ListTile** : `leading`/`trailing` — jamais `secondary`
- **PDF** : `import 'package:pdf/widgets.dart' as pw;` — jamais `const` devant `pw.TextStyle` avec `PdfColor.fromInt()`
- **Design tokens** : `AppTheme` dans `lib/config/theme.dart` (spacing, radius, shadows, couleurs status)

## Modèles

Tous dans `lib/models/` avec `fromMap()`, `toMap()`, `copyWith()`. 14 modèles dont :
- `Facture` + `LigneFacture` : cycle brouillon → validée → envoyée → payée, avoirs en montants positifs
- `Devis` + `LigneDevis` : stepper 4 étapes (`lib/views/devis/stepper/`)
- `ProfilEntreprise` : identité, TVA, mentions légales, thème PDF (`PdfTheme` enum), couleur custom

## PDF — Strategy Pattern

`lib/services/pdf_themes/` : `PdfThemeBase` (abstraite) → `ClassiqueTheme`, `ModerneTheme`, `MinimalisteTheme`.  
`PdfService` (`lib/services/pdf_service.dart`) : isolate-ready via `PdfGenerationRequest`, résolution dynamique du thème depuis `ProfilEntreprise.pdfTheme`.

## Tests

**550 tests**, structure miroir `test/` ↔ `lib/`. Commande : `flutter test`

- **Mocking** : `mocktail` — mocks dans `test/mocks/`
- **Pattern** : mock l'interface repository, injecte dans le VM via constructeur
- **Zéro régression** : toute modif de logique métier → mise à jour du test correspondant
- **Nommage** : descriptions en français dans les `test()` et `group()`

```dart
class MockFactureRepository extends Mock implements IFactureRepository {}
setUp(() {
  mockRepo = MockFactureRepository();
  viewModel = FactureViewModel(repository: mockRepo);
});
```

## Fichiers clés

| Fichier | Rôle |
|---|---|
| `lib/config/dependency_injection.dart` | 14 Providers enregistrés |
| `lib/config/router.dart` | ~22 routes + auth guard |
| `lib/core/base_viewmodel.dart` | Loading réentrant + executeOperation |
| `lib/core/base_repository.dart` | prepareForInsert/Update + handleError |
| `lib/utils/calculations_utils.dart` | Calculs financiers 100% Decimal |
| `lib/services/pdf_service.dart` | Génération PDF isolate-ready |
| `lib/config/theme.dart` | AppTheme (design tokens, couleurs, spacing) |

## Schéma BDD Supabase (résumé)

13 tables avec RLS activé sur toutes. Montants en `NUMERIC`, dates en `TIMESTAMPTZ`, PK en `UUID`.

| Table | Colonnes clés | Relations |
|---|---|---|
| `clients` | nom_complet, type_client, siret, tva_intra, adresse, email | → factures, devis |
| `factures` | numero_facture, objet, client_id (FK), type_document (`facture`/`avoir`), statut, statut_juridique, total_ht/tva/ttc, remise_taux, est_archive, numero_bon_commande, motif_avoir, taux_penalites_retard | → lignes_facture, paiements |
| `lignes_facture` | facture_id (FK), description, quantite, prix_unitaire, total_ligne, type_activite, taux_tva, avancement, ordre | |
| `paiements` | facture_id (FK), montant, date_paiement, type_paiement, is_acompte | |
| `devis` | numero_devis, client_id (FK), duree_validite, taux_acompte, devis_parent_id (self FK avenants) | → lignes_devis, → factures |
| `lignes_devis` | devis_id (FK), mêmes champs que lignes_facture | |
| `entreprises` | nom_entreprise, siret, type_entreprise, regime_fiscal, tva_applicable, pdf_theme, pdf_primary_color, mode_facturation, taux_penalites_retard, escompte_applicable, est_immatricule | 1:1 par user |
| `depenses` | description, montant, date_depense, categorie, est_deductible | |
| `articles` | designation, prix_unitaire, unite, type_activite, categorie | |
| `cotisations` | periode, montant_ca, taux_cotisation, montant_cotisation, est_paye | |
| `audit_logs` | table_name, record_id, action (`INSERT`/`UPDATE`/`DELETE`/`VALIDATE`/`PAYMENT`/`EMAIL_SENT`/`RELANCE_SENT`), old_data (JSONB), new_data (JSONB) | |
| `events` | titre, date_debut, date_fin, client_id | |
| `shopping_items` | nom, quantite, prix, is_checked | |

### Triggers SQL actifs

| Trigger | Table | Rôle |
|---|---|---|
| `trg_audit_factures` | factures | Log INSERT/UPDATE/DELETE → audit_logs |
| `trg_audit_devis` | devis | Log INSERT/UPDATE/DELETE → audit_logs |
| `trg_audit_paiements` | paiements | Log INSERT/UPDATE/DELETE → audit_logs (résout user_id via facture) |
| `trg_protect_validated_facture` | factures | **BEFORE UPDATE** — bloque modif de total_ht, total_tva, total_ttc, objet, client_id, remise_taux, conditions_reglement si statut_juridique ≠ brouillon |
| `trg_*_updated_at` | factures, devis, paiements, clients, depenses | Auto `updated_at = NOW()` |

### Migrations (dossier `migrations/`)

1. `migration_sprint1_legal_compliance.sql` — audit_logs, triggers audit, trigger immutabilité, champs légaux
2. `migration_sprint5_updated_at.sql` — colonne updated_at + triggers auto-update sur 5 tables
3. `migration_sprint8_audit_email.sql` — extension CHECK constraint (EMAIL_SENT, RELANCE_SENT)
4. `migration_sprint9_pdf_custom.sql` — colonnes pdf_primary_color, logo_footer_url

## Services (statiques, sans état)

| Service | Méthodes clés |
|---|---|
| `TvaService` | `analyserActivite(caYtd, type)` → StatutTva, `analyser(caService, caCommerce)`, `simulerAvecMontant()`. Seuils : service 36800/39100€, commerce 91900/101000€ |
| `RelanceService` | `analyserRelances(factures)` → List<RelanceInfo>, `genererTexteRelance()`. 4 niveaux : J+7, J+15, J+30, J+45 |
| `ArchivageService` | `detecterArchivables(factures)` — soldées + non archivées + > 12 mois |
| `EmailService` | `envoyerDevis()`, `envoyerFacture()`, `envoyerRelance()` — via url_launcher mailto: |
| `AuditService` | `logEnvoiEmail()`, `logRelance()` — insert audit_logs, fail-safe |
| `ExportService` | `exportComptabilite()` (2 CSVs recettes+dépenses), `exportFactures()` |
| `PdfService` | `generatePdf(PdfGenerationRequest)` — résout thème depuis ProfilEntreprise |
| `LocalStorageService` | `saveDraft()`, `getDraft()`, `clearDraft()` — SharedPreferences |
| `PreferencesService` | `getConfigCharges()`, `saveConfigCharges()` — config charges sociales |

## Documentation détaillée

| Document | Contenu |
|---|---|
| `documentation/ARCHITECTURE.md` | Architecture complète, arborescence, patterns, diagrammes de flux |
| `documentation/API_REFERENCE.md` | Signatures exhaustives de toutes les couches (core, models, repos, VMs, services, utils) |
| `documentation/DATABASE.md` | Schéma BDD complet : colonnes, types, FK, triggers, RLS, migrations |
| `documentation/CONTRIBUTING.md` | Guide contributeur : conventions, règles, tests, checklist |

## Build & Run

```bash
flutter pub get
flutter test                    # 550 tests, doit être 100% vert
flutter build windows           # Build Windows (prod)
flutter run -d chrome           # Dev web
flutter clean                   # Si fichiers éphémères corrompus
```
