import '../../../../core/result/result.dart';
import '../../domain/entities/class_attendance.dart';

/// Common contract implemented by the mock and remote class-attendance sources.
abstract class ClassAttendanceDataSource {
  /// Returns the teacher's list of classes (the "My Classes" screen).
  Future<Result<List<TeacherClass>>> fetchClasses(String accessToken);

  /// Returns the roster for a single class (the Mark Attendance screen).
  Future<Result<ClassAttendance>> fetchClassAttendance(
    String accessToken,
    String classId,
  );

  /// Returns an already-saved attendance sheet for a class (the
  /// Attendance Details / edit screen).
  Future<Result<ClassAttendance>> fetchSavedAttendance(
    String accessToken,
    String classId,
  );

  /// Persists the marked attendance and returns the submitted counts.
  Future<Result<AttendanceSubmissionResult>> submitAttendance(
    String accessToken, {
    required String classId,
    required Map<String, StudentAttendanceStatus> statusByStudent,
  });
}
