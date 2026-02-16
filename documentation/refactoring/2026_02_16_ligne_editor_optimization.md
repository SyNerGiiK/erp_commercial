# Refactoring LigneEditor (Clean Architecture)

**Date:** 16/02/2026
**Objet:** Centralisation de la logique de calcul de prix par ligne.
**Branche:** `refactor/optimize-ligne-editor`

---

## PROBLEME
Le calcul du total d'une ligne de facture était dupliqué à deux endroits :
1.  Dans le widget `LigneEditor` (pour l'affichage temps réel).
2.  Dans la vue parente `AjoutFactureView` (pour la persistence).

De plus, la logique spécifique aux factures de **situation** (`(Qmm * PU * Av%)`) était codée "en dur" dans ces deux fichiers, augmentant le risque d'erreur ou d'incohérence.

## SOLUTION (DRY - Don't Repeat Yourself)
Une méthode unique et testable a été créée dans `CalculationsUtils`.

### 1. `CalculationsUtils`
Nouvelle signature :
```dart
static Decimal calculateTotalLigne(Decimal qte, Decimal pu, {bool isSituation = false, Decimal? avancement})
```
Elle gère désormais nativement la logique d'avancement.

### 2. Files Updated
- `lib/widgets/ligne_editor.dart` : Utilise désormais `CalculationsUtils` au lieu de sa propre formule.
- `lib/views/ajout_facture_view.dart` : Idem.

## RESULTAT
- **Fiabilité :** Une seule source de vérité pour le prix d'une ligne.
- **Maintenance :** Si la formule d'arrondi change, on modifie uniquement `CalculationsUtils`.
