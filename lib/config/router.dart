import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/client_model.dart';
import '../models/depense_model.dart';

import '../views/splash_view.dart';
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

      // REDIRECTION AUTOMATIQUE (Guard)
      redirect: (context, state) {
        final isLoggedIn = authViewModel.currentUser != null;
        final isLoggingIn = state.matchedLocation == '/login';
        final isSplash = state.matchedLocation == '/';

        // Si pas connecté et pas sur login/splash -> Login
        if (!isLoggedIn && !isLoggingIn && !isSplash) {
          return '/login';
        }

        // Si connecté et sur login -> Home
        if (isLoggedIn && isLoggingIn) {
          return '/home';
        }

        return null;
      },

      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashView()),
        GoRoute(path: '/login', builder: (_, __) => const LoginView()),
        GoRoute(path: '/home', builder: (_, __) => const TableauDeBordView()),
        GoRoute(path: '/planning', builder: (_, __) => const PlanningView()),
        GoRoute(path: '/devis', builder: (_, __) => const ListeDevisView()),
        GoRoute(
            path: '/factures', builder: (_, __) => const ListeFacturesView()),
        GoRoute(path: '/clients', builder: (_, __) => const ListeClientsView()),
        GoRoute(
            path: '/depenses', builder: (_, __) => const ListeDepensesView()),
        GoRoute(path: '/courses', builder: (_, __) => const ShoppingListView()),
        GoRoute(
            path: '/parametres', builder: (_, __) => const SettingsRootView()),
        GoRoute(
            path: '/config_urssaf', builder: (_, __) => const ParametresView()),
        GoRoute(
            path: '/profil', builder: (_, __) => const ProfilEntrepriseView()),
        GoRoute(
            path: '/bibliotheque',
            builder: (_, __) => const BibliothequePrixView()),
        GoRoute(path: '/archives', builder: (_, __) => const ArchivesView()),
        GoRoute(path: '/search', builder: (_, __) => const GlobalSearchView()),

        // --- ROUTES DYNAMIQUES (CRUD) ---
        // Supporte : /ajout_devis (Nouveau) et /ajout_devis/123 (Edit)

        // DEVIS
        GoRoute(
          path: '/ajout_devis',
          builder: (context, state) => const AjoutDevisView(),
          routes: [
            GoRoute(
              path: ':id', // /ajout_devis/123
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
          path: '/ajout_facture',
          builder: (context, state) {
            // Gestion paramètre query : ?source_devis=XYZ (Conversion Devis->Facture)
            final sourceDevisId = state.uri.queryParameters['source_devis'];
            return AjoutFactureView(sourceDevisId: sourceDevisId);
          },
          routes: [
            GoRoute(
              path: ':id', // /ajout_facture/123
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
          path: '/ajout_client',
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
          path: '/ajout_depense',
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
