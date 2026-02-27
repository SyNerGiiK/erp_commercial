import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// ViewModels
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../viewmodels/facture_viewmodel.dart';
import '../viewmodels/devis_viewmodel.dart';
import '../viewmodels/entreprise_viewmodel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../viewmodels/urssaf_viewmodel.dart';
import '../viewmodels/depense_viewmodel.dart';
import '../viewmodels/article_viewmodel.dart';
import '../viewmodels/planning_viewmodel.dart';
import '../viewmodels/shopping_viewmodel.dart';
import '../viewmodels/global_search_viewmodel.dart';
import '../viewmodels/editor_state_provider.dart';
import '../viewmodels/relance_viewmodel.dart';
import '../viewmodels/corbeille_viewmodel.dart';
import '../viewmodels/facture_recurrente_viewmodel.dart';
import '../viewmodels/temps_viewmodel.dart';
import '../viewmodels/rappel_viewmodel.dart';
import '../viewmodels/rentabilite_viewmodel.dart';
import '../viewmodels/support_viewmodel.dart';
import '../viewmodels/admin_viewmodel.dart'; // Added
import '../viewmodels/pdf_studio_viewmodel.dart';

class DependencyInjection {
  static List<SingleChildWidget> get providers {
    return [
      // AuthViewModel : instancié immédiatement (auth guard du router)
      ChangeNotifierProvider(create: (_) => AuthViewModel()),

      // Tous les autres providers sont lazy (instanciés au premier accès)
      ChangeNotifierProvider(lazy: true, create: (_) => ClientViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => EntrepriseViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => FactureViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => DevisViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => DepenseViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => DashboardViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => UrssafViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => ArticleViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => PlanningViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => ShoppingViewModel()),
      ChangeNotifierProvider(
          lazy: true, create: (_) => GlobalSearchViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => EditorStateProvider()),
      ChangeNotifierProvider(lazy: true, create: (_) => RelanceViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => CorbeilleViewModel()),
      ChangeNotifierProvider(
          lazy: true, create: (_) => FactureRecurrenteViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => TempsViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => RappelViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => RentabiliteViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => SupportViewModel()),
      // AdminViewModel : ne lance plus de requêtes en constructeur
      ChangeNotifierProvider(lazy: true, create: (_) => AdminViewModel()),
      ChangeNotifierProvider(lazy: true, create: (_) => PdfStudioViewModel()),
    ];
  }
}
