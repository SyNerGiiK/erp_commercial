## Plan : Mise en conformité et refonte workflow Devis/Factures Micro-entreprise

### TL;DR

L'application Artisan 3.0 possède une base solide (modèles, repositories, PDF, calculs Decimal). Suite aux **Sprints 1-5**, les non-conformités légales critiques sont corrigées : mentions obligatoires PDF, immutabilité des factures validées, piste d'audit, numérotation par trigger SQL, protection contre la suppression physique, référence facture source dans les avoirs PDF. Le nettoyage legacy est effectué, `updated_at` est déployé sur toutes les tables.

**Légende :** ✅ = Fait | ⚠️ = Partiel | ❌ = À faire

---

### Cadre légal (inchangé — référence)

- **CGI art. 289** : mentions obligatoires factures
- **Loi anti-fraude TVA 2018** (art. 286 I-3° bis CGI) : immutabilité, piste d'audit, numérotation chronologique
- **Code de Commerce L441-10** : pénalités de retard, indemnité 40€
- **Art. 293 B CGI** : franchise en base de TVA micro-entreprise

---

### État du diagnostic (mise à jour 18/02/2026)

#### CRITIQUE — Corrigé ✅

| # | Problème | Statut | Détail |
|---|---|---|---|
| C1 | Mentions obligatoires manquantes PDF | ✅ | Pénalités, indemnité 40€, escompte, conditions, échéance ajoutés |
| C2 | Factures validées modifiables | ✅ | Trigger SQL + vérification Dart côté repository |
| C3 | Pas de piste d'audit | ✅ | Table `audit_logs` + triggers sur factures/devis/paiements |
| C5 | CHECK bloque les avoirs | ✅ | `createAvoir` utilise désormais des montants positifs |

#### CRITIQUE — Reste à faire ❌

| # | Problème | Statut | Détail |
|---|---|---|---|
| — | Tous les problèmes critiques sont résolus | ✅ | — |

#### IMPORTANT — Corrigé ✅

| # | Statut | Détail |
|---|---|---|
| I5 | ✅ | GlobalSearchRepository : colonnes corrigées (titre, designation, type_activite) |
| I6 | ✅ | Mention « Dispensé » conditionnée par `estImmatricule` |
| I7 | ✅ | Doublon TVA supprimé des 3 thèmes |
| I10 | ✅ | `getImpayes()` utilise `netAPayer` centralisé |
| M4 | ✅ | `numero_bon_commande` ajouté à Facture |
| M5 | ✅ | `motif_avoir` ajouté à Facture |
| M10 | ✅ | Doublon `if (widget.type == 'titre')` corrigé dans LigneEditor |

#### IMPORTANT — Reste à faire ❌

| # | Problème | Statut |
|---|---|---|
| I1 | `typeDocument` vs `type` — **conservés** (axes orthogonaux : nature juridique vs mode facturation) | ✅ Classé |
| I2 | `statut` vs `statutJuridique` — **conservés** (opérationnel vs juridique, trigger SQL synchronise) | ✅ Classé |
| I3 | `Paiement.isAcompte` stocké mais jamais exploité en logique métier | ✅ Exploité dans PDF (colonne Type: Acompte/Solde) |
| I4 | `acompte_percentage` sur Devis jamais lu côté métier | ❌ |
| I8 | Vues legacy non supprimées (2 203 lignes : ajout_devis 1244L + ajout_facture 959L) | ✅ Supprimées |
| I9 | Chiffrage/rentabilité : vue séparée à auditer et mettre à jour (PAS dans le stepper, volonté utilisateur) | ✅ Auditée, cohérente |
| M1 | Pas de `updated_at` sur tables | ✅ Déployé (5 tables + triggers auto) |
| M2 | Pas de soft-delete | ❌ |
| M3 | Pas de validation Luhn SIRET | ❌ |
| M7 | Seuils TVA hardcodés | ❌ |
| M8 | Pas d'UI relances | ❌ |
| M9 | Pas d'envoi email | ❌ |

#### Migration SQL (mise à jour 18/02/2026)

- ✅ Table `audit_logs` créée avec RLS et indexes
- ✅ Triggers audit sur factures, devis, paiements (paiements corrigé : user_id via jointure factures)
- ✅ Trigger immutabilité `protect_validated_facture`
- ✅ Colonnes ajoutées : `entreprises.taux_penalites_retard`, `escompte_applicable`, `est_immatricule`
- ✅ Colonnes ajoutées : `factures.numero_bon_commande`, `motif_avoir`
- ✅ Migration appliquée en production
- ✅ Triggers BEFORE DELETE déjà existants (`prevent_devis_modification`, `prevent_facture_modification`) — bloquent DELETE si non brouillon
- ✅ `updated_at` déployé sur factures, devis, paiements, clients, depenses + triggers auto-update
- ❌ Soft-delete (`deleted_at`) non implémenté

#### Tests (mise à jour 18/02/2026)

- **401/401** tests passent (0 échec)
- Bug `annulerDevis` test corrigé (mockait `updateDevis` au lieu de `changeStatut`)
- Sprint 4 : 11 tests ajoutés (finalizeDevis sans generateNextNumero, PdfGenerationRequest.factureSourceNumero, Facture numeroBonCommande/motifAvoir, résolution source pour avoirs)
- Sprint 5 : 8 tests ajoutés (Paiement.isAcompte ventilation, Facture paiements mixtes, intégrité modèles)
- **409/409** tests passent (0 échec)

---

### Sprints restants (restructuré)

#### Sprint 4 — Finalisation sécurité DB & nettoyage numérotation ✅ TERMINÉ

| # | Tâche | Statut |
|---|---|---|
| 4.1 | **Triggers BEFORE DELETE** : déjà existants en DB (`prevent_devis_modification`, `prevent_facture_modification`) — bloquent DELETE si statut != brouillon | ✅ |
| 4.2 | **Supprimer `generateNextNumero()`** de `DevisRepository.finalizeDevis()` : simplifié, délègue au trigger SQL | ✅ |
| 4.3 | **Résoudre `factureSourceNumero`** : paramètre threadé dans `PdfGenerationRequest` → `generateDocument()` → `_generateDocumentInternal()` → `_buildFooterSignatures()`. Résolu côté `FactureViewModel` et `liste_factures_view.dart` | ✅ |
| 4.4 | **Champs steppers** : `numero_bon_commande` et `motif_avoir` (conditionnel) ajoutés dans `Step2Details` facture | ✅ |
| 4.5 | **Tests** : 11 tests ajoutés (finalizeDevis, PdfGenerationRequest, Facture model, résolution source) | ✅ |

#### Sprint 5 — Nettoyage legacy & audit rentabilité ✅ TERMINÉ

| # | Tâche | Statut |
|---|---|---|
| 5.1 | **Supprimer vues legacy** : `ajout_devis_view.dart` (1244L) et `ajout_facture_view.dart` (959L) supprimés | ✅ |
| 5.2 | **Nettoyer imports/routes** : import orphelin `ajout_facture_view.dart` supprimé du routeur | ✅ |
| 5.3 | **Auditer `rentabilite_view.dart`** : vue cohérente (404L), utilise correctement DevisViewModel, UrssafViewModel, LigneChiffrage, CalculationsUtils.ventilerCA, RentabiliteCard, ChiffrageEditor | ✅ |
| 5.4 | **Exploiter `Paiement.isAcompte`** : colonne "Type" (Acompte/Solde) ajoutée dans le tableau PDF des règlements | ✅ |
| 5.5 | **`updated_at`** : migration appliquée (5 tables + trigger `set_updated_at()` auto), backfill `created_at` pour existants | ✅ |
| 5.6 | **Tests** : 8 tests ajoutés | ✅ |

#### Sprint 6 — Gestion TVA & dépassement de seuil (Priorité IMPORTANTE)

| # | Tâche | Fichiers |
|---|---|---|
| 6.1 | **Créer `TvaService`** : calcul CA cumulé YTD, comparaison seuils, détection dépassement, gestion transition franchise → assujettissement | `lib/services/tva_service.dart` |
| 6.2 | **Seuils versionnés** : table `seuils_tva` ou configuration dans `UrssafConfig` par année | Migration SQL, `urssaf_configs` |
| 6.3 | **Alertes UI** : dans steppers devis/facture, si dépassement détecté → alerte + forcer `tva_applicable = true` | Steppers |
| 6.4 | **Widget dashboard** : « Suivi seuil TVA » avec progression vers les plafonds | `lib/widgets/dashboard/` |
| 6.5 | **Tests TvaService** | `test/services/` |

#### Sprint 7 — Refonte Custom Drawer & Profil Entreprise (Priorité IMPORTANTE)

| # | Tâche | Fichiers |
|---|---|---|
| 7.1 | **Refonte `custom_drawer.dart`** : design moderne, navigation fluide, sections regroupées logiquement (Activité, Documents, Outils, Paramètres), typographies et icônes mis à jour | `lib/widgets/custom_drawer.dart` |
| 7.2 | **Refonte profil entreprise** : interface claire avec sections (Identité, Facturation, TVA, Mentions légales, Personnalisation PDF), accès direct depuis drawer | `lib/views/profil_entreprise_view.dart` |
| 7.3 | **Onboarding guidé** : assistant première connexion (identité, SIRET, activité, IBAN, logo) qui pré-remplit mentions légales | Nouveau fichier |
| 7.4 | **Validation Luhn SIRET** | `lib/utils/` |

#### Sprint 8 — Envoi email & UI relances (Priorité IMPORTANTE)

| # | Tâche | Fichiers |
|---|---|---|
| 8.1 | **`EmailService`** via `url_launcher` (V1 mailto:) : envoi devis, facture, avoir avec PDF joint | `lib/services/email_service.dart` |
| 8.2 | **Boutons « Envoyer par email »** dans listes devis/factures + MAJ statut automatique | Vues listes |
| 8.3 | **Écran relances** exploitant `RelanceService` existant : liste impayés, niveaux de relance, bouton relancer | `lib/views/relances_view.dart` |
| 8.4 | **Widget dashboard « Factures en retard »** avec badge notification | `lib/widgets/dashboard/` |
| 8.5 | **Logger envois et relances** dans `audit_logs` | Services |

#### Sprint 9 — Refonte design global & personnalisation PDF (Priorité MOYENNE)

| # | Tâche | Fichiers |
|---|---|---|
| 9.1 | **Design système** : palette couleurs douces, typographies modernes, composants épurés, constantes thème centralisées | `lib/config/theme.dart` |
| 9.2 | **Refonte dashboard** : widgets clés (CA, impayés, seuil TVA, planning), layout responsive, cartes modernes | `lib/views/dashboard_view.dart` |
| 9.3 | **Personnalisation PDF** : couleurs customisables, logo header + logo footer (ex: SAP), décorations, choix police | `lib/services/pdf_themes/`, `entreprise_model.dart` |
| 9.4 | **Archivage automatique** : factures payées > 1 an → proposition d'archivage | `lib/viewmodels/` |

---

### Décisions architecturales (mises à jour)

- ✅ **Architecture MVVM + Supabase** conservée, refonte ciblée par sprint
- ✅ **Numérotation trigger SQL seul** : mécanisme Dart supprimé des ViewModels et de `DevisRepository.finalizeDevis()`
- ✅ **Avoirs en montants positifs** : `createAvoir` stocke en valeurs absolues
- ✅ **`typeDocument` et `type` conservés** : axes orthogonaux (nature juridique ≠ mode facturation)
- ✅ **`statut` et `statutJuridique` conservés** : trigger SQL synchronise
- ❌ **Chiffrage hors stepper** : vue `rentabilite_view.dart` dédiée, outil interne artisan non visible client
- ❌ **Email via `mailto:`** en V1, Supabase Edge Function + SMTP en V2
- ❌ **Seuils TVA versionnés** : table dédiée par année
- ❌ **Custom drawer** : refonte complète pour UX moderne

### Remarques utilisateur (conservées)

- Refonte complète du custom_drawer : design moderne, navigation fluide, sections logiques, profil entreprise accessible
- Refonte design global de l'application : couleurs douces, typo modernes, interface épurée, dashboard amélioré
- Personnalisation PDF complète : couleurs, logo header/footer, décorations
- Objectif : concurrencer Abby et les applications professionnelles du marché
