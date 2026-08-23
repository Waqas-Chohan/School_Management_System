import '../../../../core/result/result.dart';
import '../../domain/entities/class_attendance.dart';

/// Repository for the Class Attendance flow (My Classes list, Mark Attendance
/// and the Attendance Details / edit screen).
abstract class ClassAttendanceRepository {
  Future<Result<List<TeacherClass>>> getClasses(String accessToken);

  Future<Result<ClassAttendance>> getClassAttendance(
    String accessToken,
    String classId,
  );

  Future<Result<ClassAttendance>> getSavedAttendance(
    String accessToken,
    String classId,
  );

  Future<Result<AttendanceSubmissionResult>> submitAttendance(
    String accessToken, {
    required String classId,
    required Map<String, StudentAttendanceStatus> statusByStudent,
  });
}
