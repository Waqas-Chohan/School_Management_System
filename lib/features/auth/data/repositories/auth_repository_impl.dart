import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_mock_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implements the [AuthRepository] contract on top of the data sources.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._mockDataSource,
    this._remoteDataSource,
    this._secureStorage,
  );

  static const _accessTokenKey = 'access_token';

  final AuthMockDataSource _mockDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _secureStorage;

  @override
  Future<Result<AuthSession>> login(LoginCredentials credentials) async {
    final remote = await _remoteDataSource.login(
      username: credentials.username,
      password: credentials.password,
    );
    if (remote is Success<AuthSession>) {
      await _secureStorage.write(
        key: _accessTokenKey,
        value: remote.data.accessToken,
      );
      return remote;
    }

    // Fall back to the mock identity only when the API is unreachable,
    // so the app remains usable during development.
    if (remote is Failure && remote.failureOrNull is NetworkFailure) {
      try {
        final session = await _mockDataSource.login(
          username: credentials.username,
          password: credentials.password,
        );
        await _secureStorage.write(
          key: _accessTokenKey,
          value: session.accessToken,
        );
        return Success(session);
      } on Object {
        return const Failure(UnauthorizedFailure('Invalid username or password.'));
      }
    }

    return remote;
  }

  @override
  Future<Result<void>> logout({required String accessToken}) async {
    final remote = await _remoteDataSource.logout(accessToken: accessToken);
    await _secureStorage.delete(key: _accessTokenKey);
    return remote.fold<Result<void>>(
      (data) => const Success(null),
      (failure) => Failure(failure),
    );
  }

  @override
  Future<String?> readStoredAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<void> persistSession(AuthSession session) async {
    await _secureStorage.write(
      key: _accessTokenKey,
      value: session.accessToken,
    );
  }

  @override
  Future<void> clearSession() async {
    await _secureStorage.delete(key: _accessTokenKey);
  }
}