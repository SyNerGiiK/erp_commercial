import '../models/urssaf_model.dart';
import '../repositories/urssaf_repository.dart';
import '../services/urssaf_sync_service.dart';
import '../core/base_viewmodel.dart';

class UrssafViewModel extends BaseViewModel {
  final IUrssafRepository _repository;
  final UrssafSyncService _syncService;

  UrssafViewModel({
    IUrssafRepository? repository,
    UrssafSyncService? syncService,
  })  : _repository = repository ?? UrssafRepository(),
        _syncService = syncService ?? UrssafSyncService();

  UrssafConfig? _config;
  UrssafConfig? get config => _config;

  /// Message de retour de la dernière synchronisation
  String? _syncMessage;
  String? get syncMessage => _syncMessage;

  Future<void> loadConfig() async {
    await executeOperation(
      () async {
        _config = await _repository.getConfig();
      },
      onError: () {
        _config = UrssafConfig(
          userId: '',
          id: '',
        );
      },
    );
  }

  Future<void> saveConfig(UrssafConfig newConfig) async {
    await executeOperation(() async {
      await _repository.saveConfig(newConfig);
      await loadConfig();
    });
  }

  /// Synchronise les taux depuis l'API URSSAF Publicodes.
  /// Met à jour la config et la sauvegarde si succès.
  /// Retourne true si la synchronisation a réussi.
  Future<bool> syncFromApi() async {
    _syncMessage = null;
    if (_config == null) return false;

    return await executeOperation(
      () async {
        final result = await _syncService.syncFromApi(_config!);

        if (result.success && result.config != null) {
          await _repository.saveConfig(result.config!);
          _config = result.config;
          _syncMessage = 'Taux synchronisés avec succès';
        } else {
          _syncMessage = result.errorMessage ?? 'Erreur inconnue';
          throw Exception(_syncMessage);
        }
      },
      onError: () {
        _syncMessage ??= 'Échec de la synchronisation API';
      },
    );
  }
}
