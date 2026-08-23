import '../../../../core/result/result.dart';
import '../../domain/entities/class_attendance.dart';
import '../../domain/repositories/class_attendance_repository.dart';

/// Fetches an already-saved attendance sheet for a class (the Attendance
/// Details / edit screen).
class GetSavedAttendanceUseCase {
  const GetSavedAttendanceUseCase(this._repository);

  final ClassAttendanceRepository _repository;

  Future<Result<ClassAttendance>> call(String accessToken, String classId) {
    return _repository.getSavedAttendance(accessToken, classId);
  }
}
