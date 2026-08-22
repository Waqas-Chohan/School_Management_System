import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_data_source.dart';

/// Implements [SettingsRepository] using the mock data source.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._dataSource);

  final SettingsDataSource _dataSource;

  @override
  Future<Result<List<SettingsItem>>> fetchSettingsItems() async {
    try {
      final items = await _dataSource.fetchItems();
      return Success(items);
    } on Object {
      return const Failure(UnknownFailure('Unable to load settings.'));
    }
  }

  @override
  Future<Result<void>> logout({required String accessToken}) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to log out.'));
    }
    // Mock: logout is considered successful locally.
    return const Success(null);
  }
}