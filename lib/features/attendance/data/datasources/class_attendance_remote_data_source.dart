import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/class_attendance.dart';
import '../models/class_attendance_model.dart';
import 'class_attendance_data_source.dart';

/// Remote class-attendance data source backed by the SMS portal:
/// - `GET  /teacher-portal/classes`
/// - `GET  /teacher-portal/attendance/students?classId=&sectionId=&date=`
/// - `POST /teacher-portal/attendance/mark`
///
/// The dashboard's `classId` (e.g. `B1-C12`) differs from the assignment `id`
/// (e.g. `B1-C12-TA7`) used across the app, so every classified call first
/// resolves the canonical `classId` / `sectionId` from the classes list.
class ClassAttendanceRemoteDataSourceImpl implements ClassAttendanceDataSource {
  ClassAttendanceRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Options _auth(String accessToken) =>
      Options(headers: {'Authorization': 'Bearer $accessToken'});

  String get _today => _dateFormat.format(DateTime.now());

  @override
  Future<Result<List<TeacherClass>>> fetchClasses(String accessToken) async {
    return guardApi(() async {
      // Use `get<dynamic>`: the body is the envelope Map, not a raw list,
      // and Dio's typed `get<List<T>>` would throw a cast DioException.
      final response = await dio.get<dynamic>(
        ApiEndpoints.classes,
        options: _auth(accessToken),
      );
      final classes = envelopeList(response.data)
          .map(
            (e) =>
                TeacherClassModel.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList();

      // A class counts as "already submitted" when the classes endpoint's own
      // per-class flag says so, OR the dashboard's `classAttendanceRecords`
      // says so. Previously the per-class `isMarkedToday` (already parsed by
      // TeacherClassModel.fromJson) was thrown away and the card relied solely
      // on the dashboard aggregation, which can lag behind a successful POST.
      final markedIds = await _fetchMarkedAssignmentIds(accessToken);
      return classes
          .map(
            (c) => TeacherClassModel(
              id: c.id,
              classId: c.classId,
              sectionId: c.sectionId,
              name: c.name,
              grade: c.grade,
              studentCount: c.studentCount,
              attendanceSubmitted:
                  c.attendanceSubmitted || markedIds.contains(c.id),
            ),
          )
          .toList();
    });
  }

  Future<Set<String>> _fetchMarkedAssignmentIds(String accessToken) async {
    try {
      final response = await dio.get<dynamic>(
        ApiEndpoints.dashboardSummary,
        options: _auth(accessToken),
      );
      final payload = envelopeMap(response.data);
      final records =
          payload['classAttendanceRecords'] as List? ?? const <dynamic>[];
      final marked = <String>{};
      for (final record in records) {
        final map = (record as Map).cast<String, dynamic>();
        if (map['isMarkedToday'] == true) {
          final id = map['assignmentId']?.toString() ?? '';
          if (id.isNotEmpty) marked.add(id);
        }
      }
      return marked;
    } catch (_) {
      return const {};
    }
  }

  @override
  Future<Result<ClassAttendance>> fetchClassAttendance(
    String accessToken,
    String classId,
  ) {
    return _fetchAttendance(accessToken, classId);
  }

  @override
  Future<Result<ClassAttendance>> fetchSavedAttendance(
    String accessToken,
    String classId,
  ) {
    return _fetchAttendance(accessToken, classId);
  }

  Future<Result<ClassAttendance>> _fetchAttendance(
    String accessToken,
    String assignmentId,
  ) {
    return guardApi(() async {
      final resolved = await _resolveClass(accessToken, assignmentId);
      final query = <String, dynamic>{
        'classId': resolved.classId.isEmpty ? assignmentId : resolved.classId,
        'sectionId': resolved.sectionId,
        'date': _today,
      };
      final response = await dio.get<Map<String, dynamic>>(
        ApiEndpoints.attendanceStudents,
        queryParameters: query,
        options: _auth(accessToken),
      );
      final payload = envelopeMap(response.data);
      final model = ClassAttendanceModel.fromJson(payload);
      return ClassAttendance(
        teacherClass: TeacherClass(
          id: resolved.id.isEmpty ? assignmentId : resolved.id,
          classId: resolved.classId,
          sectionId: resolved.sectionId,
          name: resolved.name.isNotEmpty
              ? resolved.name
              : model.teacherClass.name,
          grade: resolved.grade.isNotEmpty
              ? resolved.grade
              : model.teacherClass.grade,
          studentCount: model.students.length,
        ),
        students: model.students,
        savedStatuses: model.savedStatuses,
      );
    });
  }

  @override
  Future<Result<AttendanceSubmissionResult>> submitAttendance(
    String accessToken, {
    required String classId,
    required Map<String, StudentAttendanceStatus> statusByStudent,
  }) {
    return guardApi(() async {
      final resolved = await _resolveClass(accessToken, classId);
      const serverStatus = {
        StudentAttendanceStatus.present: 'Present',
        StudentAttendanceStatus.absent: 'Absent',
        StudentAttendanceStatus.leave: 'Leave',
        StudentAttendanceStatus.late: 'Late',
      };
      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.markAttendance,
        data: {
          'classId': resolved.classId.isEmpty ? classId : resolved.classId,
          'sectionId': resolved.sectionId,
          'date': _today,
          'records': statusByStudent.entries.map((entry) {
            return {
              'studentId': entry.key,
              'status': serverStatus[entry.value] ?? 'Present',
              'remark': '',
            };
          }).toList(),
        },
        options: _auth(accessToken),
      );
      return AttendanceSubmissionResultModel.fromSavedRecords(
        envelopeList(response.data),
      );
    });
  }

  /// Finds the assignment (by assignment `id`) in the classes list so the
  /// canonical `classId` / `sectionId` are available for sub-calls.
  Future<TeacherClass> _resolveClass(String accessToken, String id) async {
    final response = await dio.get<dynamic>(
      ApiEndpoints.classes,
      options: _auth(accessToken),
    );
    final classes = envelopeList(response.data)
        .map(
          (e) => TeacherClassModel.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList();
    return classes.firstWhere(
      (c) => c.id == id,
      orElse: () => TeacherClassModel(
        id: id,
        classId: id,
        sectionId: '',
        name: '',
        grade: '',
        studentCount: 0,
      ),
    );
  }
}
