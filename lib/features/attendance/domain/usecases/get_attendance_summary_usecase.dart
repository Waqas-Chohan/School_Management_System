import '../../../../core/result/result.dart';
import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceSummaryParams {
  const GetAttendanceSummaryParams({required this.accessToken, this.month});
  final String accessToken;
  final String? month;
}

class GetAttendanceSummaryUseCase {
  const GetAttendanceSummaryUseCase(this._repository);
  final AttendanceRepository _repository;

  Future<Result<AttendanceSummary>> call(GetAttendanceSummaryParams params) {
    return _repository.fetchSummary(
      accessToken: params.accessToken,
      month: params.month,
    );
  }
}