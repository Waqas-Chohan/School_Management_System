import '../../../../core/result/result.dart';
import '../../domain/entities/teacher_profile.dart';

/// Common contract implemented by the mock and remote profile data sources so
/// the repository can swap between them with a one-line provider change.
abstract class ProfileDataSource {
  Future<Result<TeacherProfile>> fetchProfile(String accessToken);
  Future<Result<void>> updatePhone(String accessToken, String phone);
}