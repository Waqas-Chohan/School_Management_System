import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/result/result.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/profile_data_source.dart';
import '../../data/datasources/profile_mock_data_source.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/teacher_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_phone_usecase.dart';

// Data layer providers

final profileMockDataSourceProvider = Provider<ProfileDataSource>((ref) {
  return ProfileMockDataSourceImpl();
});

final profileRemoteDataSourceProvider = Provider<ProfileDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

// Swap to `ref.watch(profileRemoteDataSourceProvider)` when the API is ready.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileMockDataSourceProvider));
});

// ── Use case providers ───────────────────────────────

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updatePhoneUseCaseProvider = Provider<UpdatePhoneUseCase>((ref) {
  return UpdatePhoneUseCase(ref.watch(profileRepositoryProvider));
});

String _readAccessToken(Ref ref) {
  return ref.read(authSessionProvider)?.accessToken ?? '';
}

// ── State ────────────────────────────────────────────

final profileProvider = FutureProvider.autoDispose<TeacherProfile>((ref) async {
  final accessToken = _readAccessToken(ref);
  final result = await ref.read(getProfileUseCaseProvider)(
    GetProfileParams(accessToken: accessToken),
  );
  return result.fold((profile) => profile, (failure) => throw failure);
});

/// Controller for editing the profile phone number.
final updatePhoneControllerProvider =
    NotifierProvider<UpdatePhoneController, AsyncValue<void>>(
      UpdatePhoneController.new,
    );

class UpdatePhoneController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  AppFailure? get errorOrNull => state is AsyncError
      ? (state as AsyncError).error is AppFailure
          ? (state as AsyncError).error as AppFailure
          : const UnknownFailure('Unable to update the phone number.')
      : null;

  Future<bool> updatePhone(String phone) async {
    final accessToken = _readAccessToken(ref);
    state = const AsyncLoading();
    final result = await ref.read(updatePhoneUseCaseProvider)(
      UpdatePhoneParams(accessToken: accessToken, phone: phone),
    );
    state = result.fold((_) {
      ref.invalidate(profileProvider);
      return const AsyncData(null);
    }, (failure) => AsyncError(failure, StackTrace.current));
    return state is AsyncData;
  }
}