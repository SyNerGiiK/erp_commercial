ARCHITECTURE REFERENCE - ERP ARTISAN 3.0

Ce document est la VÉRITÉ ABSOLUE du projet. Il décrit la stack, les règles de code, la structure des données et la navigation. Toute proposition de code DOIT respecter ce document.

1. STACK TECHNIQUE & ENVIRONNEMENT

Type : Application Web (SaaS) & Mobile (Cross-platform).

Framework : Flutter (SDK >=3.2.2 <4.0.0).

Backend / Base de données : Supabase (PostgreSQL).

Architecture : MVVM (Model - View - ViewModel) + Repository Pattern.

Injection de dépendances : provider (MultiProvider dans main.dart).

Routing : go_router (Redirections dynamiques et Guards).

Gestion des types monétaires : Package decimal (OBLIGATOIRE).

Génération PDF : Package pdf et printing (Pas de path_provider sur le Web).

2. RÈGLES D'OR DE DÉVELOPPEMENT (CRITIQUE)

💰 ARGENT & QUANTITÉS :

Interdiction formelle d'utiliser double pour les prix ou les quantités.

Utiliser EXCLUSIVEMENT le type Decimal.

Pour parser : Decimal.parse(value.toString()).

Pour afficher : myDecimal.toDouble().toStringAsFixed(2).

🛡️ SÉCURITÉ ASYNC :

Après chaque await, insérer if (!mounted) return; avant d'utiliser le context (Navigation, SnackBar, Dialog).

🗄️ SUPABASE NAMING :

Tables SQL : Toujours au PLURIEL (ex: clients, factures).

Clés étrangères : Toujours au SINGULIER + _id (ex: client_id, user_id).

🌐 WEB COMPATIBILITY :

Ne jamais utiliser dart:io (File) pour l'accès fichier. Utiliser Uint8List (bytes).

Les images sont stockées via URL (String) ou Base64, pas de chemin local.

🔑 UI STABILITY :

Dans les listes modifiables (Lignes de facture/devis), utiliser une uiKey (via Uuid().v4()) pour gérer l'identité des widgets lors des redessins ou du Drag & Drop.

3. STRUCTURE DES DONNÉES (MODELS)

Tous les modèles possèdent une méthode fromMap, toMap et copyWith.

Article (article_model.dart)

id (String?)

userId (String?)

designation (String)

prixUnitaire (Decimal)

prixAchat (Decimal)

unite (String, def: 'u')

typeActivite (String: 'service' ou 'vente')

Client (client_model.dart)

id (String?)

userId (String?)

nomComplet (String)

typeClient (String: 'particulier' ou 'professionnel')

nomContact (String?)

siret, tvaIntra (String?)

adresse, codePostal, ville, telephone, email (String)

notesPrivees (String?)

ProfilEntreprise (entreprise_model.dart)

id (String?)

userId (String?)

nomEntreprise, nomGerant (String)

adresse, codePostal, ville, siret, email (String)

telephone, iban, bic (String?)

frequenceCotisation (String)

logoUrl (String? - URL Cloud, pas Base64)

signatureUrl (String? - URL Cloud)

mentionsLegales (String?)

UrssafConfig (urssaf_model.dart)

Configuration des taux de cotisation et seuils. Tous les champs numériques sont des Decimal.

Champs clés : tauxPrestation, tauxVente, plafondCaService, seuilTvaService, etc.

Devis (devis_model.dart)

id, userId (String?)

numeroDevis (String)

clientId (String - Lien vers Client)

statut (String: 'brouillon', etc.)

totalHt, remiseTaux, acompteMontant (Decimal)

lignes (List<LigneDevis>)

chiffrage (List<LigneChiffrage>)

signatureUrl (String?), dateSignature (DateTime?)

LigneDevis (Sub-model)

Contient : description, quantite (Decimal), prixUnitaire (Decimal), totalLigne (Decimal).

Formatage : estGras, estItalique, estSouligne (bool).

Spécial : uiKey (String) pour la gestion UI unique.

Facture (facture_model.dart)

id, userId (String?)

numeroFacture (String)

clientId (String)

devisSourceId (String? - Lien optionnel vers Devis)

statut, statutJuridique (String)

totalHt, remiseTaux, acompteDejaRegle (Decimal)

lignes (List<LigneFacture>)

paiements (List<Paiement>)

chiffrage (List<LigneChiffrage>)

LigneFacture (Sub-model)

Identique à LigneDevis (avec uiKey, quantite Decimal, etc.).

LigneChiffrage (chiffrage_model.dart)

Utilisé pour le calcul de rentabilité interne (invisible client).

prixAchatUnitaire, prixVenteUnitaire (Decimal).

Getters calculés : totalAchat, totalVente.

Paiement (paiement_model.dart)

factureId (String)

montant (Decimal)

datePaiement (DateTime)

typePaiement (String), isAcompte (bool).

Depense (depense_model.dart)

titre, categorie, fournisseur (String)

montant (Decimal)

devisId (String? - Pour lier une dépense à un chantier).

PlanningEvent (planning_model.dart)

titre, description

dateDebut, dateFin (DateTime)

clientId (String?), type (String).

ShoppingItem (shopping_model.dart)

Liste de courses. quantite (Decimal), estAchete (bool).

PhotoChantier (photo_model.dart)

clientId (String), url (String), commentaire (String).

4. NAVIGATION & ROUTING (GoRouter)

Le fichier router.dart gère la navigation avec un système de Guard (Redirection).

Logique de Guard :

Si utilisateur NON connecté → Redirection forcée vers /login.

Si utilisateur connecté et tente d'aller sur /login → Redirection vers /home.

Routes Définies :

/ : SplashView

/login : LoginView

/home : TableauDeBordView

/planning : PlanningView

/devis : ListeDevisView

/factures : ListeFacturesView

/clients : ListeClientsView

/depenses : ListeDepensesView

/courses : ShoppingListView

/parametres : SettingsRootView

/config_urssaf : ParametresView

/profil : ProfilEntrepriseView

/bibliotheque : BibliothequePrixView

/archives : ArchivesView

/search : GlobalSearchView

Routes Dynamiques (CRUD) :

/ajout_devis ou /ajout_devis/:id

/ajout_facture ou /ajout_facture/:id (Supporte query param ?source_devis=ID)

/ajout_client ou /ajout_client/:id

/ajout_depense ou /ajout_depense/:id

Les objets complets (Devis, Facture, Client) peuvent être passés via l'objet extra de GoRouter pour éviter de re-fetcher les données lors de l'édition.

5. ARBORESCENCE DU PROJET (lib/)

config/ : Configuration globale (Supabase, Theme, Router, DI).

models/ : Définition des classes de données (Sources de vérité).

repositories/ : Communication avec Supabase (CRUD). Ne contient pas de logique métier complexe.

services/ : Logique métier externe (PDF, Export CSV).

utils/ : Fonctions utilitaires (Formatage dates, Calculs mathématiques).

viewmodels/ : Gestion d'état (Provider). Fait le lien entre View et Repository. Contient la logique métier.

views/ : Les écrans (UI). Ne doivent pas contenir de logique métier, seulement de l'affichage.

widgets/ : Composants UI réutilisables (Cards, Dialogs, Inputs).