import '../../domain/entities/settings.dart';

/// Common contract implemented by the mock and remote settings data sources so
/// the repository can swap between them with a one-line provider change.
abstract class SettingsDataSource {
  Future<List<SettingsItem>> fetchItems();

  /// Changes the teacher's password through the portal's
  /// `PUT /teacher-portal/profile/change-password` endpoint.
  Future<void> changePassword(
    String accessToken, {
    required String currentPassword,
    required String newPassword,
  });
}