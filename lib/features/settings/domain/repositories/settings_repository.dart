import '../../../../core/result/result.dart';
import '../entities/settings.dart';

/// Contract implemented by the data layer.
abstract class SettingsRepository {
  Future<Result<List<SettingsItem>>> fetchSettingsItems();
  Future<Result<void>> logout({required String accessToken});
}