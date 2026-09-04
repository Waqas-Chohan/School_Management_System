import '../../../../core/result/result.dart';
import '../repositories/settings_repository.dart';

class ChangePasswordParams {
  const ChangePasswordParams({
    required this.accessToken,
    required this.currentPassword,
    required this.newPassword,
  });

  final String accessToken;
  final String currentPassword;
  final String newPassword;
}

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);
  final SettingsRepository _repository;

  Future<Result<void>> call(ChangePasswordParams params) {
    return _repository.changePassword(
      accessToken: params.accessToken,
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}