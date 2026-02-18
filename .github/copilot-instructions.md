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

**527 tests**, structure miroir `test/` ↔ `lib/`. Commande : `flutter test`

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

## Build & Run

```bash
flutter pub get
flutter test                    # 527 tests, doit être 100% vert
flutter build windows           # Build Windows (prod)
flutter run -d chrome           # Dev web
flutter clean                   # Si fichiers éphémères corrompus
```
