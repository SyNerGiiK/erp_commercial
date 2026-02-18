import '../models/client_model.dart';
import '../models/facture_model.dart';
import '../models/devis_model.dart';
import '../models/depense_model.dart';
import '../models/article_model.dart';
import '../core/base_repository.dart';

class GlobalSearchResults {
  final List<Client> clients;
  final List<Facture> factures;
  final List<Devis> devis;
  final List<Depense> depenses;
  final List<Article> articles;

  GlobalSearchResults({
    this.clients = const [],
    this.factures = const [],
    this.devis = const [],
    this.depenses = const [],
    this.articles = const [],
  });

  int get totalResults =>
      clients.length +
      factures.length +
      devis.length +
      depenses.length +
      articles.length;
}

abstract class IGlobalSearchRepository {
  Future<GlobalSearchResults> searchAll(String query);
}

class GlobalSearchRepository extends BaseRepository
    implements IGlobalSearchRepository {
  @override
  Future<GlobalSearchResults> searchAll(String query) async {
    try {
      final sanitizedQuery = "%${query.trim()}%";

      final clientFuture = client
          .from('clients')
          .select()
          .eq('user_id', userId)
          .or('nom_complet.ilike.$sanitizedQuery,ville.ilike.$sanitizedQuery,email.ilike.$sanitizedQuery,telephone.ilike.$sanitizedQuery')
          .limit(10);

      final factureFuture = client
          .from('factures')
          .select('*, lignes_factures(*), paiements(*), lignes_chiffrages(*)')
          .eq('user_id', userId)
          .or('numero_facture.ilike.$sanitizedQuery,objet.ilike.$sanitizedQuery')
          .limit(10);

      final devisFuture = client
          .from('devis')
          .select('*, lignes_devis(*), lignes_chiffrages(*)')
          .eq('user_id', userId)
          .or('numero_devis.ilike.$sanitizedQuery,objet.ilike.$sanitizedQuery')
          .limit(10);

      final depenseFuture = client
          .from('depenses')
          .select()
          .eq('user_id', userId)
          .or('titre.ilike.$sanitizedQuery,categorie.ilike.$sanitizedQuery,fournisseur.ilike.$sanitizedQuery')
          .limit(10);

      final articleFuture = client
          .from('articles')
          .select()
          .eq('user_id', userId)
          .or('designation.ilike.$sanitizedQuery,type_activite.ilike.$sanitizedQuery')
          .limit(10);

      final results = await Future.wait([
        clientFuture,
        factureFuture,
        devisFuture,
        depenseFuture,
        articleFuture,
      ]);

      return GlobalSearchResults(
        clients: (results[0] as List).map((e) => Client.fromMap(e)).toList(),
        factures: (results[1] as List).map((e) => Facture.fromMap(e)).toList(),
        devis: (results[2] as List).map((e) => Devis.fromMap(e)).toList(),
        depenses: (results[3] as List).map((e) => Depense.fromMap(e)).toList(),
        articles: (results[4] as List).map((e) => Article.fromMap(e)).toList(),
      );
    } catch (e) {
      handleError(e, 'searchAll');
      return GlobalSearchResults();
    }
  }
}
