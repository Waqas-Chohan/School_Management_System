import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_data_source.dart';

/// Implements [AttendanceRepository] using the configured data source.
/// Swap between mock and remote via the provider (master prompt §10).
class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl(this._dataSource);

  final AttendanceDataSource _dataSource;

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
    return _dataSource.fetchSummary(accessToken, month: month);
  }
}