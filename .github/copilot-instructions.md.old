# ERP Artisan - Instructions Copilot

**Rôle:** Lead Senior Flutter Architect pour cette application ERP.  
**Objectif:** Zéro dette technique, 100% type safety, code production sans crash.  
**Langue:** Toujours répondre en FRANÇAIS.

Application Flutter Web SaaS de gestion commerciale avec backend Supabase.

## Architecture

**MVVM + Provider + GoRouter**: ViewModels dans `lib/viewmodels/`, Views dans `lib/views/`, Models dans `lib/models/`.
- ViewModels héritent de `ChangeNotifier`, injectés via `MultiProvider` dans `lib/config/dependency_injection.dart`
- Navigation: `go_router` avec guards d'auth dans `lib/config/router.dart`
- Dans `build()`: `context.watch<T>()` ou `Consumer<T>` (avec `listen: true`)
- Dans callbacks: `Provider.of<T>(context, listen: false)`
- **Loading State:** Utiliser le pattern `_loadingDepth` (Reentrant Counter) pour les appels async imbriqués

## Règles Critiques Decimal

**❌ JAMAIS `double` pour l'argent.** Utiliser `Decimal` du package `decimal`.

```dart
// ✅ Division: OBLIGATOIRE .toDecimal() (retourne Rational)
final prixUnitaire = (totalHt / quantite).toDecimal();

// ✅ Multiplication: PAS de .toDecimal() (retourne déjà Decimal)
final totalLigne = prixUnitaire * quantite;

// Parsing JSON
final prix = Decimal.parse(json['prix'].toString());

// Affichage
final display = montant.toDouble().toStringAsFixed(2);
```

## Sécurité Async

**Après CHAQUE `await`**, insérer `if (!mounted) return;` avant d'utiliser `context`:

```dart
await viewModel.saveData();
if (!mounted) return;
Navigator.push(context, ...);
```

## Conventions Supabase

- **Tables**: Pluriel (`clients`, `factures`, `devis`)
- **Foreign Keys**: Singulier + `_id` (`client_id`, `user_id`)
- **Updates**: Retirer `user_id` du map (RLS policy)
- **Dates**: `DateTime.parse()` pour lire, `.toIso8601String()` pour écrire

```dart
// fromMap
dateEmission: DateTime.parse(map['date_emission']),

// toMap
'date_emission': dateEmission.toIso8601String()
```

## Patterns UI Flutter

**Dropdowns**: Éviter `value`, utiliser `initialValue` + `key`:
```dart
DropdownButtonFormField<String>(
  key: ValueKey(selectedValue),
  initialValue: selectedValue,
  items: [...],
)
```

**Colors**: `withOpacity()` est déprécié, utiliser:
```dart
color.withValues(alpha: 0.5)
```

**ListTile**: ❌ Ne jamais utiliser `secondary`. ✅ Utiliser `leading` ou `trailing`.

**PDF**: Importer avec alias obligatoire:
```dart
import 'package:pdf/widgets.dart' as pw;
// Utiliser pw.Text, pw.Container, etc.
// ❌ JAMAIS const devant pw.TextStyle avec PdfColor.fromInt()
```

## Navigation avec Objets

Passer des objets complexes via `extra`:

```dart
// Sender
context.push('/ajout_devis/123', extra: monDevis);

// Receiver (router.dart)
final devis = state.extra as Devis?;
```

## Services & Repositories

**Repositories** (`lib/repositories/`): Pattern Interface + Implémentation
```dart
// Interface pour injection de dépendances et tests
abstract class IFactureRepository {
  Future<List<Facture>> getFactures({bool archives = false});
  Future<Facture> createFacture(Facture facture);
  // ...
}

// Implémentation concrète
class FactureRepository implements IFactureRepository {
  final SupabaseClient _client = SupabaseConfig.client;
  // Accès direct à Supabase
}
```

**Services** (`lib/services/`): Logique métier transverse
- `PdfService`: Génération PDF avec isolates (calculs lourds)
- `LocalStorageService`: Auto-save brouillons (shared_preferences)
- `ExportService`: Export CSV/Excel
- Pas d'interface abstraite (services utilitaires)

**Injection ViewModel**: Repositories injectés via constructeur pour faciliter les tests
```dart
class FactureViewModel extends ChangeNotifier {
  final IFactureRepository _repository;
  
  FactureViewModel({IFactureRepository? repository})
      : _repository = repository ?? FactureRepository();
}
```

## Tests

**Mocktail** pour les mocks, structure `test/` miroir de `lib/`:
- `test/viewmodels/` → Tests unitaires ViewModels
- `test/widgets/` → Tests widgets
- `test/models/` → Tests models (fromMap/toMap)

**RÈGLES STRICTES:**
- ❌ **Zéro Régression**: Chaque modification de logique métier (ViewModels, Models, Utils) DOIT s'accompagner de la mise à jour du test correspondant
- ✅ **100% Success Rate**: `flutter test` doit TOUJOURS retourner 100% de succès
- Mocker les repositories/services avec `mocktail`

```dart
// Exemple test ViewModel
class MockFactureRepository extends Mock implements IFactureRepository {}

void main() {
  late FactureViewModel viewModel;
  late MockFactureRepository mockRepo;

  setUp(() {
    mockRepo = MockFactureRepository();
    viewModel = FactureViewModel(repository: mockRepo);
  });

  test('createFacture should call repository', () async {
    when(() => mockRepo.createFacture(any())).thenAnswer((_) async => facture);
    await viewModel.saveFacture();
    verify(() => mockRepo.createFacture(any())).called(1);
  });
}
```

Commande: `flutter test`

## Workflow & Comportement

**Deep Scan avant modification:**
- Avant de modifier un fichier, vérifier ses références (imports, dépendances)
- Ne jamais casser les imports ou la logique dans les fichiers dépendants

**Refactoring proactif:**
- Si tu vois du code fragile (ex: simple `bool isLoading` au lieu de `_loadingDepth`), suggérer le refactoring vers le pattern standard

**Ton:**
- Franc, concis, techniquement précis
- Ne pas s'excuser, juste corriger

## Fichiers Clés

- `lib/config/dependency_injection.dart`: Injection Provider
- `lib/config/router.dart`: Routes et redirections auth
- `lib/models/`: Tous avec `fromMap()`, `toMap()`, `copyWith()`
- `AI_RULES.md`: Règles techniques détaillées
- `ARCHITECTURE_REFERENCE.md`: Référence complète
