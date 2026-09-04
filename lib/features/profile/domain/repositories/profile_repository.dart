import '../../../../core/result/result.dart';
import '../entities/teacher_profile.dart';

/// Contract implemented by the data layer.
abstract class ProfileRepository {
  Future<Result<TeacherProfile>> fetchProfile({required String accessToken});
  Future<Result<void>> updatePhone({
    required String accessToken,
    required String phone,
  });
  Future<Result<void>> updateProfile({
    required String accessToken,
    required ProfileUpdate update,
  });

  /// Persists the push-notification preference to the portal.
  Future<Result<void>> updateNotifications({
    required String accessToken,
    required bool enabled,
  });

  /// Uploads an image file and returns the server's avatar path/URL.
  Future<Result<String>> uploadAvatar({
    required String accessToken,
    required String filePath,
  });
}