import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../attendance/data/datasources/class_attendance_data_source.dart';
import '../../domain/entities/class_attendance.dart';
import '../../domain/repositories/class_attendance_repository.dart';

/// Concrete [ClassAttendanceRepository] delegating to the configured data
/// sources. Uses the live portal API with a graceful fallback to the mock
/// source when the network is unreachable.
class ClassAttendanceRepositoryImpl implements ClassAttendanceRepository {
  ClassAttendanceRepositoryImpl(this._mockDataSource, this._remoteDataSource);

  final ClassAttendanceDataSource _mockDataSource;
  final ClassAttendanceDataSource _remoteDataSource;

  @override
  Future<Result<List<TeacherClass>>> getClasses(String accessToken) {
    return _withFallback(
      () => _remoteDataSource.fetchClasses(accessToken),
      () => _mockDataSource.fetchClasses(accessToken),
    );
  }

  @override
  Future<Result<ClassAttendance>> getClassAttendance(
    String accessToken,
    String classId,
  ) {
    return _withFallback(
      () => _remoteDataSource.fetchClassAttendance(accessToken, classId),
      () => _mockDataSource.fetchClassAttendance(accessToken, classId),
    );
  }

  @override
  Future<Result<ClassAttendance>> getSavedAttendance(
    String accessToken,
    String classId,
  ) {
    return _withFallback(
      () => _remoteDataSource.fetchSavedAttendance(accessToken, classId),
      () => _mockDataSource.fetchSavedAttendance(accessToken, classId),
    );
  }

  @override
  Future<Result<AttendanceSubmissionResult>> submitAttendance(
    String accessToken, {
    required String classId,
    required Map<String, StudentAttendanceStatus> statusByStudent,
  }) {
    return _withFallback(
      () => _remoteDataSource.submitAttendance(
        accessToken,
        classId: classId,
        statusByStudent: statusByStudent,
      ),
      () => _mockDataSource.submitAttendance(
        accessToken,
        classId: classId,
        statusByStudent: statusByStudent,
      ),
    );
  }

  /// Runs the remote call; when it fails with a [NetworkFailure] (offline /
  /// demo mode) it transparently falls back to the mock data source.
  Future<Result<T>> _withFallback<T>(
    Future<Result<T>> Function() remote,
    Future<Result<T>> Function() mock,
  ) async {
    final result = await remote();
    if (result is Failure<T> && result.failure is NetworkFailure) {
      return mock();
    }
    return result;
  }
}
