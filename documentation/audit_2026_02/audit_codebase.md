# RAPPORT D'AUDIT CODEBASE - ERP ARTISAN

**Date:** 16/02/2026
**Auditeur:** Senior Staff Engineer (Agent IG)
**Cible:** Flutter Web SaaS / Supabase

---

## 📊 SYNTHÈSE

L'analyse statique approfondie révèle une codebase globalement saine et respectueuse des contraintes critiques (Decimal, Web Compat, Async Safety). Cependant, des fuites de logique métier dans l'UI et une potentielle fragilité sur les permissions RLS (pour les paiements) ont été détectées.

---

## 🔴 1. SÉCURITÉ & STABILITÉ (CRITIQUE)

### ✅ A. Sécurité Async (Context Gap)
**Statut:** CONFORME
L'audit des vues critiques (`LoginView`, `AjoutFactureView`, `ProfilEntrepriseView`) montre une discipline stricte sur l'utilisation de `if (!mounted) return;` après chaque instruction `await` et avant toute utilisation du `context`.
- **Preuve:** `LoginView.dart` (~L38), `AjoutFactureView.dart` (~L435, L462, L518).

### 🔵 B. Money Typing (Decimal)
**Statut:** MINEUR / À SURVEILLER
L'utilisation du type `Decimal` est généralisée dans les Modèles et Calculs.
- **Fichier:** `lib/models/facture_model.dart` (~L67)
- **Problème:** Utilisation de valeurs par défaut `double` converties en string : `map['taux_tva'] ?? 20.0`. Bien que fonctionnel, cela introduit un type flottant intermédiaire.
- **Conseil:** Utiliser `20` (int) ou `'20.0'` (string) directement.

### 🟠 C. Fuites de Données / RLS Supabase
**Statut:** RISQUE IDENTIFIÉ
`FactureRepository` gère correctement le champ `user_id` pour les factures (ajout à la création, suppression à l'update).
- **Fichier:** `lib/repositories/facture_repository.dart` (~L163)
- **Problème:** La méthode `addPaiement` insère un paiement **SANS** injecter explicitement `user_id`.
- **Risque:** Si la table `paiements` active le RLS (Row Level Security) basé sur `auth.uid()`, l'insertion pourrait échouer ou la ligne être invisible si la colonne `user_id` est requise et non déduite par défaut.
- **Correctif:** Vérifier le schéma DB. Si `paiements.user_id` existe, l'ajouter explicitement dans le Repository.

### ✅ D. Web Compatibility
**Statut:** CONFORME
Aucune trace de `dart:io` ou `File` dans le code source.
- `PdfService` utilise `package:http` et `TypedData`.
- `LocalStorageService` utilise `shared_preferences`.

---

## 🟠 2. ARCHITECTURE & PERFORMANCE

### 🟠 A. Logique Métier dans l'UI
**Statut:** NON CONFORME (Sur 2 points)

**1. Dashboard (KPIs)**
- **Fichier:** `lib/views/tableau_de_bord_view.dart` (~L250, ~L275)
- **Problème:** Les méthodes `_calculateImpayesFromLoaded` et `_calculateConversionFromLoaded` contiennent de la logique métier (filtrage, itération, calculs financiers).
- **Correctif:** Déplacer ces méthodes dans `DashboardViewModel`. La vue ne doit faire que de l'affichage.

**2. LigneEditor (Calculs dupliqués)**
- **Fichier:** `lib/widgets/ligne_editor.dart` (~L186)
- **Problème:** Le widget recalcule le total de la ligne `(q * pu * av)` pour l'affichage local. Ce calcul est **dupliqué** par rapport à la vue parente `AjoutFactureView`.
- **Risque:** Désynchronisation si la formule change à un seul endroit.
- **Correctif:** Passer le total calculé via les props ou utiliser `CalculationsUtils`.

### ✅ B. Boucles de Rendu
**Statut:** CONFORME
Les ViewModels utilisent correctement des flags `_isLoading` et des `Timer` (debounce) pour éviter les boucles infinies lors des mises à jour (ex: PDF Preview dans `FactureViewModel`).

### ✅ C. PDF & Const Styles
**Statut:** CONFORME
Les couleurs sont définies comme `static const` mais utilisées correctement dans les styles dynamiques de `pdf` (package). Pas d'erreur de compilation release détectée.

---

## 📋 PLAN D'ACTION SUGGÉRÉ

1.  **Refactor UI Logic:** Déplacer les calculs de KPI du `TableauDeBordView` vers `DashboardViewModel`.
2.  **Verify RLS:** Confirmer si la table `paiements` nécessite `user_id` et corriger `FactureRepository` si besoin.
3.  **Cleanup:** Remplacer les valeurs par défaut `20.0` (double) par `20` (int) dans les `fromMap`.

---
*Fin du rapport.*
