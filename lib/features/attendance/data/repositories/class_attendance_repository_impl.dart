import '../../../../core/result/result.dart';
import '../../../attendance/data/datasources/class_attendance_data_source.dart';
import '../../domain/entities/class_attendance.dart';
import '../../domain/repositories/class_attendance_repository.dart';

/// Concrete [ClassAttendanceRepository] delegating to a [ClassAttendanceDataSource].
class ClassAttendanceRepositoryImpl implements ClassAttendanceRepository {
  ClassAttendanceRepositoryImpl(this._dataSource);

  final ClassAttendanceDataSource _dataSource;

  @override
  Future<Result<List<TeacherClass>>> getClasses(String accessToken) {
    return _dataSource.fetchClasses(accessToken);
  }

  @override
  Future<Result<ClassAttendance>> getClassAttendance(
    String accessToken,
    String classId,
  ) {
    return _dataSource.fetchClassAttendance(accessToken, classId);
  }

  @override
  Future<Result<ClassAttendance>> getSavedAttendance(
    String accessToken,
    String classId,
  ) {
    return _dataSource.fetchSavedAttendance(accessToken, classId);
  }

  @override
  Future<Result<AttendanceSubmissionResult>> submitAttendance(
    String accessToken, {
    required String classId,
    required Map<String, StudentAttendanceStatus> statusByStudent,
  }) {
    return _dataSource.submitAttendance(
      accessToken,
      classId: classId,
      statusByStudent: statusByStudent,
    );
  }
}
