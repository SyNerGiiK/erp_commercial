import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/client_model.dart';
import '../models/depense_model.dart';

import '../views/landing_view.dart';
import '../views/login_view.dart';
import '../views/tableau_de_bord_view.dart';
import '../views/planning_view.dart';
import '../views/liste_devis_view.dart';
import '../views/liste_factures_view.dart';
import '../views/liste_clients_view.dart';
import '../views/liste_depenses_view.dart';
import '../views/settings_root_view.dart';
import '../views/parametres_view.dart';
import '../views/bibliotheque_prix_view.dart';
import '../views/profil_entreprise_view.dart';
import '../views/ajout_devis_view.dart';
import '../views/ajout_facture_view.dart';
import '../views/ajout_client_view.dart';
import '../views/ajout_depense_view.dart';
import '../views/global_search_view.dart';
import '../views/shopping_list_view.dart';
import '../views/archives_view.dart';

class AppRouter {
  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable:
          authViewModel, // Écoute les changements d'auth (Login/Logout)
      debugLogDiagnostics: true,

      // REDIRECTION AUTOMATIQUE (Guard) - Architecture SaaS
      redirect: (context, state) {
        final isLoggedIn = authViewModel.currentUser != null;
        final isOnAppRoute = state.matchedLocation.startsWith('/app');
        final isOnLogin = state.matchedLocation == '/login';
        final isOnLanding = state.matchedLocation == '/';

        // Utilisateur NON connecté tente d'accéder à /app/* → Redirection /login
        if (!isLoggedIn && isOnAppRoute) {
          return '/login';
        }

        // Utilisateur connecté sur / ou /login → Redirection /app/home
        if (isLoggedIn && (isOnLanding || isOnLogin)) {
          return '/app/home';
        }

        return null; // Pas de redirection
      },

      routes: [
        // ========== ROUTES PUBLIQUES ==========
        GoRoute(
          path: '/',
          builder: (_, __) => const LandingView(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginView(),
        ),

        // ========== ROUTES PRIVÉES (Préfixe /app) ==========
        GoRoute(
          path: '/app/home',
          builder: (_, __) => const TableauDeBordView(),
        ),
        GoRoute(
          path: '/app/planning',
          builder: (_, __) => const PlanningView(),
        ),
        GoRoute(
          path: '/app/devis',
          builder: (_, __) => const ListeDevisView(),
        ),
        GoRoute(
          path: '/app/factures',
          builder: (_, __) => const ListeFacturesView(),
        ),
        GoRoute(
          path: '/app/clients',
          builder: (_, __) => const ListeClientsView(),
        ),
        GoRoute(
          path: '/app/depenses',
          builder: (_, __) => const ListeDepensesView(),
        ),
        GoRoute(
          path: '/app/courses',
          builder: (_, __) => const ShoppingListView(),
        ),
        GoRoute(
          path: '/app/parametres',
          builder: (_, __) => const SettingsRootView(),
        ),
        GoRoute(
          path: '/app/config_urssaf',
          builder: (_, __) => const ParametresView(),
        ),
        GoRoute(
          path: '/app/profil',
          builder: (_, __) => const ProfilEntrepriseView(),
        ),
        GoRoute(
          path: '/app/bibliotheque',
          builder: (_, __) => const BibliothequePrixView(),
        ),
        GoRoute(
          path: '/app/archives',
          builder: (_, __) => const ArchivesView(),
        ),
        GoRoute(
          path: '/app/search',
          builder: (_, __) => const GlobalSearchView(),
        ),

        // --- ROUTES DYNAMIQUES (CRUD) ---
        // Supporte : /app/ajout_devis (Nouveau) et /app/ajout_devis/123 (Edit)

        // DEVIS
        GoRoute(
          path: '/app/ajout_devis',
          builder: (context, state) => const AjoutDevisView(),
          routes: [
            GoRoute(
              path: ':id', // /app/ajout_devis/123
              builder: (context, state) {
                final id = state.pathParameters['id'];
                final devis = state.extra as Devis?;
                return AjoutDevisView(id: id, devisAModifier: devis);
              },
            ),
          ],
        ),

        // FACTURES
        GoRoute(
          path: '/app/ajout_facture',
          builder: (context, state) {
            // Gestion paramètre query : ?source_devis=XYZ (Conversion Devis->Facture)
            final sourceDevisId = state.uri.queryParameters['source_devis'];
            return AjoutFactureView(sourceDevisId: sourceDevisId);
          },
          routes: [
            GoRoute(
              path: ':id', // /app/ajout_facture/123
              builder: (context, state) {
                final id = state.pathParameters['id'];
                final facture = state.extra as Facture?;
                return AjoutFactureView(id: id, factureAModifier: facture);
              },
            ),
          ],
        ),

        // CLIENTS
        GoRoute(
          path: '/app/ajout_client',
          builder: (context, state) => const AjoutClientView(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                final client = state.extra as Client?;
                return AjoutClientView(id: id, clientAModifier: client);
              },
            ),
          ],
        ),

        // DEPENSES
        GoRoute(
          path: '/app/ajout_depense',
          builder: (context, state) => const AjoutDepenseView(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                final depense = state.extra as Depense?;
                return AjoutDepenseView(id: id, depenseAModifier: depense);
              },
            ),
          ],
        ),
      ],
    );
  }
}
