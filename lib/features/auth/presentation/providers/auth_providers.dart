import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/result/result.dart';
import '../../data/datasources/auth_mock_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/auth_session_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

// ── Data layer providers ─────────────────────────────

final authMockDataSourceProvider = Provider<AuthMockDataSource>((ref) {
  return AuthMockDataSourceImpl();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authMockDataSourceProvider),
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageProvider),
  );
});

// ── Use case providers ───────────────────────────────

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

/// Holds the current [AuthSession] (if any) and persists it to secure storage.
final authSessionProvider = NotifierProvider<AuthSessionNotifier, AuthSession?>(
  AuthSessionNotifier.new,
);

class AuthSessionNotifier extends Notifier<AuthSession?> {
  @override
  AuthSession? build() {
    unawaited(_restore());
    return null;
  }

  Future<void> _restore() async {
    final repository = ref.read(authRepositoryProvider);
    final token = await repository.readStoredAccessToken();
    if (token != null && token.isNotEmpty) {
      // Without the full payload we only know the token; reconstruct a
      // lightweight session and let the remote fetch the profile later.
      state = AuthSession(
        accessToken: token,
        refreshToken: '',
        expiresAt: DateTime.now().add(const Duration(hours: 12)),
        employeeName: '',
        employeeId: '',
      );
    }
  }

  void save(AuthSession session) {
    state = session;
    unawaited(_writeToStorage(session));
  }

  void clear() {
    state = null;
    unawaited(_deleteFromStorage());
  }

  Future<void> _writeToStorage(AuthSession session) async {
    await ref
        .read(authRepositoryProvider)
        .persistSession(AuthSessionModel.fromEntity(session));
  }

  Future<void> _deleteFromStorage() async {
    await ref.read(authRepositoryProvider).clearSession();
  }
}

/// Drives the login form submission and exposes the async state to the UI.
final loginControllerProvider =
    NotifierProvider<LoginController, AsyncValue<void>>(LoginController.new);

class LoginController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  bool get isSubmitting => state is AsyncLoading;

  AppFailure? get errorOrNull => state is AsyncError
      ? (state as AsyncError).error is AppFailure
          ? (state as AsyncError).error as AppFailure
          : UnknownFailure('Unable to log in. Please try again.')
      : null;

  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(loginUseCaseProvider)(
      LoginCredentials(username: username, password: password),
    );
    return result.fold((session) {
      ref.read(authSessionProvider.notifier).save(session);
      state = const AsyncData(null);
      return true;
    }, (failure) {
      state = AsyncError(failure, StackTrace.current);
      return false;
    });
  }
}