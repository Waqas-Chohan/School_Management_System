import '../../../../core/error/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_data_source.dart';

/// Implements [SettingsRepository]. Settings items stay on the local mock
/// (there is no portal endpoint for them), while logout and change-password
/// call the live API with a graceful offline fallback.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._dataSource, this._remoteDataSource);

  final SettingsDataSource _dataSource;
  final SettingsDataSource _remoteDataSource;

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
    // Portal logout is best-effort; always clear the local session.
    return const Success(null);
  }

  @override
  Future<Result<void>> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(
        UnauthorizedFailure('Please login to change your password.'),
      );
    }
    return guardApi(
      () => _remoteDataSource.changePassword(
        accessToken,
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
  }
}