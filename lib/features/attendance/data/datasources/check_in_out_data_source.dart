import '../../../../core/result/result.dart';
import '../../domain/entities/attendance.dart';

/// Contract implemented by the mock and remote check-in / check-out sources.
abstract class CheckInOutDataSource {
  Future<Result<CheckInOutResult>> checkIn(String accessToken);
  Future<Result<CheckInOutResult>> checkOut(String accessToken);
}