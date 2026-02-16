# Refactoring Architecture Dashboard

**Date:** 16/02/2026
**Objet:** Nettoyage de la vue `TableauDeBordView`.

---

## CONTEXTE
L'audit de codebase du 16/02 a révélé que la vue `TableauDeBordView` contenait de la logique métier complexe (boucles, calculs financiers, filtrage) dans ses méthodes privées :
- `_calculateImpayesFromLoaded`
- `_calculateConversionFromLoaded`

Ceci violait le principe de séparation des responsabilités (MVVM).

## CHANGEMENTS EFFECTUÉS

### 1. DashboardViewModel (`lib/viewmodels/dashboard_viewmodel.dart`)
Ajout de deux méthodes publiques pour centraliser ces calculs :
- `calculateImpayes(List<Facture> factures)` : Calcule le reste à charge des factures validées.
- `calculateConversion(List<Devis> devis)` : Calcule le ratio (Signés / Total).

### 2. TableauDeBordView (`lib/views/tableau_de_bord_view.dart`)
- Suppression des méthodes privées de calcul.
- Remplacement par des appels directs au ViewModel : `dashVM.calculateImpayes(...)`.

## BÉNÉFICES
- **Code + Propre :** La vue ne s'occupe que de l'affichage.
- **Réutilisabilité :** Les calculs sont désormais accessibles ailleurs si besoin.
- **Testabilité :** On peut désormais tester unitairement `calculateImpayes` sans instancier de Widget.
