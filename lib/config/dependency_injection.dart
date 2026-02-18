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

class DependencyInjection {
  static List<SingleChildWidget> get providers {
    return [
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => ClientViewModel()),
      ChangeNotifierProvider(create: (_) => EntrepriseViewModel()),
      ChangeNotifierProvider(create: (_) => FactureViewModel()),
      ChangeNotifierProvider(create: (_) => DevisViewModel()),
      ChangeNotifierProvider(create: (_) => DepenseViewModel()),
      ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ChangeNotifierProvider(create: (_) => UrssafViewModel()),
      ChangeNotifierProvider(create: (_) => ArticleViewModel()),
      ChangeNotifierProvider(create: (_) => PlanningViewModel()),
      ChangeNotifierProvider(create: (_) => ShoppingViewModel()),
      ChangeNotifierProvider(create: (_) => GlobalSearchViewModel()),
      ChangeNotifierProvider(create: (_) => EditorStateProvider()),
      ChangeNotifierProvider(create: (_) => RelanceViewModel()),
    ];
  }
}
