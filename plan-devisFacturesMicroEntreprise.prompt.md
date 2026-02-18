## Plan : Mise en conformité et refonte workflow Devis/Factures Micro-entreprise

### TL;DR

L'application Artisan 3.0 possède une base solide (modèles, repositories, PDF, calculs Decimal). Suite aux **Sprints 1-7**, les non-conformités légales critiques sont corrigées : mentions obligatoires PDF, immutabilité des factures validées, piste d'audit, numérotation par trigger SQL, protection contre la suppression physique, référence facture source dans les avoirs PDF. Le nettoyage legacy est effectué, `updated_at` est déployé sur toutes les tables. La gestion TVA (TvaService, alertes steppers, widget dashboard) est opérationnelle. L'UX est modernisée : drawer sectionné, profil entreprise complet (TVA, PDF, mentions légales), onboarding première connexion, validation Luhn SIRET.

**Légende :** ✅ = Fait | ⚠️ = Partiel | ❌ = À faire

---

### Cadre légal (inchangé — référence)

- **CGI art. 289** : mentions obligatoires factures
- **Loi anti-fraude TVA 2018** (art. 286 I-3° bis CGI) : immutabilité, piste d'audit, numérotation chronologique
- **Code de Commerce L441-10** : pénalités de retard, indemnité 40€
- **Art. 293 B CGI** : franchise en base de TVA micro-entreprise

---

### État du diagnostic (mise à jour 18/02/2026 — post Sprint 10)

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
| M3 | Pas de validation Luhn SIRET | ✅ Algorithme Luhn + cas La Poste |
| M7 | Seuils TVA hardcodés | ✅ Seuils versionnés dans UrssafConfig (DB), TvaService + alertes UI |
| M8 | Pas d'UI relances | ✅ Écran relances complet (RelanceViewModel + RelancesView) |
| M9 | Pas d'envoi email | ✅ EmailService via url_launcher (mailto:) + boutons dans listes |

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

#### Tests (mise à jour 18/02/2026 — post Sprint 10)

- **401/401** tests passent (0 échec)
- Bug `annulerDevis` test corrigé (mockait `updateDevis` au lieu de `changeStatut`)
- Sprint 4 : 11 tests ajoutés (finalizeDevis sans generateNextNumero, PdfGenerationRequest.factureSourceNumero, Facture numeroBonCommande/motifAvoir, résolution source pour avoirs)
- Sprint 5 : 8 tests ajoutés (Paiement.isAcompte ventilation, Facture paiements mixtes, intégrité modèles)
- Sprint 6 : 18 tests ajoutés (TvaService analyse activité, BilanTva, calculerCaYtd, simulerAvecMontant, edge cases)
- Sprint 7 : 22 tests ajoutés (Luhn SIRET 8 tests, ProfilEntreprise champs complets 4, mentions légales 5, enums couverture 5) + 3 tests SIRET existants mis à jour
- **452/452** tests passent (0 échec)
- Sprint 8 : 19 tests ajoutés (EmailService 9, RelanceViewModel 5, FacturesRetardCard 4, AuditService 1)
- **471/471** tests passent (0 échec)
- Sprint 9 : 56 tests ajoutés (ArchivageService 9, design system 18, PdfTheme custom 10, ProfilEntreprise model 8, DashboardViewModel 8 existants mis à jour)
- **527/527** tests passent (0 échec)
- Sprint 10 : 0 nouveau test (corrections lint/deprecations uniquement, aucune logique métier modifiée)
- **527/527** tests passent (0 échec) — ✅ zéro régression

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

#### Sprint 6 — Gestion TVA & dépassement de seuil ✅ TERMINÉ

| # | Tâche | Statut |
|---|---|---|
| 6.1 | **`TvaService`** : `StatutTva` enum (enFranchise/approcheSeuil/seuilBaseDepasse/seuilMajoreDepasse), `AnalyseTva`, `BilanTva`, `calculerCaYtd` (ventilation vente/service par lignes), `simulerAvecMontant` | ✅ |
| 6.2 | **Seuils versionnés** : déjà dans `UrssafConfig` (DB `urssaf_configs`), seuils 2026 par défaut, modifiables par l'utilisateur | ✅ |
| 6.3 | **Alertes UI** : `TvaAlertBanner` widget réutilisable, intégré dans `step4_validation` facture ET devis, affiche le bilan TVA avec code couleur | ✅ |
| 6.4 | **Widget dashboard** : `SuiviSeuilTvaCard` avec jauges vente/service (base + majoré), chip statut, messages d'alerte. Intégré dans `TableauDeBordView` | ✅ |
| 6.5 | **Tests** : 18 tests (analyserActivite, BilanTva, calculerCaYtd ventilation/filtre/avoirs, simulerAvecMontant, edge cases) | ✅ |

#### Sprint 7 — Refonte Custom Drawer & Profil Entreprise ✅ TERMINÉ

| # | Tâche | Statut |
|---|---|---|
| 7.1 | **Refonte `custom_drawer.dart`** : sections ACTIVITÉ / DOCUMENTS / GESTION / OUTILS / PARAMÈTRES, header cliquable vers profil, icônes Material Rounded, sélection avec fond primary 8%, footer logout | ✅ |
| 7.2 | **Refonte profil entreprise** : 7 sections en cartes (Identité, Adresse, Facturation & Bancaire, TVA, Mentions légales, Personnalisation PDF, Signature). Tous les champs du modèle exposés (tvaApplicable, numeroTvaIntra, pdfTheme, modeFacturation, modeDiscret, tauxPenalitesRetard, escompteApplicable, estImmatricule). Bouton « Régénérer automatiquement » les mentions. Validations ValidationUtils intégrées | ✅ |
| 7.3 | **Onboarding guidé** : 4 étapes (Identité → Coordonnées → Facturation/TVA → Logo/Récap), stepper visuel avec barre de progression, récapitulatif complet, auto-génération mentions légales, redirection automatique depuis dashboard si profil vide | ✅ |
| 7.4 | **Validation Luhn SIRET** : algorithme Luhn standard sur 14 chiffres + cas spécial La Poste (SIREN 356000000, somme des chiffres % 5). Intégré dans `validateSiret()` et utilisé par le profil + onboarding | ✅ |
| 7.5 | **Tests** : 22 tests (Luhn 8, modèle complet 4, mentions légales 5, enums 5) + tests SIRET existants mis à jour pour Luhn | ✅ |

#### Sprint 8 — Envoi email & UI relances (Priorité IMPORTANTE) ✅ TERMINÉ

| # | Tâche | Statut |
|---|---|---|
| 8.1 | **`EmailService`** via `url_launcher` (V1 mailto:) : envoi devis, facture, relance avec sujet/corps pré-remplis | ✅ |
| 8.2 | **Boutons « Envoyer par email »** dans listes devis/factures + MAJ statut automatique (brouillon→envoyé, validée→envoyée) | ✅ |
| 8.3 | **Écran relances** : `RelanceViewModel` + `RelancesView` avec stats, filtres par niveau, cartes relance, boutons email/aperçu | ✅ |
| 8.4 | **Widget dashboard « Factures en retard »** : `FacturesRetardCard` avec badge, montant total, retard max, barre niveaux | ✅ |
| 8.5 | **Logger envois et relances** dans `audit_logs` : `AuditService` (EMAIL_SENT, RELANCE_SENT) + migration SQL contrainte | ✅ |
| 8.6 | **Route `/app/relances`** + entrée Drawer « Relances » + Provider `RelanceViewModel` | ✅ |
| 8.7 | **Tests** : 19 tests (EmailService 9, RelanceViewModel 5, FacturesRetardCard 4, AuditService 1) | ✅ |

#### Sprint 9 — Refonte design global & personnalisation PDF (Priorité MOYENNE)

| # | Tâche | Fichiers | Statut |
|---|---|---|---|
| 9.1 | **Design système** : palette couleurs douces (primarySoft, accentSoft, etc.), spacing grille 4px, border radius constants, shadows, helpers statusColor/statusBackgroundColor, widgets AppBadge + SectionHeader | `lib/config/theme.dart` | ✅ |
| 9.2 | **Refonte dashboard** : remplacement hardcoded par AppTheme constants, intégration SectionHeader, suppression _buildSectionTitle | `lib/views/tableau_de_bord_view.dart` | ✅ |
| 9.3 | **Personnalisation PDF** : couleur primaire custom par utilisateur (10 presets + défaut thème), logo footer, migration SQL, color picker UI dans profil | `lib/services/pdf_themes/pdf_theme_base.dart`, `moderne/classique/minimaliste_theme.dart`, `lib/models/entreprise_model.dart`, `lib/views/profil_entreprise_view.dart`, `lib/services/pdf_service.dart`, `migrations/migration_sprint9_pdf_custom.sql` | ✅ |
| 9.4 | **Archivage automatique** : `ArchivageService` détecte factures soldées > 12 mois, `ArchivageSuggestionCard` sur dashboard, archivage lot + dismiss, dialogue confirmation | `lib/services/archivage_service.dart`, `lib/widgets/dashboard/archivage_suggestion_card.dart`, `lib/viewmodels/dashboard_viewmodel.dart`, `lib/views/tableau_de_bord_view.dart` | ✅ |
| 9.5 | **Tests Sprint 9** : 56 tests (ArchivageService 9, design system 18, PdfTheme custom 10, ProfilEntreprise model 8, DashboardViewModel archivage fix 8 existants) — 527/527 total | `test/services/archivage_service_test.dart`, `test/services/design_system_test.dart`, `test/services/pdf_theme_custom_test.dart`, `test/models/entreprise_model_test.dart` | ✅ |

#### Sprint 10 — Nettoyage erreurs, warnings & dépréciations Flutter 3.32+ ✅ TERMINÉ

| # | Tâche | Fichiers | Statut |
|---|---|---|---|
| 10.1 | **Fix ERROR** : `BigInt.zero` → `Decimal.zero` (comparaison marge TVA) + ajout import `decimal` | `lib/widgets/dashboard/suivi_seuil_tva_card.dart` | ✅ |
| 10.2 | **Fix WARNING** : suppression variable `original` inutilisée | `test/services/pdf_theme_custom_test.dart` | ✅ |
| 10.3 | **Naming conventions Dart** : renommage variables locales `_legalStyle` → `legalStyle` (6 occurrences), `_baseProfil` → `baseProfil` (9 occurrences) — suppression underscore non-conforme | `lib/services/pdf_service.dart`, `test/models/entreprise_model_test.dart` | ✅ |
| 10.4 | **Dépréciation `Switch.activeColor`** → `activeTrackColor` : 5 occurrences SwitchListTile.adaptive corrigées | `lib/views/profil_entreprise_view.dart` (×4), `lib/views/onboarding_view.dart` (×1) | ✅ |
| 10.5 | **Dépréciation `DropdownButtonFormField.value`** → `initialValue` : 3 occurrences corrigées | `lib/views/profil_entreprise_view.dart` (×2), `lib/views/onboarding_view.dart` (×1) | ✅ |
| 10.6 | **Dépréciation `RadioListTile.groupValue/onChanged`** → wrapping `RadioGroup<T>` : 2 sections migrées (StatutEntrepreneur, PdfTheme) | `lib/views/settings_root_view.dart` | ✅ |
| 10.7 | **Sécurité async `use_build_context_synchronously`** : ajout `if (!mounted) return;` et `if (!context.mounted) return;` après awaits — 4 corrections | `lib/views/liste_devis_view.dart` (×2), `lib/views/liste_factures_view.dart` (×1), `lib/views/relances_view.dart` (×1) | ✅ |
| 10.8 | **Validation** : 0 erreur, 0 warning, 527/527 tests passent | — | ✅ |

---

### Décisions architecturales (mises à jour)

- ✅ **Architecture MVVM + Supabase** conservée, refonte ciblée par sprint
- ✅ **Numérotation trigger SQL seul** : mécanisme Dart supprimé des ViewModels et de `DevisRepository.finalizeDevis()`
- ✅ **Avoirs en montants positifs** : `createAvoir` stocke en valeurs absolues
- ✅ **`typeDocument` et `type` conservés** : axes orthogonaux (nature juridique ≠ mode facturation)
- ✅ **`statut` et `statutJuridique` conservés** : trigger SQL synchronise
- ❌ **Chiffrage hors stepper** : vue `rentabilite_view.dart` dédiée, outil interne artisan non visible client
- ❌ **Email via `mailto:`** en V1, Supabase Edge Function + SMTP en V2
- ❌ **Seuils TVA versionnés** : exploités via UrssafConfig existant (DB), pas besoin de table dédiée supplémentaire
- ✅ **Custom drawer** : refonte complète, sections logiques, header profil cliquable
- ✅ **Onboarding première connexion** : assistant 4 étapes, détection auto profil vide
- ✅ **Validation Luhn SIRET** : algorithme standard + cas La Poste
- ✅ **Nettoyage Flutter 3.32+** : migration RadioGroup, activeTrackColor, initialValue, async safety — zéro dette technique lint

### Remarques utilisateur (conservées)

- Refonte complète du custom_drawer : design moderne, navigation fluide, sections logiques, profil entreprise accessible
- Refonte design global de l'application : couleurs douces, typo modernes, interface épurée, dashboard amélioré
- Personnalisation PDF complète : couleurs, logo header/footer, décorations
- Objectif : concurrencer Abby et les applications professionnelles du marché
