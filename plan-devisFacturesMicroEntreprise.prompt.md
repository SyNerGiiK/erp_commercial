## Plan : Mise en conformité et refonte workflow Devis/Factures Micro-entreprise

### TL;DR

L'application Artisan 3.0 possède une base solide (modèles, repositories, PDF, calculs Decimal) mais souffre de **lacunes légales critiques**, de **redondances structurelles** (vues legacy, double numérotation, `type` vs `typeDocument`), et de **fonctionnalités manquantes** (envoi email, relances UI, piste d'audit, immutabilité des factures validées). Le plan ci-dessous corrige les non-conformités au regard du **CGI art. 289** (mentions obligatoires factures), de la **loi anti-fraude TVA 2018** (immutabilité, piste d'audit, numérotation chronologique), du **Code de Commerce L441-10** (pénalités de retard), et simplifie l'architecture pour ne cibler que la micro-entreprise avec franchise en base de TVA + gestion du dépassement de seuil.

**Verdict : pas de réécriture complète nécessaire**, mais une refonte ciblée en 8 sprints sur les couches modèle, PDF, sécurité DB et UX.

---

### Cadre légal — Workflow complet Devis & Factures Micro-entreprise (sources officielles)

#### A. Le Devis (Art. L111-1 à L111-3 Code de la consommation + Arrêté du 2 mars 1990)

**Mentions obligatoires sur un devis :**
1. Mention « Devis » (ou « Proposition commerciale »)
2. Date du devis
3. Nom et adresse de l'entreprise + SIRET (ou SIREN)
4. Nom et adresse du client
5. Date de début et durée estimée des travaux (si prestation)
6. Décompte détaillé de chaque prestation/fourniture : désignation, quantité, prix unitaire HT, montant (pour ceci dans les parametre entreprise, je permet à l'entreprise de choisir si elle veux éditer des devis vente+service ou vente et service, certain artisan préfère faire des devis séparé pour les prestations et les fournitures, d'autre préfère faire un devis global, je laisse le choix à l'entreprise de choisir le type de devis qu'elle veux éditer)
7. Frais de déplacement éventuels
8. Montant total HT et TTC (ou mention « TVA non applicable, art. 293 B du CGI » si franchise)
9. Durée de validité du devis
10. Mention « Devis reçu avant l'exécution des travaux » + signature client obligatoire pour les prestations > 150€ (arrêté 2 mars 1990 pour travaux/dépannage)
11. Conditions de paiement (acompte éventuel, échéancier)

**Statuts possibles :** Brouillon → Envoyé → Signé (accepté) / Refusé / Expiré → Transformé en Facture

#### B. La Facture (CGI art. 289, art. 242 nonies A annexe II ; Loi anti-fraude 2018)

**Mentions obligatoires sur une facture (toutes entreprises) :**
1. Mention « Facture »
2. **Numéro unique, séquentiel, sans rupture** (ex: F-2026-0001)
3. Date d'émission
4. Date de la vente/prestation (si différente)
5. Identité du vendeur : nom, adresse, SIRET, forme juridique
6. Identité de l'acheteur : nom, adresse (+ SIRET si B2B)
7. Numéro de bon de commande (si fourni par le client)
8. Désignation précise des biens/services
9. Quantité, prix unitaire HT, montant total HT
10. Taux de TVA applicable + montant TVA (ou mention d'exonération)
11. **Date d'échéance du paiement**
12. **Conditions de paiement**
13. **Taux des pénalités de retard** (min. 3× le taux d'intérêt légal, soit ~11,62% en 2025)
14. **Indemnité forfaitaire de recouvrement : 40€** (art. L441-10 C. com.)
15. **Mention escompte** : « Pas d'escompte pour paiement anticipé » ou taux si applicable

**Mentions spécifiques micro-entreprise :**
16. « TVA non applicable, article 293 B du Code général des impôts »
17. **Ne PAS afficher** de ligne TVA ni de colonne TVA si franchise en base

**Exigences loi anti-fraude TVA (art. 286 I-3° bis CGI) :**
18. **Immutabilité** : une facture validée ne peut JAMAIS être modifiée → seul un avoir peut la corriger
19. **Piste d'audit** : traçabilité de toutes les opérations (création, validation, envoi, paiement, avoir)
20. **Numérotation chronologique continue** : pas de trous autorisés
21. **Archivage** : conservation 10 ans minimum

#### C. L'Avoir (CGI art. 289)

1. Mention « Avoir » + numéro unique séquentiel (série dédiée AV-)
2. **Référence explicite à la facture d'origine** (numéro + date)
3. Motif de l'avoir
4. Montants négatifs ou mention de crédit
5. Mêmes mentions obligatoires qu'une facture

#### D. La Facture d'Acompte (CGI art. 289 I-1-c)

1. Mention « Facture d'acompte » + numéro séquentiel
2. Référence au devis d'origine
3. Montant de l'acompte
4. La facture de solde déduit les acomptes déjà versés

#### E. Seuils TVA 2025-2026 (Art. 293 B CGI, LFI 2025)

| Activité | Seuil franchise base | Seuil majoré (perte franchise N+1) |
|---|---|---|
| Vente marchandises | 85 000€ (2025) / 91 900€ (modèle actuel) | 93 500€ (2025) / 101 000€ |
| Prestations de services | 37 500€ (2025) / 36 800€ (modèle actuel) | 41 250€ (2025) / 39 100€ |

> **Attention** : la LFI 2025 a abaissé le seuil unique de franchise en base à **25 000€** pour toutes activités à compter du 1er mars 2025 (art. 293 B CGI modifié), puis cette mesure a été **reportée** au 1er juin 2025. Les seuils dans votre modèle `UrssafConfig` sont ceux de pré-réforme. Il faudra les rendre **configurables et versionnés par année**.

#### F. Plafonds CA micro-entreprise (Art. 50-0 et 102 ter CGI)

| Activité | Plafond CA annuel |
|---|---|
| Vente de marchandises (BIC) | 188 700€ |
| Prestations de services (BIC/BNC) | 77 700€ |

---

### Diagnostic du codebase — Problèmes classés par criticité

#### CRITIQUE (Non-conformité légale)

| # | Problème | Localisation |
|---|---|---|
| C1 | **Mentions obligatoires manquantes sur PDF facture** : pénalités de retard, indemnité 40€, escompte, date d'échéance, conditions de paiement | `lib/services/pdf_service.dart` |
| C2 | **Factures validées modifiables** : `updateFacture()` ne bloque pas la modification du contenu après validation. Viole l'immutabilité anti-fraude | `lib/viewmodels/facture_viewmodel.dart`, `lib/repositories/facture_repository.dart` |
| C3 | **Pas de piste d'audit** : aucune table de log des événements (création, validation, modification, suppression). Requis par l'art. 286 CGI | Absent |
| C4 | **Double mécanisme de numérotation** : trigger SQL (`D-`, `F-`, `AV-`) + code Dart (`DEV-`, `FAC-`) → préfixes incohérents, risque de doublons | `lib/core/document_repository.dart`, `migrations/migration_numerotation_stricte.sql` |
| C5 | **CHECK `total_ttc >= 0` bloque les avoirs** : `createAvoir()` génère des montants négatifs qui violent la contrainte | `migrations/hardening_integrity.sql`, `lib/viewmodels/facture_viewmodel.dart` |
| C6 | **Avoir sans référence à la facture d'origine sur le PDF** : le `factureSourceId` n'est pas résolu en numéro lisible | `lib/services/pdf_service.dart` |
| C7 | **Suppression physique des factures/devis** : seul le code Dart protège. Aucun trigger `BEFORE DELETE` côté DB | Absent |

#### IMPORTANT (Bugs / incohérences)

| # | Problème | Localisation |
|---|---|---|
| I1 | **`type_document` vs `type` redondance** sur `Facture` : la valeur `'avoir'` peut être dans les deux champs | `lib/models/facture_model.dart` |
| I2 | **`statut` vs `statutJuridique` désynchronisables** : double tracking sans contrainte | `lib/models/facture_model.dart` |
| I3 | **`Paiement.isAcompte` jamais utilisé** | `lib/models/paiement_model.dart` |
| I4 | **`acompte_percentage` jamais lu** côté métier | `lib/models/devis_model.dart` |
| I5 | **GlobalSearchRepository cherche des colonnes inexistantes** (`description` sur dépenses, `reference`/`categorie` sur articles) | `lib/repositories/global_search_repository.dart` |
| I6 | **Mention « Dispensé d'immatriculation » ajoutée pour tous les micro-entrepreneurs** y compris ceux inscrits au RM/RCS | `lib/services/pdf_service.dart` |
| I7 | **Mention TVA imprimée en doublon** (corps + footer) | `lib/services/pdf_service.dart`, thèmes PDF |
| I8 | **Vues legacy non supprimées** (2419 lignes de duplication) | `lib/views/ajout_devis_view.dart`, `lib/views/ajout_facture_view.dart` |
| I9 | **Chiffrage absent du stepper devis** (aucun step ne l'édite, fonctionnalité perdue vs vue legacy) | `lib/views/devis/stepper/devis_stepper_view.dart` | (pour le chiffrage, il existe une vue dédiée 'rentabilite_view.dart' qui n'est pas intégrée dans le stepper, je souhaite le garder à part pour ne pas alourdir le stepper et surtout pour qu'un client ne vois pas à combien je lui vend de la matière première, je veux que le chiffrage soit un outil interne à l'artisan pour calculer sa rentabilité, et pas une information qui soit visible par le client dans le stepper, revoir si cette vue est fonctionnelle et à jour, si non la mettre à jour et la garder en dehors du stepper) |
| I10 | **Calcul `netAPayer` incohérent** entre `Facture.netAPayer` et `FactureViewModel.getImpayes()` | `lib/models/facture_model.dart`, `lib/viewmodels/facture_viewmodel.dart` |

#### MINEUR (Améliorations)

| # | Problème |
|---|---|
| M1 | Pas de `updated_at` sur les tables principales |
| M2 | Pas de soft-delete (le DELETE est physique) |
| M3 | Pas de validation Luhn sur SIRET |
| M4 | Pas de champ `numero_bon_commande` client |
| M5 | Pas de champ `motif_avoir` |
| M6 | Pas de gestion multi-devises (acceptable pour micro-entreprise France) |
| M7 | Seuils TVA hardcodés dans le modèle au lieu d'être versionnés par année |
| M8 | Pas d'UI pour les relances (service existant mais non exploité) |
| M9 | Pas d'envoi de documents par email |
| M10 | `LigneEditor` : condition `if (widget.type == 'titre')` dupliquée |

---

### Steps d'implémentation

#### Sprint 1 — Conformité légale PDF & mentions obligatoires (Priorité CRITIQUE)

1. **Ajouter les mentions légales obligatoires** dans `lib/services/pdf_service.dart` (`_buildFooterSignatures` et `_buildTotals`) :
   - Imprimer `conditionsReglement` sous le tableau des totaux
   - Imprimer `dateEcheance` formatée en haut du document (à côté de la date d'émission)
   - Ajouter la mention fixe : *« En cas de retard de paiement, une indemnité forfaitaire de 40€ pour frais de recouvrement sera exigée, conformément à l'article L.441-10 du Code de commerce. »*
   - Ajouter la mention : *« Taux de pénalités de retard : {X}% par an »* (champ configurable dans `ProfilEntreprise`, défaut 3× taux légal)
   - Ajouter la mention : *« Pas d'escompte pour paiement anticipé »* (ou champ configurable)
2. **Corriger le doublon TVA** : supprimer la mention « TVA non applicable » de `_buildFooterSignatures` et ne la garder QUE dans `buildFooterMentions` des thèmes
3. **Conditionner la mention « Dispensé d'immatriculation »** : ajouter un champ `estImmatricule` (bool) dans `ProfilEntreprise` ; n'afficher la dispense que si `false`
4. **Afficher le numéro de la facture d'origine sur les avoirs** : résoudre `factureSourceId` → `numeroFacture` dans le `PdfService` et l'imprimer sous le titre « AVOIR — Réf. facture F-2026-XXXX »
5. **Masquer la colonne TVA sur le PDF** quand `tva_applicable == false` (ne pas montrer de taux TVA en franchise de base)
6. Mettre à jour les 3 thèmes PDF en conséquence dans `lib/services/pdf_themes/`

#### Sprint 2 — Immutabilité & piste d'audit (Priorité CRITIQUE)

7. **Créer une migration SQL `audit_trail`** : nouvelle table `audit_logs` avec colonnes `(id, user_id, table_name, record_id, action [create/update/delete/status_change], old_data JSONB, new_data JSONB, created_at, ip_address)`
8. **Créer des triggers PostgreSQL `AFTER INSERT/UPDATE/DELETE`** sur `factures`, `devis`, `paiements` qui insèrent automatiquement dans `audit_logs`
9. **Bloquer la modification des factures validées** :
   - Trigger `BEFORE UPDATE` sur `factures` : si `statut_juridique` IN (`'validee'`, `'payee'`) ET que des colonnes de contenu changent (hors `statut`, `est_archive`, `signature_url`), → `RAISE EXCEPTION`
   - Côté Dart dans `FactureRepository.updateFacture()` : vérifier `facture.statutJuridique != 'brouillon'` → throw
10. **Bloquer la suppression des documents non-brouillon** :
    - Trigger `BEFORE DELETE` sur `factures` : si `statut_juridique != 'brouillon'` → `RAISE EXCEPTION`
    - Trigger `BEFORE DELETE` sur `devis` : si `statut NOT IN ('brouillon', 'annule')` → `RAISE EXCEPTION`
11. **Implémenter le soft-delete** : ajouter `deleted_at TIMESTAMP` à `factures` et `devis`, modifier les repositories pour filtrer `deleted_at IS NULL` au lieu de DELETE physique pour les brouillons

#### Sprint 3 — Unification numérotation & modèle de données (Priorité CRITIQUE)

12. **Supprimer le mécanisme Dart de numérotation** dans `lib/core/document_repository.dart` (`generateNextNumero()`) — ne garder QUE le trigger PostgreSQL qui est atomique et sans race condition
13. **Unifier les préfixes** : s'assurer que le trigger SQL et le code Dart utilisent les mêmes formats (`D-`, `F-`, `AV-`, `FA-`). Mettre à jour le `DevisViewModel.finaliserDevis()` pour ne plus appeler `generateNextNumero()` côté Dart mais laisser le trigger faire
14. **Corriger la contrainte CHECK pour les avoirs** : modifier la migration pour `CHECK (total_ttc >= 0 OR type = 'avoir')` (ou stocker les avoirs en montants positifs avec un flag `sens = 'credit'`)
15. **Simplifier `Facture`** :
    - Supprimer `typeDocument` (redondant avec `type`)
    - Supprimer `statutJuridique` (le dériver de `statut` via un getter : brouillon→brouillon, validee/envoye/signee→validee, payee→payee)
    - Ou si on garde `statutJuridique`, ajouter un trigger SQL qui le synchronise automatiquement
16. **Ajouter les champs manquants** au modèle `Facture` : `numero_bon_commande` (TEXT, nullable), `motif_avoir` (TEXT, nullable, requis si type=avoir)
17. **Ajouter les champs manquants** à `ProfilEntreprise` : `taux_penalites_retard` (NUMERIC, défaut 11.62), `escompte_applicable` (BOOLEAN, défaut false), `est_immatricule` (BOOLEAN, défaut false)
18. **Nettoyer `Paiement.isAcompte`** : soit le supprimer, soit l'utiliser effectivement pour ventiler acomptes vs soldes dans le PDF/dashboard
19. **Corriger `GlobalSearchRepository`** : remplacer les colonnes inexistantes par les bonnes (`titre` au lieu de `description` pour dépenses, `designation` au lieu de `reference` pour articles)

#### Sprint 4 — Gestion TVA & dépassement de seuil (Priorité IMPORTANTE)

20. **Créer un service `TvaService`** capable de :
    - Calculer le CA cumulé YTD par type d'activité (vente/service)
    - Comparer aux seuils de franchise en base (configurables par année dans `UrssafConfig`)
    - Détecter le dépassement de seuil et alerter l'utilisateur
    - Gérer la transition : franchise → assujettissement en cours d'année
21. **Ajouter une table `seuils_tva`** versionnée par année (pour suivre les changements législatifs : 2024, 2025, 2026+)
22. **Modifier les écrans de création devis/facture** : si dépassement détecté, forcer `tva_applicable = true` et afficher une alerte explicative
23. **Modifier le calcul des lignes** : quand TVA applicable, chaque ligne porte son `taux_tva` (déjà supporté) ; quand franchise en base, forcer tous les taux à 0% et masquer la colonne TVA du PDF
24. **Ajouter au dashboard** un widget « Suivi seuil TVA » affichant la progression vers les plafonds

#### Sprint 5 — Suppression vues legacy & intégration chiffrage stepper (Priorité IMPORTANTE)

25. **Supprimer** `lib/views/ajout_devis_view.dart` (1359 lignes) et `lib/views/ajout_facture_view.dart` (1060 lignes)
26. **Ajouter un Step 5 « Analyse de coûts »** (optionnel) au stepper devis dans `lib/views/devis/stepper/devis_stepper_view.dart` : réintégrer l'éditeur de chiffrage/rentabilité qui existait dans la vue legacy via le widget `ChiffrageEditor` déjà existant
27. **Ajouter un champ `numero_bon_commande`** dans le Step 2 Détails du stepper facture
28. **Ajouter un champ `motif_avoir`** dans le stepper facture quand `type == 'avoir'`
29. **Nettoyer les imports** : supprimer toutes les références aux vues legacy dans le routeur et les imports
30. **Corriger le doublon** dans `lib/widgets/ligne_editor.dart` (condition `if (widget.type == 'titre')` dupliquée)

#### Sprint 6 — Envoi de documents par email (Priorité IMPORTANTE)

31. **Ajouter le package `url_launcher`** (ou `mailer`) au `pubspec.yaml`
32. **Implémenter `EmailService`** :
    - Méthode `sendDocument(email, subject, body, pdfBytes)` via `mailto:` URI avec pièce jointe (ou intégration Supabase Edge Function pour SMTP)
    - Templates d'email configurables : envoi devis, envoi facture, relance
33. **Ajouter un bouton « Envoyer par email »** dans les actions contextuelles des listes devis et factures (à côté de « Générer PDF »)
34. **MAJ automatique du statut** : après envoi confirmé, passer le devis à `envoye` / la facture à `envoye`
35. **Logger l'envoi** dans `audit_logs` (date, destinataire, type de document)

#### Sprint 7 — UI relances & workflow complet (Priorité MOYENNE)

36. **Créer un écran « Relances »** exploitant le `RelanceService` déjà codé :
    - Liste des factures impayées par niveau (amiable, ferme, mise en demeure, contentieux)
    - Bouton « Relancer » → génère un email de relance avec le texte adapté au niveau
    - Historique des relances envoyées (stocker dans `audit_logs` ou table dédiée `relances`)
37. **Ajouter un widget « Factures en retard »** sur le dashboard avec badge de notification
38. **Corriger le calcul `getImpayes()`** dans `FactureViewModel` pour utiliser `facture.netAPayer` (getter centralisé) au lieu de recalculer manuellement
39. **Ajouter `updated_at`** à toutes les tables principales via migration ALTER TABLE + trigger `BEFORE UPDATE SET updated_at = NOW()`

#### Sprint 8 — Simplification micro-entreprise & polish (Priorité MOYENNE)

40. **Simplifier `ProfilEntreprise`** : retirer les types d'entreprise non pertinents (EURL, SASU, etc.), ne garder que `micro_entrepreneur` avec sous-catégorie (artisan, commerçant, libéral)
41. **Onboarding guidé** : à la première connexion, assistant de configuration pas-à-pas (identité, SIRET, type d'activité, régime fiscal, IBAN, logo) qui pré-remplit les mentions légales
42. **Valider le SIRET** avec l'algorithme de Luhn (pas juste le format 14 chiffres)
43. **Archivage automatique** : factures payées depuis > 1 an → proposition d'archivage
44. **Tests** : ajouter des tests unitaires pour les nouvelles fonctionnalités (TvaService, EmailService, audit trail), tests widget pour les steppers, et mettre à jour les tests existants impactés par les modifications de modèle

---

### Vérification

- **Tests unitaires** : exécuter `flutter test` — viser 100% pass rate ; ajouter des tests pour chaque mention légale du PDF (vérifier la présence de chaque texte obligatoire)
- **Test d'intégrité DB** : script SQL vérifiant qu'aucune facture validée n'a été modifiée après `date_validation`, que la numérotation est séquentielle sans trous
- **Test workflow E2E** : Devis brouillon → envoi → signature → transformation en facture acompte + facture de solde → paiement → clôture. Vérifier PDF, mentions, numérotation, audit trail
- **Test conformité PDF** : checklist manuelle des 20 mentions obligatoires sur un PDF généré, par type de document (devis, facture, acompte, avoir)
- **Test dépassement TVA** : simuler un CA dépassant le seuil et vérifier l'alerte + basculement

### Décisions architecturales

- **Pas de réécriture complète** : l'architecture MVVM + Supabase est saine, les modèles Decimal sont corrects. Refonte ciblée par sprint
- **Micro-entreprise uniquement** : simplification du modèle `ProfilEntreprise` et suppression des chemins de code multi-statuts
- **Suppression des vues legacy** : les steppers les remplacent, on récupère le chiffrage dans un step additionnel
- **Numérotation : trigger SQL seul** : supprimer le mécanisme Dart redondant pour éliminer les conflits
- **Avoirs en montants positifs** (option recommandée) : stocker les montants en valeur absolue avec un champ `sens` (`'debit'`/`'credit'`), ce qui évite de casser les contraintes CHECK et simplifie les agrégats
- **Seuils TVA versionnés** : table dédiée plutôt que constantes hardcodées, pour s'adapter aux changements législatifs annuels
- **Email via `mailto:`** en V1 (zéro infrastructure), avec possibilité d'évoluer vers Supabase Edge Function + SMTP en V2


### Remarques :

- Je veux que l'on revois entièrement le custom_Drawer pour le simplifier et le rendre plus moderne, actuellement il est très lourd et compliqué à maintenir, je veux qu'on parte sur une base plus simple et plus facilement maintenable, avec une navigation plus fluide et plus rapide, et surtout avec un design plus épuré et plus moderne, je veux que le custom_Drawer soit un vrai atout pour l'application et pas un frein à son évolution, revoir les différentes sections du drawer pour les regrouper de manière plus logique et intuitive, et surtout revoir la partie profil entreprise qui est très mal fichue actuellement, je veux que le profil entreprise soit facilement accessible depuis le drawer, avec une interface claire et simple pour éditer les informations de l'entreprise, et surtout avec une navigation fluide pour accéder aux différentes sections du profil entreprise (informations générales, paramètres de facturation, paramètres de TVA, etc.) Tu peux ajouter tout ce que tu juge nécessaire pour améliorer le custom_Drawer et le profil entreprise, l'objectif c'est de rendre ces sections plus accessibles, plus intuitives et plus agréables à utiliser pour les artisans. Il faut le hiérarchiser de manière à ce que les informations les plus importantes soient facilement accessibles, et que les paramètres avancés soient regroupés dans une section dédiée pour ne pas surcharger l'interface principale du drawer. Revoir peut être les tailles des icônes, les couleurs, les typographies, pour rendre le drawer plus moderne et plus en phase avec les tendances actuelles, et surtout pour qu'il soit plus agréable à utiliser au quotidien par les artisans.

- je veux que l'on revoie entièrement le design de toute l'application pour le rendre plus moderne et plus épuré, actuellement le design est très daté et pas du tout en phase avec les tendances actuelles, je veux que l'on parte sur une base de design plus moderne, avec des couleurs plus douces, des typographies plus modernes, et surtout avec une interface plus épurée et plus agréable à utiliser, revoir les différentes sections de l'application pour les regrouper de manière plus logique et intuitive, et surtout revoir la partie dashboard qui est très mal fichue actuellement, je veux que le dashboard soit facilement accessible depuis le drawer, avec une interface claire et simple pour afficher les informations clés de l'entreprise (CA, factures en retard, suivi des seuils TVA, etc.) et surtout avec une navigation fluide pour accéder aux différentes sections du dashboard (statistiques, relances, etc.) Tu peux ajouter tout ce que tu juge nécessaire pour améliorer le design de l'application, l'objectif c'est de rendre l'application plus moderne, plus agréable à utiliser, et surtout plus adaptée aux besoins des artisans.

- Je veux que l'on ajoute la possibilité de customiser entièrement les PDF, couleurs, logo, logo de pieds de page (par exemple service à la personne), des décorations, etc.

- Si tu à des propositions à me faire pour améliorer l'application je t'écoute, je veux pouvoir concurencer Abby et les grosse application de ce genre.
