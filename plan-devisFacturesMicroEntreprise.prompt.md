## Plan : Mise en conformité et refonte workflow Devis/Factures Micro-entreprise

### TL;DR

L'application Artisan 3.0 possède une base solide (modèles, repositories, PDF, calculs Decimal). Suite aux **Sprints 1-13**, toutes les non-conformités sont corrigées : mentions obligatoires PDF, immutabilité des factures validées, piste d'audit, numérotation par trigger SQL, soft-delete avec corbeille, exploitation acompte_percentage, statistiques devis sur dashboard. La gestion TVA (TvaService, alertes steppers, widget dashboard) est opérationnelle. L'UX est modernisée : drawer sectionné, profil entreprise complet, onboarding, validation Luhn SIRET, archivage automatique.

Suite à l'**analyse concurrentielle Abby**, les **Sprints 14-20** ajoutent les fonctionnalités manquantes pour rivaliser avec la concurrence : factures récurrentes (heb/mens/trim/annuel), suivi du temps d'activité avec CA potentiel, rappels & échéances fiscales automatiques (URSSAF, CFE, Impôts, TVA), et multi-devises sur factures/devis.

**Légende :** ✅ = Fait | ⚠️ = Partiel | ❌ = À faire

---

### Cadre légal (inchangé — référence)

- **CGI art. 289** : mentions obligatoires factures
- **Loi anti-fraude TVA 2018** (art. 286 I-3° bis CGI) : immutabilité, piste d'audit, numérotation chronologique
- **Code de Commerce L441-10** : pénalités de retard, indemnité 40€
- **Art. 293 B CGI** : franchise en base de TVA micro-entreprise

---

### État du diagnostic (mise à jour 18/02/2026 — post Sprint 20)

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

#### IMPORTANT — Tout corrigé ✅

| # | Problème | Statut |
|---|---|---|
| I1 | `typeDocument` vs `type` — **conservés** (axes orthogonaux : nature juridique vs mode facturation) | ✅ Classé |
| I2 | `statut` vs `statutJuridique` — **conservés** (opérationnel vs juridique, trigger SQL synchronise) | ✅ Classé |
| I3 | `Paiement.isAcompte` stocké mais jamais exploité en logique métier | ✅ Exploité dans PDF (colonne Type: Acompte/Solde) |
| I4 | `acompte_percentage` sur Devis jamais lu côté métier | ✅ TransformationDialog utilise `devis.acomptePercentage` comme valeur par défaut |
| I8 | Vues legacy non supprimées (2 203 lignes : ajout_devis 1244L + ajout_facture 959L) | ✅ Supprimées |
| I9 | Chiffrage/rentabilité : vue séparée à auditer et mettre à jour (PAS dans le stepper, volonté utilisateur) | ✅ Auditée, cohérente |
| M1 | Pas de `updated_at` sur tables | ✅ Déployé (5 tables + triggers auto) |
| M2 | Pas de soft-delete | ✅ `deleted_at` sur 4 tables, corbeille UI, restore/purge, auto-purge 30j |
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
- ✅ Soft-delete (`deleted_at`) déployé sur factures, devis, clients, depenses + vue Corbeille + auto-purge 30j
- ✅ **Sprint 14-20** : 3 nouvelles tables (`factures_recurrentes`, `lignes_facture_recurrente`, `temps_activites`, `rappels`), ALTER TABLE `factures`/`devis` (+`devise`, `taux_change`, `notes_privees`), RLS, triggers audit/updated_at, indexes

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
- Sprint 11 : 11 tests ajoutés (CorbeilleViewModel fetch, restore/purge par type, purgeAll)
- **538/538** tests passent (0 échec)
- Sprint 12 : 9 tests ajoutés (getConversionRate 4, creerAvenant 2, refuserDevis 2 + bugfix infinite precision)
- **547/547** tests passent (0 échec)
- Sprint 13 : 4 tests ajoutés (DashboardViewModel devis stats : zéro, conversion 50%, pipeline, exclusion annulés)
- **550/550** tests passent (0 échec) — ✅ zéro régression
- Sprint 14-20 : 86 tests ajoutés (FactureRecurrenteVM 10, TempsVM 10, RappelVM 14, EcheanceService 11, nouveaux modèles 24, multi-devises 17)
- **636/636** tests passent (0 échec) — ✅ zéro régression

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

#### Sprint 11 — Soft-delete & Corbeille (Priorité IMPORTANTE) ✅ TERMINÉ

| # | Tâche | Fichiers | Statut |
|---|---|---|---|
| 11.1 | **Migration SQL** : `deleted_at TIMESTAMPTZ` sur factures/devis/clients/depenses, indexes partiels, fonction `purge_old_deleted_items()` (30 jours) | `migrations/migration_sprint11_soft_delete.sql` | ✅ |
| 11.2 | **Repositories soft-delete** : `deleteX()` → soft-delete (`deleted_at = NOW()`), `.isFilter('deleted_at', null)` sur toutes les requêtes, nouveau `getDeletedX()`, `restoreX()`, `purgeX()` | `lib/repositories/facture_repository.dart`, `devis_repository.dart`, `client_repository.dart`, `depense_repository.dart`, `dashboard_repository.dart` | ✅ |
| 11.3 | **CorbeilleViewModel** : charge items supprimés depuis 4 repos, restore/purge par type, purgeAll | `lib/viewmodels/corbeille_viewmodel.dart` | ✅ |
| 11.4 | **CorbeilleView** : TabBar 4 onglets (Factures/Devis/Clients/Dépenses), cartes avec restore/purge, info banner 30j, dialogues confirmation | `lib/views/corbeille_view.dart` | ✅ |
| 11.5 | **Intégration** : route `/app/corbeille`, entrée Drawer, Provider DI | `lib/config/router.dart`, `lib/widgets/custom_drawer.dart`, `lib/config/dependency_injection.dart` | ✅ |
| 11.6 | **Tests** : 11 tests (fetchAll, empty detection, restore/purge par type ×4, purgeAll) — 538/538 total | `test/viewmodels/corbeille_viewmodel_test.dart` | ✅ |

#### Sprint 12 — Exploitation acompte_percentage & avenants (Priorité IMPORTANTE) ✅ TERMINÉ

| # | Tâche | Fichiers | Statut |
|---|---|---|---|
| 12.1 | **TransformationDialog** : paramètre `acomptePercentage` (nullable Decimal), utilise la valeur du devis comme défaut au lieu de 30% hardcodé | `lib/widgets/dialogs/transformation_dialog.dart` | ✅ |
| 12.2 | **ListeDevisView** : passe `d.acomptePercentage` au dialog, badge visuel « Avenant » (violet) sur les devis enfants | `lib/views/liste_devis_view.dart` | ✅ |
| 12.3 | **Bugfix getConversionRate** : `toDecimal(scaleOnInfinitePrecision: 10)` pour éviter crash sur divisions non finies (2/3) | `lib/viewmodels/devis_viewmodel.dart` | ✅ |
| 12.4 | **Tests** : 9 tests (getConversionRate 4, creerAvenant 2, refuserDevis 2 + edge cases) — 547/547 total | `test/viewmodels/devis_viewmodel_test.dart` | ✅ |

#### Sprint 13 — Statistiques Devis Dashboard (Priorité MOYENNE) ✅ TERMINÉ

| # | Tâche | Fichiers | Statut |
|---|---|---|---|
| 13.1 | **DashboardRepository** : nouvelle méthode `getAllDevisYear(year)` — récupère tous les devis de l'année | `lib/repositories/dashboard_repository.dart` | ✅ |
| 13.2 | **DashboardViewModel** : champs `tauxConversion`, `devisEnCours`, `montantPipeline`, `totalDevisYear` + méthode `_computeDevisStats()` | `lib/viewmodels/dashboard_viewmodel.dart` | ✅ |
| 13.3 | **Dashboard UI** : section « Pipeline Devis » avec 3 cartes (Taux de conversion, Devis en cours, Montant pipeline) — couleur conditionnelle selon seuils | `lib/views/tableau_de_bord_view.dart` | ✅ |
| 13.4 | **Tests** : 4 tests (zéro devis, conversion 50%, pipeline brouillon+envoyé, exclusion annulés) — 550/550 total | `test/viewmodels/dashboard_viewmodel_test.dart` | ✅ |
#### Sprint 14-20 — Fonctionnalités concurrentielles (Analyse Abby) ✅ TERMINÉ

| # | Tâche | Fichiers | Statut |
|---|---|---|---|
| 14.1 | **Factures récurrentes** : modèle `FactureRecurrente` + `LigneFactureRecurrente`, enum `FrequenceRecurrence` (hebdomadaire/mensuelle/trimestrielle/annuelle), cycle de génération automatique | `lib/models/facture_recurrente_model.dart` | ✅ |
| 14.2 | **Repository factures récurrentes** : interface `IFactureRecurrenteRepository` + impl avec gestion des lignes imbriquées (insert/delete), `getActives()`, `getAGenerer()`, `toggleActive()`, `incrementerGeneration()` | `lib/repositories/facture_recurrente_repository.dart` | ✅ |
| 14.3 | **ViewModel factures récurrentes** : CRUD complet, getters `actives`/`inactives`/`aGenerer`/`totalGeneres`, méthode statique `calculerProchaineDate()` | `lib/viewmodels/facture_recurrente_viewmodel.dart` | ✅ |
| 14.4 | **Vue factures récurrentes** : liste avec toggle actif/inactif, badge fréquence, état vide, suppression avec confirmation | `lib/views/factures_recurrentes_view.dart` | ✅ |
| 15.1 | **Suivi du temps** : modèle `TempsActivite` avec `montant` (Decimal, division safe), `dureeFormatee` (format Xh00) | `lib/models/temps_activite_model.dart` | ✅ |
| 15.2 | **Repository temps** : interface `ITempsRepository` + impl, `getNonFactures()`, `getByClient()`, `getByProjet()`, `marquerFacture()` | `lib/repositories/temps_repository.dart` | ✅ |
| 15.3 | **ViewModel temps** : `nonFactures`/`totalMinutesMois`/`totalHeuresMoisFormate`/`caPotentiel`/`parClient`/`parProjet`, CRUD, `marquerFacture()` | `lib/viewmodels/temps_viewmodel.dart` | ✅ |
| 15.4 | **Vue suivi temps** : barre KPI (total heures, CA potentiel, non-facturé), dialogue ajout avec dropdown client, liste par date | `lib/views/suivi_temps_view.dart` | ✅ |
| 16.1 | **Rappels & échéances** : modèle `Rappel` avec `TypeRappel` (7 types : urssaf, cfe, impots, tva, echeanceFacture, finDevis, custom), `PrioriteRappel`, getters `joursRestants`/`estEnRetard`/`estProche` | `lib/models/rappel_model.dart` | ✅ |
| 16.2 | **Repository rappels** : interface `IRappelRepository` + impl, `getActifs()`, `getByType()`, `completer()`/`decompleter()` | `lib/repositories/rappel_repository.dart` | ✅ |
| 16.3 | **ViewModel rappels** : `actifs`/`enRetard`/`proches`/`completes`/`nbUrgents`/`parType`, générateurs statiques URSSAF/CFE/Impôts | `lib/viewmodels/rappel_viewmodel.dart` | ✅ |
| 16.4 | **Vue rappels** : onglets (À venir / Tous / Complétés), génération auto rappels fiscaux, code couleur urgence, dialogue ajout | `lib/views/rappels_echeances_view.dart` | ✅ |
| 17.1 | **EcheanceService** : génération automatique des rappels fiscaux (URSSAF mensuel/trimestriel, CFE 15 déc, Impôts 8 juin, TVA trimestrielle), rappels factures échues, rappels devis expirants | `lib/services/echeance_service.dart` | ✅ |
| 18.1 | **Multi-devises** : champs `devise` (défaut EUR), `tauxChange` (Decimal?), `notesPrivees` (String?) ajoutés sur `Facture` et `Devis` | `lib/models/facture_model.dart`, `lib/models/devis_model.dart` | ✅ |
| 19.1 | **Intégration DI** : 3 nouveaux providers (FactureRecurrenteVM, TempsVM, RappelVM) — 18 providers total | `lib/config/dependency_injection.dart` | ✅ |
| 19.2 | **Intégration Router** : 3 nouvelles routes `/app/recurrentes`, `/app/temps`, `/app/rappels` | `lib/config/router.dart` | ✅ |
| 19.3 | **Intégration Drawer** : 3 entrées menu (Récurrentes dans DOCUMENTS, Suivi du temps + Rappels dans OUTILS) | `lib/widgets/custom_drawer.dart` | ✅ |
| 19.4 | **Migration SQL** : 3 tables + ALTER TABLE + RLS + triggers + indexes | `migrations/migration_sprint14_20_features.sql` | ✅ |
| 20.1 | **Tests** : 86 tests ajoutés (6 fichiers) — 636/636 total | `test/viewmodels/facture_recurrente_viewmodel_test.dart`, `test/viewmodels/temps_viewmodel_test.dart`, `test/viewmodels/rappel_viewmodel_test.dart`, `test/services/echeance_service_test.dart`, `test/models/nouveaux_models_test.dart`, `test/models/multi_devises_test.dart` | ✅ |
---

### Décisions architecturales (mises à jour)

- ✅ **Architecture MVVM + Supabase** conservée, refonte ciblée par sprint
- ✅ **Numérotation trigger SQL seul** : mécanisme Dart supprimé des ViewModels et de `DevisRepository.finalizeDevis()`
- ✅ **Avoirs en montants positifs** : `createAvoir` stocke en valeurs absolues
- ✅ **`typeDocument` et `type` conservés** : axes orthogonaux (nature juridique ≠ mode facturation)
- ✅ **`statut` et `statutJuridique` conservés** : trigger SQL synchronise
- ✅ **Chiffrage hors stepper** : vue `rentabilite_view.dart` dédiée, outil interne artisan non visible client (décision architecturale)
- ✅ **Email via `mailto:`** en V1 (fonctionnel), Supabase Edge Function + SMTP = V2 future (hors scope MVP)
- ✅ **Seuils TVA versionnés** : exploités via UrssafConfig existant (DB), pas besoin de table dédiée supplémentaire
- ✅ **Soft-delete** : `deleted_at` sur 4 tables, Corbeille UI, restore/purge, auto-purge 30j
- ✅ **Custom drawer** : refonte complète, sections logiques, header profil cliquable
- ✅ **Onboarding première connexion** : assistant 4 étapes, détection auto profil vide
- ✅ **Validation Luhn SIRET** : algorithme standard + cas La Poste
- ✅ **Nettoyage Flutter 3.32+** : migration RadioGroup, activeTrackColor, initialValue, async safety — zéro dette technique lint
- ✅ **Factures récurrentes** : modèle + repo + VM + vue, 4 fréquences, toggle actif/inactif, génération programmée
- ✅ **Suivi du temps** : modèle + repo + VM + vue, CA potentiel, groupement client/projet, marquage facturé
- ✅ **Rappels & échéances fiscales** : modèle + repo + VM + vue + EcheanceService, 7 types, génération auto URSSAF/CFE/Impôts/TVA
- ✅ **Multi-devises** : champs devise/tauxChange/notesPrivees sur Facture et Devis, rétrocompatible EUR
- ✅ **Email V1 via mailto:** en attendant SMTP V2 (hors scope actuel)

### Remarques utilisateur (conservées)

- Refonte complète du custom_drawer : design moderne, navigation fluide, sections logiques, profil entreprise accessible
- Refonte design global de l'application : couleurs douces, typo modernes, interface épurée, dashboard amélioré
- Personnalisation PDF complète : couleurs, logo header/footer, décorations
- Objectif : concurrencer Abby et les applications professionnelles du marché
- **Analyse concurrentielle Abby** réalisée : 10 gaps identifiés (P1-P10), Sprints 14-20 couvrent P2 (récurrence), P6 (time tracking), P5 (relances avancées), P7 (multi-devises)
- Reste à explorer (V2+) : P1 (SMTP email), P3 (Stripe/paiements en ligne), P4 (Open Banking), P8 (e-signature), P9 (gestion stocks), P10 (débours)
