import '../models/urssaf_model.dart';
import '../repositories/urssaf_repository.dart';
import '../core/base_viewmodel.dart';

class UrssafViewModel extends BaseViewModel {
  final IUrssafRepository _repository;

  UrssafViewModel({IUrssafRepository? repository})
      : _repository = repository ?? UrssafRepository();

  UrssafConfig? _config;
  UrssafConfig? get config => _config;

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
}
