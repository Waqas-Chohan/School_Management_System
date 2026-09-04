import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/teacher_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_data_source.dart';

/// Implements [ProfileRepository] over the live portal API with a graceful
/// fallback to the mock source when the network is unreachable.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._mockDataSource, this._remoteDataSource);

  final ProfileDataSource _mockDataSource;
  final ProfileDataSource _remoteDataSource;

  @override
  Future<Result<TeacherProfile>> fetchProfile({
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to view your profile.'));
    }
    final remote = await _remoteDataSource.fetchProfile(accessToken);
    if (remote is Success<TeacherProfile>) return remote;
    if (remote is Failure<TeacherProfile> && remote.failure is NetworkFailure) {
      return _mockDataSource.fetchProfile(accessToken);
    }
    return remote;
  }

  @override
  Future<Result<void>> updatePhone({
    required String accessToken,
    required String phone,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to update your profile.'));
    }
    final remote = await _remoteDataSource.updatePhone(accessToken, phone);
    if (remote is Success<void>) return remote;
    if (remote is Failure<void> && remote.failure is NetworkFailure) {
      return _mockDataSource.updatePhone(accessToken, phone);
    }
    return remote;
  }

  @override
  Future<Result<void>> updateProfile({
    required String accessToken,
    required ProfileUpdate update,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to update your profile.'));
    }
    final remote = await _remoteDataSource.updateProfile(accessToken, update);
    if (remote is Success<void>) return remote;
    if (remote is Failure<void> && remote.failure is NetworkFailure) {
      return _mockDataSource.updateProfile(accessToken, update);
    }
    return remote;
  }

  @override
  Future<Result<void>> updateNotifications({
    required String accessToken,
    required bool enabled,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(
        UnauthorizedFailure('Please login to update notifications.'),
      );
    }
    final remote = await _remoteDataSource.updateNotifications(
      accessToken,
      enabled: enabled,
    );
    if (remote is Success<void>) return remote;
    if (remote is Failure<void> && remote.failure is NetworkFailure) {
      return _mockDataSource.updateNotifications(accessToken, enabled: enabled);
    }
    return remote;
  }

  @override
  Future<Result<String>> uploadAvatar({
    required String accessToken,
    required String filePath,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to upload a picture.'));
    }
    final remote = await _remoteDataSource.uploadAvatar(
      accessToken,
      filePath: filePath,
    );
    if (remote is Success<String>) return remote;
    if (remote is Failure<String> && remote.failure is NetworkFailure) {
      return _mockDataSource.uploadAvatar(accessToken, filePath: filePath);
    }
    return remote;
  }
}