import '../../../../core/result/result.dart';
import '../entities/attendance.dart';

/// Contract implemented by the data layer.
abstract class AttendanceRepository {
  Future<Result<AttendanceSummary>> fetchSummary({
    required String accessToken,
    String? month,
  });

  /// Records a self check-in for today and returns the saved row.
  Future<Result<CheckInOutResult>> checkIn({required String accessToken});

  /// Records a self check-out for today and returns the saved row.
  Future<Result<CheckInOutResult>> checkOut({required String accessToken});
}
