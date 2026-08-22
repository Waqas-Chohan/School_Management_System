import '../../../../core/result/result.dart';
import '../entities/teacher_profile.dart';

/// Contract implemented by the data layer.
abstract class ProfileRepository {
  Future<Result<TeacherProfile>> fetchProfile({required String accessToken});
  Future<Result<void>> updatePhone({
    required String accessToken,
    required String phone,
  });
}