import '../../../../core/result/result.dart';
import '../entities/teacher_profile.dart';
import '../repositories/profile_repository.dart';

class EditProfileParams {
  const EditProfileParams({
    required this.accessToken,
    this.phone,
    this.qualification,
    this.gender,
    this.name,
    this.email,
    this.dob,
    this.avatar,
  });

  final String accessToken;
  final String? phone;
  final String? qualification;
  final String? gender;
  final String? name;
  final String? email;
  final DateTime? dob;
  final String? avatar;
}

class EditProfileUseCase {
  const EditProfileUseCase(this._repository);
  final ProfileRepository _repository;

  Future<Result<void>> call(EditProfileParams params) {
    return _repository.updateProfile(
      accessToken: params.accessToken,
      update: ProfileUpdate(
        phone: params.phone,
        qualification: params.qualification,
        gender: params.gender,
        name: params.name,
        email: params.email,
        dob: params.dob,
        avatar: params.avatar,
      ),
    );
  }
}