import '../../../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';

/// Credentials submitted from the login form.
class LoginCredentials {
  const LoginCredentials({required this.username, required this.password});

  final String username;
  final String password;
}

/// Contract to be implemented by the data layer.
abstract class AuthRepository {
  Future<Result<AuthSession>> login(LoginCredentials credentials);
  Future<Result<void>> logout({required String accessToken});
  Future<String?> readStoredAccessToken();
  Future<void> persistSession(AuthSession session);
  Future<void> clearSession();
}