import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_data_source.dart';
import '../datasources/check_in_out_data_source.dart';

/// Implements [AttendanceRepository] over the live portal API with a graceful
/// fallback to the mock source when the network is unreachable.
class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl(
    this._mockDataSource,
    this._remoteDataSource,
    this._checkInOutMock,
    this._checkInOutRemote,
  );

  final AttendanceDataSource _mockDataSource;
  final AttendanceDataSource _remoteDataSource;
  final CheckInOutDataSource _checkInOutMock;
  final CheckInOutDataSource _checkInOutRemote;

  @override
  Future<Result<AttendanceSummary>> fetchSummary({
    required String accessToken,
    String? month,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(
        UnauthorizedFailure('Please login to view attendance.'),
      );
    }
    final remote = await _remoteDataSource.fetchSummary(accessToken, month: month);
    if (remote is Success<AttendanceSummary>) return remote;
    if (remote is Failure<AttendanceSummary> && remote.failure is NetworkFailure) {
      return _mockDataSource.fetchSummary(accessToken, month: month);
    }
    return remote;
  }

  @override
  Future<Result<CheckInOutResult>> checkIn({required String accessToken}) {
    if (accessToken.isEmpty) {
      return Future.value(
        Failure<CheckInOutResult>(
          const UnauthorizedFailure('Please login to check in.'),
        ),
      );
    }
    return _withFallback(
      () => _checkInOutRemote.checkIn(accessToken),
      () => _checkInOutMock.checkIn(accessToken),
    );
  }

  @override
  Future<Result<CheckInOutResult>> checkOut({required String accessToken}) {
    if (accessToken.isEmpty) {
      return Future.value(
        Failure<CheckInOutResult>(
          const UnauthorizedFailure('Please login to check out.'),
        ),
      );
    }
    return _withFallback(
      () => _checkInOutRemote.checkOut(accessToken),
      () => _checkInOutMock.checkOut(accessToken),
    );
  }

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
