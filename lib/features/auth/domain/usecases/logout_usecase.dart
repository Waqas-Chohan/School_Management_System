import '../../../../core/result/result.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this.repository);

  final AuthRepository repository;

  Future<Result<void>> call({required String accessToken}) {
    return repository.logout(accessToken: accessToken);
  }
}