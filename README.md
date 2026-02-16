# ERP Artisan - SaaS de Gestion Commerciale

**ERP Artisan** est une solution SaaS moderne développée en **Flutter Web**, conçue pour simplifier la gestion quotidienne des artisans et TPE du bâtiment.

L'application permet de gérer l'intégralité du cycle commercial : Clients, Devis, Factures, Acomptes, Avoirs, Paiements et Tableaux de bord financiers.

---

## 🚀 Fonctionnalités Clés

### 📄 Gestion Commerciale Complète
- **Devis & Factures** : Édition intuitive avec calculs automatiques (HT, TVA, TTC).
- **Acomptes & Avoirs** : Gestion native des situations complexes (acompte déduit, avoir sur facture).
- **Bibliothèque Articles** : Base de données produits/services pour une saisie rapide.
- **Signature Électronique** : Signature des devis directement sur l'écran (ou tablette).

### 🎨 Éditeur de Documents Riche
- **Mise en page avancée** : Titres, Sous-titres, Textes libres, Sauts de page forcés.
- **Calculs temps réel** : Aperçu immédiat des totaux et du reste à charge.
- **Rendu PDF** : Génération de PDF professionnels (via `pdf` et `printing`) avec logo et couleurs de l'entreprise.

### 📊 Pilotage & Tableau de Bord
- **KPIs Financiers** : Chiffre d'Affaires, Trésorerie, Impayés.
- **Graphiques** : Évolution du CA mensuel/annuel.
- **Suivi URSSAF** : Estimation des cotisations selon le statut (Micro, TNS, SASU...).

### 🔒 Sécurité "Top Niveau" (Blindée)
- **RLS (Row Level Security)** : Isolation stricte des données (un utilisateur ne voit QUE ses données).
- **Intégrité des Données** : Contraintes SQL strictes (Prix positifs, Emails valides, Quantités cohérentes).
- **Numérotation Certifiée** : Séquences sans trou respectant la législation anti-fraude TVA.

---

## 🛠️ Stack Technique

- **Frontend** : Flutter Web (Channel Stable).
- **Backend / BDD** : Supabase (PostgreSQL 15+).
- **State Management** : Provider.
- **Navigation** : GoRouter.
- **PDF Generation** : `pdf` + `printing`.
- **Calculs** : `decimal` (Pour une précision financière absolue).

---

## 📁 Structure du Projet

```
lib/
├── config/         # Thèmes, Routes, Constantes
├── models/         # Modèles de données (avec Decimal)
├── repositories/   # Couche d'accès aux données (Supabase)
├── services/       # Services tiers (PDF, Storage, Auth)
├── viewmodels/     # Logique métier (State management)
├── views/          # Écrans de l'application
├── widgets/        # Composants réutilisables
└── main.dart       # Point d'entrée
```

---

## 🔐 Sécurité & Conformité (Audit Février 2026)

Le projet a subi un audit de sécurité approfondi et un durcissement (Hardening).
La documentation complète est disponible dans : `documentation/audit_2026_02/`.

- [x] **RLS Strict** : Chaque accès BDD est vérifié par le moteur SQL.
- [x] **Protection Anti-Injection** : Usage exclusif des méthodes RPC/Query paramétrées.
- [x] **Droit à l'oubli** : Configuré via CASCADE DELETE.

---

## 🏁 Installation & Démarrage

1.  **Pré-requis** : Flutter SDK installé, compte Supabase configuré.
2.  **Configuration** :
    Créer un fichier `.env` ou configurer les clés dans `lib/config/supabase_config.dart`.
3.  **Lancer en Local** :
    ```bash
    flutter run -d chrome
    ```
4.  **Tests** :
    ```bash
    flutter test
    flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
    ```

---

*Généré par l'Assistant IA Lead Dev - Février 2026*
