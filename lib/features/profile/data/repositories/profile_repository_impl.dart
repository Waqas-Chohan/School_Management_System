import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/teacher_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_data_source.dart';

/// Implements [ProfileRepository] using the configured data source.

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._dataSource);

  final ProfileDataSource _dataSource;

  @override
  Future<Result<TeacherProfile>> fetchProfile({
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to view your profile.'));
    }
    return _dataSource.fetchProfile(accessToken);
  }

  @override
  Future<Result<void>> updatePhone({
    required String accessToken,
    required String phone,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to update your profile.'));
    }
    return _dataSource.updatePhone(accessToken, phone);
  }
}