import '../../../../core/result/result.dart';
import '../../domain/entities/class_attendance.dart';
import '../../domain/repositories/class_attendance_repository.dart';

/// Fetches the teacher's classes for the "My Classes" screen.
class GetClassesUseCase {
  const GetClassesUseCase(this._repository);

  final ClassAttendanceRepository _repository;

  Future<Result<List<TeacherClass>>> call(String accessToken) {
    return _repository.getClasses(accessToken);
  }
}
