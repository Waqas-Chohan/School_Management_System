import '../../../../core/result/result.dart';
import '../entities/settings.dart';

/// Contract implemented by the data layer.
abstract class SettingsRepository {
  Future<Result<List<SettingsItem>>> fetchSettingsItems();
  Future<Result<void>> logout({required String accessToken});

  /// Passwords for the portal's `PUT /profile/change-password`.
  Future<Result<void>> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  });
}