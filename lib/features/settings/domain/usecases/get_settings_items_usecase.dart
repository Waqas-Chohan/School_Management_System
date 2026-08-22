import '../../../../core/result/result.dart';
import '../entities/settings.dart';
import '../repositories/settings_repository.dart';

class GetSettingsItemsParams {
  const GetSettingsItemsParams();
}

class GetSettingsItemsUseCase {
  const GetSettingsItemsUseCase(this._repository);
  final SettingsRepository _repository;

  Future<Result<List<SettingsItem>>> call(GetSettingsItemsParams params) {
    return _repository.fetchSettingsItems();
  }
}