# Guide du contributeur — ERP Artisan

> Conventions, règles de développement et processus de contribution — Dernière mise à jour : 20/02/2026

---

## Table des matières

1. [Prérequis](#prérequis)
2. [Installation](#installation)
3. [Commandes essentielles](#commandes-essentielles)
4. [Architecture & conventions](#architecture--conventions)
5. [Règles Decimal (monétaire)](#règles-decimal-monétaire)
6. [Sécurité async](#sécurité-async)
7. [Conventions Supabase](#conventions-supabase)
8. [Patterns UI Flutter](#patterns-ui-flutter)
9. [Tests](#tests)
10. [Processus de contribution](#processus-de-contribution)
11. [Checklist avant commit](#checklist-avant-commit)

---

## Prérequis

| Outil | Version minimum |
|---|---|
| Flutter | 3.38.x |
| Dart | 3.10.x |
| Git | 2.x |
| VS Code | Latest (avec extensions Flutter/Dart) |

**SDK Dart constraint :** `>=3.2.2 <4.0.0`

---

## Installation

```bash
# 1. Cloner le repo
git clone <url-du-repo>
cd erp_commercial

# 2. Installer les dépendances
flutter pub get

# 3. Vérifier l'analyse statique
dart analyze

# 4. Lancer les tests (doit être 100% vert)
flutter test

# 5. Lancer en mode dev web
flutter run -d chrome

# 6. Build Windows (production)
flutter build windows
```

**En cas de problème :**
```bash
flutter clean
flutter pub get
```

---

## Commandes essentielles

| Commande | Description |
|---|---|
| `flutter pub get` | Installe les dépendances |
| `flutter test` | Lance les 662 tests |
| `flutter test test/viewmodels/` | Tests d'un dossier |
| `flutter test test/viewmodels/facture_viewmodel_test.dart` | Test d'un fichier |
| `dart analyze` | Analyse statique (0 issues attendu) |
| `flutter run -d chrome` | Lancement web dev |
| `flutter build windows` | Build production Windows |
| `flutter clean` | Nettoie les fichiers de build |

---

## Architecture & conventions

### Pattern MVVM strict

```
Views → ViewModels (Provider/ChangeNotifier) → Repositories (Interface + Impl) → Supabase
                         ↓
                    Services (statiques, sans état)
```

**Règles :**

1. **Views** : Aucune logique métier. Uniquement de l'affichage + `Consumer<ViewModel>` / `context.read<ViewModel>()`
2. **ViewModels** : Héritent de `BaseViewModel`. Toute opération async passe par `executeOperation()` ou `execute()`
3. **Repositories** : Interface abstraite `IXxxRepository` + implémentation `XxxRepository` héritant de `BaseRepository`
4. **Services** : Classes avec méthodes `static`. Pas d'état, pas d'injection
5. **Injection** : Constructeur optionnel dans le VM, fallback vers implémentation concrète

### Nommage

| Élément | Convention | Exemple |
|---|---|---|
| Fichiers | `snake_case` | `facture_viewmodel.dart` |
| Classes | `PascalCase` | `FactureViewModel` |
| Méthodes / variables | `camelCase` | `loadFactures()` |
| Constantes | `camelCase` | `seuilFranchiseService` |
| Enums | `PascalCase` + `camelCase` values | `TypeEntreprise.microEntrepreneurService` |
| Tables SQL | `snake_case` pluriel | `factures`, `lignes_facture` |
| Colonnes SQL | `snake_case` | `total_ht`, `client_id` |
| FK SQL | `singulier_id` | `client_id`, `facture_id` |

### Structure des fichiers

Pour un nouveau domaine `xxx` :

```
lib/models/xxx_model.dart                    # Modèle avec fromMap/toMap/copyWith
lib/repositories/xxx_repository.dart          # IXxxRepository + XxxRepository
lib/viewmodels/xxx_viewmodel.dart            # XxxViewModel extends BaseViewModel
lib/views/xxx_view.dart                      # Vue principale
test/viewmodels/xxx_viewmodel_test.dart      # Tests du viewmodel
test/models/xxx_model_test.dart              # Tests du modèle (si logique)
```

Ajouter le Provider dans `lib/config/dependency_injection.dart` et la route dans `lib/config/router.dart`.

**Note :** Pour les fonctionnalités avec auto-save (ex: progress billing), privilégier :
- **Auto-save immédiat** pour les toggles binaires (ex: `toggleEstAchete`)
- **Auto-save avec debounce** (400ms) pour les sliders/inputs continus (ex: `updateAvancementMo`)

---

## Règles Decimal (monétaire)

**❌ JAMAIS `double` pour l'argent.** Utiliser le package `decimal`.

Référence : `lib/utils/calculations_utils.dart`

```dart
import 'package:decimal/decimal.dart';

// ✅ Création
final prix = Decimal.parse('19.99');
final zero = Decimal.zero;
final cent = Decimal.fromInt(100);

// ✅ Division → passe par Rational → .toDecimal() OBLIGATOIRE
final prixUnit = (totalHt / quantite).toDecimal();

// ✅ Multiplication → Decimal direct, PAS de .toDecimal()
final total = prix * quantite;

// ✅ Parsing depuis Supabase (peut être int, double ou String)
final montant = Decimal.parse(json['montant'].toString());

// ✅ Sérialisation vers Supabase
'montant': montant.toString(),

// ✅ Affichage
montant.toDouble().toStringAsFixed(2)  // "19.99"

// ❌ INTERDIT
double prix = 19.99;
num montant = json['montant'];
```

### Pourquoi ?

Les `double` IEEE 754 provoquent des erreurs d'arrondi (`0.1 + 0.2 != 0.3`). Pour un ERP financier, c'est inacceptable. Le package `Decimal` utilise une représentation exacte.

---

## Sécurité async

Après **chaque** `await` dans un widget, vérifier `mounted` avant d'utiliser `context` :

```dart
// ✅ Dans un State<Widget>
await viewModel.save();
if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(...);

// ✅ Quand context est un paramètre de fonction
await viewModel.save();
if (!context.mounted) return;
Navigator.of(context).pop();

// ❌ INTERDIT (crash si widget désmonté pendant l'await)
await viewModel.save();
ScaffoldMessenger.of(context).showSnackBar(...);
```

**Pourquoi ?** Si l'utilisateur navigue pendant un `await`, le widget est désmonté. Appeler `context` sur un widget désmonté provoque un crash.

---

## Conventions Supabase

### Tables

- **Noms** : pluriel, snake_case (`clients`, `factures`, `lignes_facture`)
- **PK** : `id UUID DEFAULT gen_random_uuid()`
- **FK** : `singulier_id` (`client_id`, `facture_id`)
- **Dates** : `TIMESTAMPTZ` toujours (jamais `TIMESTAMP` sans timezone)
- **Montants** : `NUMERIC` (pas `FLOAT` ni `DOUBLE PRECISION`)

### Insert / Update dans les repositories

```dart
// INSERT — ajoute user_id, retire id
final data = prepareForInsert(facture.toMap());
await client.from('factures').insert(data);

// UPDATE — retire user_id (RLS gère) et id
final data = prepareForUpdate(facture.toMap());
await client.from('factures').update(data).eq('id', facture.id!);
```

### Dates

```dart
// Lecture depuis Supabase
final date = DateTime.parse(map['date_emission']);

// Écriture vers Supabase
'date_emission': date.toIso8601String(),
```

### Numérotation

Gérée par `DocumentRepository.generateNextNumero()` — format `PREFIX-YYYY-NNNN`.

**Ne jamais générer de numéro côté Dart manuellement.**

### Immutabilité

Le trigger `protect_validated_facture` bloque la modification des champs financiers sur les factures validées. Pour corriger une facture validée → **créer un avoir**.

---

## Patterns UI Flutter

### DropdownButtonFormField

```dart
// ✅ CORRECT — initialValue + ValueKey pour la reconstruction
DropdownButtonFormField<String>(
  key: ValueKey(selectedValue),    // Force la reconstruction si la valeur change
  initialValue: selectedValue,      // Pas de `value:`
  items: [...],
  onChanged: (v) => setState(() => selectedValue = v),
)

// ❌ INTERDIT
DropdownButtonFormField<String>(
  value: selectedValue,  // Cause des bugs si la valeur n'est pas dans items
)
```

### Couleurs avec opacité

```dart
// ✅ Flutter 3.32+
Colors.blue.withValues(alpha: 0.5)

// ❌ Déprécié
Colors.blue.withOpacity(0.5)
```

### RadioListTile

```dart
// ✅ Wrapper RadioGroup
RadioGroup<String>(
  groupValue: selectedValue,
  onChanged: (v) => setState(() => selectedValue = v!),
  child: RadioListTile<String>(
    title: Text('Option'),
    value: 'option1',
    // PAS de groupValue/onChanged ici
  ),
)

// ❌ INTERDIT
RadioListTile<String>(
  groupValue: selectedValue,    // Géré par RadioGroup
  onChanged: (v) => ...,       // Géré par RadioGroup
)
```

### Switch

```dart
// ✅ CORRECT
Switch(
  value: isEnabled,
  onChanged: (v) => setState(() => isEnabled = v),
  activeTrackColor: Colors.green,   // Pour la couleur de la piste
)

// ❌ INTERDIT
Switch(activeColor: Colors.green)   // N'existe pas dans ce contexte
```

### ListTile

```dart
// ✅ CORRECT
ListTile(
  leading: Icon(Icons.person),
  trailing: Icon(Icons.chevron_right),
)

// ❌ INTERDIT
ListTile(secondary: Icon(Icons.person))  // secondary n'existe pas
```

### Import PDF

```dart
// ✅ CORRECT — toujours préfixer avec `pw`
import 'package:pdf/widgets.dart' as pw;

// ❌ INTERDIT — pas de `const` devant pw.TextStyle avec PdfColor.fromInt()
const pw.TextStyle(color: PdfColor.fromInt(0xFF000000));  // ERREUR
pw.TextStyle(color: PdfColor.fromInt(0xFF000000));         // ✅ OK
```

### Design tokens

Utiliser `AppTheme` (dans `lib/config/theme.dart`) pour les valeurs constantes — **Design System Aurora 2030** :

```dart
// ✅ CORRECT — Design tokens Aurora
padding: EdgeInsets.all(AppTheme.spacing16),  // 16.0
borderRadius: BorderRadius.circular(AppTheme.radiusMedium),  // 16.0
color: AppTheme.primary,  // Indigo #6366F1

// ✅ Surfaces glassmorphiques
decoration: AppTheme.glassDecoration,
background: AppTheme.surfaceGlassBright,

// ✅ Ombres colorées (teintées primary)
boxShadow: AppTheme.shadowMedium,

// ✅ Typographie
GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)  // Titres
GoogleFonts.inter()  // Corps

// ❌ INTERDIT — valeurs magiques
padding: EdgeInsets.all(16.0),
borderRadius: BorderRadius.circular(16.0),
```

**Palette Aurora :**

| Token | Couleur | Hex | Usage |
|---|---|---|---|
| `primary` | Indigo Électrique | `#6366F1` | Action principale, accents |
| `secondary` | Violet Cosmique | `#8B5CF6` | Premium, créativité |
| `accent` | Émeraude | `#10B981` | Succès, paiements |
| `highlight` | Cyan | `#06B6D4` | Highlights dynamiques |
| `error` | Rose Vif | `#F43F5E` | Erreurs, alertes |

---

## Tests

### Statistiques actuelles

- **662 tests** — 100% passants
- Structure miroir : `test/` ↔ `lib/`
- Commande : `flutter test`

### Framework

- **flutter_test** : Framework de base
- **mocktail** : Mocking des interfaces repository

### Pattern de test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// 1. Mock de l'interface (pas de l'implémentation)
class MockFactureRepository extends Mock implements IFactureRepository {}

void main() {
  late MockFactureRepository mockRepo;
  late FactureViewModel viewModel;

  setUp(() {
    mockRepo = MockFactureRepository();
    viewModel = FactureViewModel(repository: mockRepo);
  });

  group('Factures - Chargement', () {
    test('charge les factures avec succès', () async {
      // Arrange
      when(() => mockRepo.getFactures()).thenAnswer((_) async => [testFacture]);

      // Act
      await viewModel.loadFactures();

      // Assert
      expect(viewModel.factures, hasLength(1));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      verify(() => mockRepo.getFactures()).called(1);
    });
  });
}
```

### Conventions de test

| Règle | Description |
|---|---|
| **Nommage** | Descriptions en **français** dans `test()` et `group()` |
| **Arrange-Act-Assert** | Structure systématique des tests |
| **Un test, un cas** | Chaque `test()` vérifie un seul comportement |
| **Mocks dans test/mocks/** | Fichier centralisé `repository_mocks.dart` |
| **Zéro régression** | Toute modif de logique → mise à jour test correspondant |
| **Isolation** | Chaque test est indépendant (setUp/tearDown) |

### Structure des tests

```
test/
├── mocks/
│   └── repository_mocks.dart          # Tous les mocks centralisés
├── models/
│   ├── client_model_test.dart         # Tests fromMap/toMap/copyWith
│   ├── devis_model_test.dart
│   ├── entreprise_model_test.dart
│   ├── facture_model_test.dart
│   ├── facture_recurrente_model_test.dart  # Tests FactureRecurrente + LigneFactureRecurrente
│   └── rappel_model_test.dart             # Tests Rappel + getters (joursRestants, etc.)
├── viewmodels/
│   ├── facture_viewmodel_test.dart    # Tests VM complets (CRUD, workflow, etc.)
│   ├── devis_viewmodel_test.dart
│   ├── dashboard_viewmodel_test.dart
│   ├── client_viewmodel_test.dart
│   ├── depense_viewmodel_test.dart
│   ├── entreprise_viewmodel_test.dart
│   ├── urssaf_viewmodel_test.dart
│   ├── article_viewmodel_test.dart
│   ├── auth_viewmodel_test.dart
│   ├── relance_viewmodel_test.dart
│   ├── global_search_viewmodel_test.dart
│   ├── planning_viewmodel_test.dart
│   ├── shopping_viewmodel_test.dart
│   ├── corbeille_viewmodel_test.dart       # Tests corbeille soft-delete (4 entités)
│   ├── facture_recurrente_viewmodel_test.dart # Tests récurrence, toggle, compteur
│   ├── temps_viewmodel_test.dart           # Tests suivi temps, KPIs, filtrage
│   ├── rappel_viewmodel_test.dart          # Tests rappels, génération fiscale
│   └── sprint5_test.dart                   # Tests progress billing (chiffrages, avancements, rentabilité)
├── services/
│   ├── tva_service_test.dart          # Tests calculs TVA
│   ├── relance_service_test.dart      # Tests niveaux relance
│   ├── archivage_service_test.dart    # Tests détection archivage
│   ├── email_service_test.dart        # Tests envoi email
│   ├── audit_service_test.dart        # Tests logging audit
│   ├── echeance_service_test.dart     # Tests génération rappels fiscaux
│   ├── pdf_theme_custom_test.dart     # Tests thèmes PDF
│   └── design_system_test.dart        # Tests design tokens
├── utils/
│   └── calculations_utils_test.dart   # Tests calculs Decimal
└── integration/
    └── ...                            # Tests d'intégration
```

---

## Processus de contribution

### Workflow Git

1. **Créer une branche** depuis `main`
   ```bash
   git checkout -b feature/nom-de-la-feature
   ```

2. **Développer** en suivant les conventions ci-dessus

3. **Tester**
   ```bash
   flutter test                # Tous les tests
   dart analyze                # Analyse statique
   ```

4. **Commit** avec message descriptif en français
   ```bash
   git commit -m "feat: ajout gestion des relances multi-niveaux"
   ```

5. **Push** et créer une Pull Request

### Convention de commit

```
type: description courte en français

Types :
- feat:     Nouvelle fonctionnalité
- fix:      Correction de bug
- refactor: Refactoring sans changement fonctionnel
- test:     Ajout ou modification de tests
- docs:     Documentation
- style:    Formatage, style de code
- chore:    Tâches de maintenance
```

---

## Checklist avant commit

- [ ] `flutter test` → 662/662 tests verts (ou plus si nouveaux tests ajoutés)
- [ ] `dart analyze` → 0 issues
- [ ] Pas de `double` pour l'argent → `Decimal` partout
- [ ] `mounted` / `context.mounted` vérifié après chaque `await` dans les widgets
- [ ] `.withValues(alpha:)` utilisé (pas `.withOpacity()`)
- [ ] `initialValue` + `ValueKey` sur les `DropdownButtonFormField`
- [ ] Design tokens Aurora de `AppTheme` utilisés (pas de valeurs magiques, pas de `Colors.black` pour les ombres)
- [ ] Surfaces glass (`surfaceGlass*`, `glassDecoration`) pour les conteneurs
- [ ] Interface repository créée/mise à jour si nouveau repository
- [ ] Provider ajouté dans `dependency_injection.dart` si nouveau VM
- [ ] Route ajoutée dans `router.dart` si nouvelle vue
- [ ] Tests ajoutés/mis à jour pour toute nouvelle logique
- [ ] Descriptions de tests en français
