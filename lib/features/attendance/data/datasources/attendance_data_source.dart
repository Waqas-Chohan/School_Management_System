import '../../../../core/result/result.dart';
import '../../domain/entities/attendance.dart';

/// Common contract implemented by the mock and remote attendance sources.
abstract class AttendanceDataSource {
  Future<Result<AttendanceSummary>> fetchSummary(
    String accessToken, {
    String? month,
  });
}
