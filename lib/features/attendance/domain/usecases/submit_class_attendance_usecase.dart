import '../../../../core/result/result.dart';
import '../../domain/entities/class_attendance.dart';
import '../../domain/repositories/class_attendance_repository.dart';

/// Submits the marked attendance for a class and returns the counts shown in
/// the success dialog.
class SubmitClassAttendanceUseCase {
  const SubmitClassAttendanceUseCase(this._repository);

  final ClassAttendanceRepository _repository;

  Future<Result<AttendanceSubmissionResult>> call({
    required String accessToken,
    required String classId,
    required Map<String, StudentAttendanceStatus> statusByStudent,
  }) {
    return _repository.submitAttendance(
      accessToken,
      classId: classId,
      statusByStudent: statusByStudent,
    );
  }
}
