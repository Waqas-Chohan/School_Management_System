import '../../../../core/result/result.dart';
import '../entities/attendance.dart';

/// Contract implemented by the data layer.
abstract class AttendanceRepository {
  Future<Result<AttendanceSummary>> fetchSummary({
    required String accessToken,
    String? month,
  });
}
