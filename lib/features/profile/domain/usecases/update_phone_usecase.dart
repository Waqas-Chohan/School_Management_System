import '../../../../core/result/result.dart';
import '../repositories/profile_repository.dart';

class UpdatePhoneParams {
  const UpdatePhoneParams({
    required this.accessToken,
    required this.phone,
  });
  final String accessToken;
  final String phone;
}

class UpdatePhoneUseCase {
  const UpdatePhoneUseCase(this._repository);
  final ProfileRepository _repository;

  Future<Result<void>> call(UpdatePhoneParams params) {
    return _repository.updatePhone(
      accessToken: params.accessToken,
      phone: params.phone,
    );
  }
}