import '../../../../core/result/result.dart';
import '../../domain/entities/teacher_profile.dart';

/// Common contract implemented by the mock and remote profile data sources so
/// the repository can swap between them with a one-line provider change.
abstract class ProfileDataSource {
  Future<Result<TeacherProfile>> fetchProfile(String accessToken);
  Future<Result<void>> updatePhone(String accessToken, String phone);
  Future<Result<void>> updateProfile(String accessToken, ProfileUpdate update);

  /// Saves the push-notification preference through
  /// `PUT /teacher-portal/settings/notifications`.
  Future<Result<void>> updateNotifications(
    String accessToken, {
    required bool enabled,
  });

  /// Uploads an image (profile picture) through
  /// `POST /teacher-portal/upload`. Returns the avatar path/URL returned by
  /// the server (may be relative, e.g. `/uploads/image-....png`).
  Future<Result<String>> uploadAvatar(
    String accessToken, {
    required String filePath,
  });
}