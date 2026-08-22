import '../../../../core/result/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this.repository);

  final AuthRepository repository;

  Future<Result<AuthSession>> call(LoginCredentials credentials) {
    return repository.login(credentials);
  }
}