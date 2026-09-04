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
import '../../domain/usecases/edit_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_phone_usecase.dart';

// Data layer providers

final profileMockDataSourceProvider = Provider<ProfileDataSource>((ref) {
  return ProfileMockDataSourceImpl();
});

final profileRemoteDataSourceProvider = Provider<ProfileDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

// Remote-first provider: the repository falls back to the mock source only
// when the live API is unreachable.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ref.watch(profileMockDataSourceProvider),
    ref.watch(profileRemoteDataSourceProvider),
  );
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

// ── Edit profile ────────────────────────────────────

final editProfileUseCaseProvider = Provider<EditProfileUseCase>((ref) {
  return EditProfileUseCase(ref.watch(profileRepositoryProvider));
});

final editProfileControllerProvider =
    NotifierProvider<EditProfileController, AsyncValue<void>>(
      EditProfileController.new,
    );

class EditProfileController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  bool get isSaving => state is AsyncLoading;

  AppFailure? get errorOrNull => state is AsyncError
      ? (state as AsyncError).error is AppFailure
          ? (state as AsyncError).error as AppFailure
          : const UnknownFailure('Unable to update the profile.')
      : null;

  Future<bool> save({
    String? phone,
    String? qualification,
    String? gender,
    String? name,
    String? email,
    DateTime? dob,
    String? avatar,
  }) async {
    final accessToken = _readAccessToken(ref);
    state = const AsyncLoading();
    final result = await ref.read(editProfileUseCaseProvider)(
      EditProfileParams(
        accessToken: accessToken,
        phone: phone,
        qualification: qualification,
        gender: gender,
        name: name,
        email: email,
        dob: dob,
        avatar: avatar,
      ),
    );
    state = result.fold((_) {
      ref.invalidate(profileProvider);
      return const AsyncData(null);
    }, (failure) => AsyncError(failure, StackTrace.current));
    return state is AsyncData;
  }
}

// ── Notifications toggle ─────────────────────────────

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, AsyncValue<void>>(
      NotificationsController.new,
    );

class NotificationsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  bool get isSaving => state is AsyncLoading;

  AppFailure? get errorOrNull => state is AsyncError
      ? (state as AsyncError).error is AppFailure
          ? (state as AsyncError).error as AppFailure
          : const UnknownFailure('Unable to update notifications.')
      : null;

  Future<bool> setEnabled(bool enabled) async {
    final accessToken = _readAccessToken(ref);
    state = const AsyncLoading();
    final result = await ref.read(profileRepositoryProvider).updateNotifications(
      accessToken: accessToken,
      enabled: enabled,
    );
    state = result.fold((_) {
      // Refresh the profile so the toggle reflects the server value.
      ref.invalidate(profileProvider);
      return const AsyncData(null);
    }, (failure) => AsyncError(failure, StackTrace.current));
    return state is AsyncData;
  }
}

// ── Avatar upload ────────────────────────────────────

final avatarUploadControllerProvider =
    NotifierProvider<AvatarUploadController, AsyncValue<String?>>(
      AvatarUploadController.new,
    );

class AvatarUploadController extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() => const AsyncData(null);

  bool get isUploading => state is AsyncLoading;

  AppFailure? get errorOrNull => state is AsyncError
      ? (state as AsyncError).error is AppFailure
          ? (state as AsyncError).error as AppFailure
          : const UnknownFailure('Unable to upload the picture.')
      : null;

  /// Uploads [filePath] through the portal and persists it as the profile
  /// avatar through `PUT /profile`. Returns the server avatar URL on success.
  Future<String?> uploadAndSet(String filePath) async {
    final accessToken = _readAccessToken(ref);
    state = const AsyncLoading();
    final upload = await ref.read(profileRepositoryProvider).uploadAvatar(
      accessToken: accessToken,
      filePath: filePath,
    );
    final avatar = upload.fold<String?>(
      (url) => url,
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
    );
    if (avatar == null) return null;

    final save = await ref.read(profileRepositoryProvider).updateProfile(
      accessToken: accessToken,
      update: ProfileUpdate(avatar: avatar),
    );
    state = save.fold(
      (_) {
        ref.invalidate(profileProvider);
        return AsyncData(avatar);
      },
      (failure) => AsyncError(failure, StackTrace.current),
    );
    return state is AsyncData ? state.value : null;
  }
}