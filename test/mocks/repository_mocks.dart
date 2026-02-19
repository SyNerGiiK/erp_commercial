// Fichier de mocks pour les repositories
// Utilisé pour tester les ViewModels sans dépendre de Supabase

import 'package:mocktail/mocktail.dart';
import 'package:erp_commercial/repositories/client_repository.dart';
import 'package:erp_commercial/repositories/devis_repository.dart';
import 'package:erp_commercial/repositories/facture_repository.dart';
import 'package:erp_commercial/repositories/dashboard_repository.dart';
import 'package:erp_commercial/repositories/depense_repository.dart';
import 'package:erp_commercial/repositories/urssaf_repository.dart';
import 'package:erp_commercial/repositories/article_repository.dart';
import 'package:erp_commercial/repositories/entreprise_repository.dart';
import 'package:erp_commercial/repositories/auth_repository.dart';
import 'package:erp_commercial/repositories/global_search_repository.dart';
import 'package:erp_commercial/repositories/shopping_repository.dart';
import 'package:erp_commercial/repositories/planning_repository.dart';
import 'package:erp_commercial/repositories/facture_recurrente_repository.dart';
import 'package:erp_commercial/repositories/temps_repository.dart';
import 'package:erp_commercial/repositories/rappel_repository.dart';
import 'package:erp_commercial/repositories/chiffrage_repository.dart';

// Mock pour ClientRepository
class MockClientRepository extends Mock implements IClientRepository {}

// Mock pour DevisRepository
class MockDevisRepository extends Mock implements IDevisRepository {}

// Mock pour FactureRepository
class MockFactureRepository extends Mock implements IFactureRepository {}

// Mock pour DashboardRepository
class MockDashboardRepository extends Mock implements IDashboardRepository {}

// Mock pour DepenseRepository
class MockDepenseRepository extends Mock implements IDepenseRepository {}

// Mock pour UrssafRepository
class MockUrssafRepository extends Mock implements IUrssafRepository {}

// Mock pour ArticleRepository
class MockArticleRepository extends Mock implements IArticleRepository {}

// Mock pour EntrepriseRepository
class MockEntrepriseRepository extends Mock implements IEntrepriseRepository {}

// Mock pour AuthRepository
class MockAuthRepository extends Mock implements IAuthRepository {}

// Mock pour GlobalSearchRepository
class MockGlobalSearchRepository extends Mock
    implements IGlobalSearchRepository {}

// Mock pour ShoppingRepository
class MockShoppingRepository extends Mock implements IShoppingRepository {}

// Mock pour PlanningRepository
class MockPlanningRepository extends Mock implements IPlanningRepository {}

// Mock pour FactureRecurrenteRepository
class MockFactureRecurrenteRepository extends Mock
    implements IFactureRecurrenteRepository {}

// Mock pour TempsRepository
class MockTempsRepository extends Mock implements ITempsRepository {}

// Mock pour RappelRepository
class MockRappelRepository extends Mock implements IRappelRepository {}

// Mock pour ChiffrageRepository
class MockChiffrageRepository extends Mock implements IChiffrageRepository {}

// Ajouter d'autres mocks de repositories ici selon les besoins
