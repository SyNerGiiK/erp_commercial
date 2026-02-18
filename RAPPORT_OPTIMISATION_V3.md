# RAPPORT D'OPTIMISATION - ERP Artisan 3.0

**Date :** 18 février 2026  
**Sprint :** Optimisation & Correctifs v3.0  
**Statut :** ✅ TERMINÉ — 0 erreur de compilation

---

## Sommaire

| # | Tâche | Priorité | Statut |
|---|-------|----------|--------|
| 1 | Verrouiller édition Devis signé | P1 | ✅ |
| 2 | Autoriser édition Devis envoyé | P1 | ✅ |
| 3 | Ajouter champ `acomptePercentage` | P2 | ✅ |
| 4 | Enums PDF + Préférences entreprise | P2 | ✅ |
| 5 | Refonte Settings en accordéon | P2 | ✅ |
| 6 | Architecture PDF Multi-Thèmes | P2 | ✅ |
| 7 | Séparation Module Analyse (Rentabilité) | P2 | ✅ |
| 8 | Ventilation URSSAF BIC/BNC | P2 | ✅ |
| 9 | Indicateur "Analysé" sur liste devis | P3 | ✅ |

---

## Détail des implémentations

### 1. Verrouiller édition Devis signé (P1)

**Fichiers modifiés :**
- `lib/views/devis/stepper/steps/step3_lignes.dart`
- `lib/views/devis/stepper/devis_stepper_view.dart`
- `lib/widgets/ligne_editor.dart`

**Changements :**
- `Step3Lignes` reçoit un paramètre `readOnly` calculé à partir du statut (`signe` ou `annule`)
- Quand `readOnly = true` : bannière d'info orange, boutons d'ajout masqués, `LigneEditor` non interactif
- `LigneEditor.onChanged` et `LigneEditor.onDelete` rendus nullable (suppression du `required`) pour le mode lecture seule
- Le stepper (`devis_stepper_view.dart`) propage le statut vers step3

---

### 2. Autoriser édition Devis envoyé (P1)

**Fichier modifié :**
- `lib/views/devis/stepper/devis_stepper_view.dart`

**Changement :**
- La condition de lecture seule est `statut == 'signe' || statut == 'annule'` uniquement
- Les devis au statut `envoye` restent éditables (demande métier)

---

### 3. Ajouter `acomptePercentage` au modèle Devis (P2)

**Fichier modifié :**
- `lib/models/devis_model.dart`

**Changements :**
- Nouveau champ `Decimal acomptePercentage` avec valeur par défaut `Decimal.fromInt(30)`
- Intégré dans `fromMap()` (parsing sécurisé `Decimal.parse(toString())`)
- Intégré dans `toMap()` (sérialisé en `toDouble()`)
- Intégré dans `copyWith()`
- Le stepper lit et écrit ce champ depuis `_buildDevisFromState()`

---

### 4. Enums PDF + Préférences entreprise (P2)

**Fichiers modifiés :**
- `lib/models/enums/entreprise_enums.dart`
- `lib/models/entreprise_model.dart`

**Nouveaux enums :**
- `PdfTheme` : `moderne`, `classique`, `minimaliste` — avec extension `label` + `description`
- `ModeFacturation` : `global`, `detaille` — avec extension `label` + `description`

**Nouveaux champs dans `ProfilEntreprise` :**
- `PdfTheme pdfTheme` (défaut: `moderne`)
- `ModeFacturation modeFacturation` (défaut: `global`)
- `bool modeDiscret` (défaut: `false`)
- Parsers statiques `_parsePdfTheme()` et `_parseModeFacturation()`
- Complet dans `fromMap()`, `toMap()`, `copyWith()`

---

### 5. Refonte Settings en accordéon (P2)

**Fichier modifié :**
- `lib/views/settings_root_view.dart`
- `lib/config/router.dart`

**Avant :** Vue simple avec `ListView` de liens menu (~80 lignes)  
**Après :** Vue accordéon `StatefulWidget` (~500 lignes) avec 3 `ExpansionPanel` :

| Panel | Contenu |
|-------|---------|
| Mon Entreprise | Logo, nom, contact, adresse, email, téléphone, signature digitale |
| Fiscalité & Légal | SIRET, TVA, config URSSAF (tous taux), IBAN/BIC, mentions légales |
| Préférences d'Édition | Mode de facturation (dropdown), Thème PDF (radio), Mode Discret (switch) |

- Bouton global **"ENREGISTRER TOUT"** sauvegarde `ProfilEntreprise` + `UrssafConfig` en un seul clic
- Routes `/app/config_urssaf` et `/app/profil` redirigent automatiquement vers `/app/parametres`

---

### 6. Architecture PDF Multi-Thèmes — Strategy Pattern (P2)

**Nouveaux fichiers :**
- `lib/services/pdf_themes/pdf_theme_base.dart` — Classe abstraite (contrat)
- `lib/services/pdf_themes/moderne_theme.dart` — Thème bleu professionnel (défaut)
- `lib/services/pdf_themes/classique_theme.dart` — Thème navy formel, bordures
- `lib/services/pdf_themes/minimaliste_theme.dart` — Thème gris épuré, lignes fines
- `lib/services/pdf_themes/pdf_themes.dart` — Barrel export + `PdfThemeFactory`

**Fichier modifié :**
- `lib/services/pdf_service.dart`

**Architecture :**
```
PdfThemeBase (abstract)
├── buildHeader()
├── buildAddresses()
├── buildTitle()
├── buildFooterMentions()
└── couleurs: primaryColor, accentColor, lightGrey, darkGrey...

PdfThemeFactory.resolve(PdfTheme enum) → PdfThemeBase
├── PdfTheme.moderne  → ModernePdfTheme
├── PdfTheme.classique → ClassiquePdfTheme
└── PdfTheme.minimaliste → MinimalistePdfTheme
```

**Refactoring PdfService :**
- Méthode `_resolveTheme(ProfilEntreprise?)` résout le thème depuis le profil
- `_generateDocumentInternal()` délègue header/addresses/title/footerMentions au thème
- 4 anciennes méthodes statiques supprimées (`_buildHeader`, `_buildAddresses`, `_buildTitle`, `_buildFooterMentions`)
- 2 couleurs orphelines supprimées (`_accentColor`, `_darkGrey`)

---

### 7. Séparation Module Analyse — Rentabilité (P2)

**Nouveau fichier :**
- `lib/views/rentabilite_view.dart` (~400 lignes)

**Fichiers modifiés :**
- `lib/views/devis/stepper/steps/step3_lignes.dart`
- `lib/config/router.dart`
- `lib/widgets/custom_drawer.dart`

**Changements :**
- **Step3 simplifié** : suppression du `TabBar`/`TabBarView` (onglets "Devis Client" / "Analyse & Marge"), ne garde que le contenu devis client
- Ajout d'un mini-bandeau bleu en bas de step3 indiquant le nombre de chiffrages avec lien vers la vue Rentabilité
- **Nouvelle route** `/app/rentabilite` → `RentabiliteView`
- **Nouveau menu** dans le drawer : index 8 "Rentabilité" avec icône `Icons.analytics`

**RentabiliteView :**
- Split view : panneau gauche = liste des devis (coche verte si analysé), panneau droit = détail
- Intègre `RentabiliteCard`, `ChiffrageEditor`, `MatiereDialog`
- Carte ventilation URSSAF avec détail BIC/BNC/Vente

---

### 8. Ventilation URSSAF BIC/BNC (P2)

**Fichier modifié :**
- `lib/utils/calculations_utils.dart`

**Nouvelles classes/méthodes :**

```dart
/// Méthode statique dans CalculationsUtils
static VentilationUrssaf ventilerCA({
  required List<LigneDevis> lignes,
  Decimal remiseTaux = Decimal.zero,
  bool isBncDefault = false,
})

/// Classe résultat
class VentilationUrssaf {
  final Decimal caVente;
  final Decimal caPrestaBIC;
  final Decimal caPrestaBNC;
  Decimal get total;
  bool get isMixte; // true si > 1 catégorie non nulle
}
```

**Logique de classification :**
- `vente`, `marchandise` → `caVente`
- `prestation_bic`, `service_bic` → `caPrestaBIC`
- `prestation_bnc`, `service_bnc` → `caPrestaBNC`
- `service` (défaut) → BIC sauf si `isBncDefault = true`
- Remise appliquée proportionnellement via coefficient

**Intégration :** Carte de ventilation dans `RentabiliteView` montrant la répartition lorsque l'activité est mixte.

---

### 9. Indicateur "Analysé" sur liste devis (P3)

**Fichier modifié :**
- `lib/views/liste_devis_view.dart`

**Changement :**
- Badge vert "Analysé" (`Icons.analytics` + texte) affiché à côté du `StatutBadge` quand `devis.chiffrage.isNotEmpty`
- Style : Container arrondi, fond vert léger `Colors.green.shade50`, texte vert foncé

---

## Fichiers impactés — Synthèse

### Fichiers créés (5)
| Fichier | Rôle |
|---------|------|
| `lib/services/pdf_themes/pdf_theme_base.dart` | Classe abstraite thème PDF |
| `lib/services/pdf_themes/moderne_theme.dart` | Thème Moderne (bleu) |
| `lib/services/pdf_themes/classique_theme.dart` | Thème Classique (navy) |
| `lib/services/pdf_themes/minimaliste_theme.dart` | Thème Minimaliste (gris) |
| `lib/services/pdf_themes/pdf_themes.dart` | Barrel export + Factory |
| `lib/views/rentabilite_view.dart` | Vue analyse rentabilité autonome |

### Fichiers modifiés (12)
| Fichier | Nature du changement |
|---------|---------------------|
| `lib/models/devis_model.dart` | +`acomptePercentage` |
| `lib/models/entreprise_model.dart` | +`pdfTheme`, `modeFacturation`, `modeDiscret` |
| `lib/models/enums/entreprise_enums.dart` | +enums `PdfTheme`, `ModeFacturation` |
| `lib/services/pdf_service.dart` | Délégation aux thèmes, suppression code mort |
| `lib/utils/calculations_utils.dart` | +`ventilerCA()`, `VentilationUrssaf` |
| `lib/config/router.dart` | +route rentabilité, redirections legacy |
| `lib/widgets/custom_drawer.dart` | +menu Rentabilité (index 8) |
| `lib/widgets/ligne_editor.dart` | `onChanged`/`onDelete` nullable |
| `lib/views/settings_root_view.dart` | Refonte complète accordéon |
| `lib/views/devis/stepper/devis_stepper_view.dart` | ReadOnly propagation |
| `lib/views/devis/stepper/steps/step3_lignes.dart` | Simplifié, bandeau chiffrage |
| `lib/views/liste_devis_view.dart` | Badge "Analysé" |

---

## Correctifs techniques appliqués

| Problème | Fichier | Correction |
|----------|---------|-----------|
| `.toDecimal()` sur `Decimal` (invalide) | `calculations_utils.dart` | Retiré — `Decimal * Decimal` retourne déjà `Decimal` |
| `loadDevis()` inexistant | `rentabilite_view.dart` | Remplacé par `fetchDevis()` |
| 4 méthodes statiques orphelines | `pdf_service.dart` | Supprimées après migration vers thèmes |
| 2 couleurs `PdfColor` inutilisées | `pdf_service.dart` | `_accentColor` et `_darkGrey` supprimées |
| Constructeur `ProfilEntreprise` incomplet | `entreprise_model.dart` | Ajout des 3 nouveaux params avec défauts |

---

## Validation

- **Compilation** : ✅ `get_errors()` → 0 erreur, 0 warning
- **Architecture** : ✅ Respect MVVM + Provider + GoRouter
- **Type Safety** : ✅ `Decimal` pour les montants, pas de `double`
- **Conventions** : ✅ Enums avec extensions, Factory pattern, Strategy pattern
