import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/settings_data_source.dart';
import '../../data/datasources/settings_mock_data_source.dart';
import '../../data/datasources/settings_remote_data_source.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/get_settings_items_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

// ── Data layer providers ─────────────────────────────

final settingsDataSourceProvider = Provider<SettingsDataSource>((ref) {
  return SettingsMockDataSourceImpl();
});

final settingsRemoteDataSourceProvider = Provider<SettingsDataSource>((ref) {
  return SettingsRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

// Items stay on the mock (no portal endpoint); logout/change-password hit the
// live API through the remote source.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    ref.watch(settingsDataSourceProvider),
    ref.watch(settingsRemoteDataSourceProvider),
  );
});

// ── Use case providers ───────────────────────────────

final getSettingsItemsUseCaseProvider = Provider<GetSettingsItemsUseCase>((ref) {
  return GetSettingsItemsUseCase(ref.watch(settingsRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(settingsRepositoryProvider));
});

// ── State ────────────────────────────────────────────

final settingsItemsProvider = FutureProvider.autoDispose<List<SettingsItem>>(
  (ref) async {
    final result = await ref.read(getSettingsItemsUseCaseProvider)(
      const GetSettingsItemsParams(),
    );
    return result.fold((items) => items, (failure) => throw failure);
  },
);

/// Controller driving the logout flow.
final logoutControllerProvider =
    NotifierProvider<LogoutController, AsyncValue<void>>(
      LogoutController.new,
    );

class LogoutController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  bool get isLoggingOut => state is AsyncLoading;

  AppFailure? get errorOrNull => state is AsyncError
      ? (state as AsyncError).error is AppFailure
          ? (state as AsyncError).error as AppFailure
          : const UnknownFailure('Unable to log out.')
      : null;

  Future<bool> logout() async {
    final accessToken = ref.read(authSessionProvider)?.accessToken ?? '';
    state = const AsyncLoading();
    final result = await ref.read(logoutUseCaseProvider)(
      LogoutParams(accessToken: accessToken),
    );
    state = result.fold((_) {
      ref.read(authSessionProvider.notifier).clear();
      return const AsyncData(null);
    }, (failure) => AsyncError(failure, StackTrace.current));
    return state is AsyncData;
  }
}

// ── Change password ─────────────────────────────────

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.watch(settingsRepositoryProvider));
});

final changePasswordControllerProvider =
    NotifierProvider<ChangePasswordController, AsyncValue<void>>(
      ChangePasswordController.new,
    );

class ChangePasswordController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  bool get isSaving => state is AsyncLoading;

  AppFailure? get errorOrNull => state is AsyncError
      ? (state as AsyncError).error is AppFailure
          ? (state as AsyncError).error as AppFailure
          : const UnknownFailure('Unable to change the password.')
      : null;

  Future<bool> change({
    required String currentPassword,
    required String newPassword,
  }) async {
    final accessToken = ref.read(authSessionProvider)?.accessToken ?? '';
    state = const AsyncLoading();
    final result = await ref.read(changePasswordUseCaseProvider)(
      ChangePasswordParams(
        accessToken: accessToken,
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
    state = result.fold(
      (_) => const AsyncData(null),
      (failure) => AsyncError(failure, StackTrace.current),
    );
    return state is AsyncData;
  }
}