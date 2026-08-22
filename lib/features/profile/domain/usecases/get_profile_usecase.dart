import '../../../../core/result/result.dart';
import '../entities/teacher_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileParams {
  const GetProfileParams({required this.accessToken});
  final String accessToken;
}

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);
  final ProfileRepository _repository;

  Future<Result<TeacherProfile>> call(GetProfileParams params) {
    return _repository.fetchProfile(accessToken: params.accessToken);
  }
}