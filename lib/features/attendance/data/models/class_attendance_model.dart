import '../../domain/entities/class_attendance.dart';

/// Serializable model for [TeacherClass].
class TeacherClassModel extends TeacherClass {
  const TeacherClassModel({
    required super.id,
    required super.name,
    required super.grade,
    required super.studentCount,
    super.attendanceSubmitted = false,
  });

  factory TeacherClassModel.fromJson(Map<String, dynamic> json) {
    return TeacherClassModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      studentCount: int.tryParse(json['student_count']?.toString() ?? '0') ?? 0,
      attendanceSubmitted:
          json['attendance_submitted'] == true ||
          json['attendance_submitted']?.toString() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'grade': grade,
    'student_count': studentCount,
    'attendance_submitted': attendanceSubmitted,
  };
}

/// Serializable model for [Student].
class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    required super.rollNo,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      rollNo: json['roll_no']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'roll_no': rollNo};
}

/// Serializable model for [ClassAttendance].
class ClassAttendanceModel extends ClassAttendance {
  const ClassAttendanceModel({
    required super.teacherClass,
    required super.students,
    super.savedStatuses = const {},
  });

  factory ClassAttendanceModel.fromJson(Map<String, dynamic> json) {
    final rawStatuses =
        json['saved_statuses'] as Map? ?? const <String, dynamic>{};
    final savedStatuses = rawStatuses.map((key, value) {
      final status = StudentAttendanceStatus.values.firstWhere(
        (s) => s.name == value?.toString(),
        orElse: () => StudentAttendanceStatus.present,
      );
      return MapEntry(key.toString(), status);
    });
    return ClassAttendanceModel(
      teacherClass: (json['teacher_class'] as Map? ?? const <String, dynamic>{})
          .cast<String, dynamic>()
          .let((m) => TeacherClassModel.fromJson(m)),
      students: (json['students'] as List? ?? const <dynamic>[])
          .map((e) => StudentModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      savedStatuses: savedStatuses,
    );
  }

  Map<String, dynamic> toJson() => {
    'teacher_class': (teacherClass as TeacherClassModel).toJson(),
    'students': students.map((s) => (s as StudentModel).toJson()).toList(),
    'saved_statuses': savedStatuses.map(
      (key, value) => MapEntry(key, value.name),
    ),
  };
}

/// Serializable model for [AttendanceSubmissionResult].
class AttendanceSubmissionResultModel extends AttendanceSubmissionResult {
  const AttendanceSubmissionResultModel({
    required super.present,
    required super.absent,
    required super.leave,
    required super.late,
  });

  factory AttendanceSubmissionResultModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSubmissionResultModel(
      present: int.tryParse(json['present']?.toString() ?? '0') ?? 0,
      absent: int.tryParse(json['absent']?.toString() ?? '0') ?? 0,
      leave: int.tryParse(json['leave']?.toString() ?? '0') ?? 0,
      late: int.tryParse(json['late']?.toString() ?? '0') ?? 0,
    );
  }
}

extension<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
