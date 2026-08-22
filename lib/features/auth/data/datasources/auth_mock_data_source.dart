import '../../domain/entities/auth_session.dart';

/// Mock authentication implementation used when the backend is not available.
abstract class AuthMockDataSource {
  Future<AuthSession> login({
    required String username,
    required String password,
  });
}

class AuthMockDataSourceImpl implements AuthMockDataSource {
  AuthMockDataSourceImpl();

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (password.isEmpty) {
      throw const LoginException('Password cannot be empty.');
    }

    return AuthSession(
      accessToken: 'mock-access-token-${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock-refresh-token-${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 12)),
      employeeName: username,
      employeeId: 'EMP-001',
    );
  }
}

class LoginException implements Exception {
  const LoginException(this.message);
  final String message;
}