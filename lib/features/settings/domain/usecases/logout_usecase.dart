import '../../../../core/result/result.dart';
import '../repositories/settings_repository.dart';

class LogoutParams {
  const LogoutParams({required this.accessToken});
  final String accessToken;
}

class LogoutUseCase {
  const LogoutUseCase(this._repository);
  final SettingsRepository _repository;

  Future<Result<void>> call(LogoutParams params) {
    return _repository.logout(accessToken: params.accessToken);
  }
}