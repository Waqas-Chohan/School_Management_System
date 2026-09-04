import '../../domain/entities/class_attendance.dart';

/// Serializable model for [TeacherClass].
class TeacherClassModel extends TeacherClass {
  const TeacherClassModel({
    required super.id,
    required super.name,
    required super.grade,
    required super.studentCount,
    super.attendanceSubmitted = false,
    super.classId = '',
    super.sectionId = '',
  });

  /// Maps a `/teacher-portal/classes` entry. The assignment `id` doubles as
  /// the class key used across the app; `classId` + `sectionId` are kept for
  /// the roster / mark endpoints.
  factory TeacherClassModel.fromJson(Map<String, dynamic> json) {
    final level = json['level']?.toString() ?? '';
    final section = json['sectionName']?.toString() ?? '';
    final subject = json['subjectName']?.toString() ?? '';
    final gradeParts = [section, subject].where((p) => p.isNotEmpty).join(' • ');
    return TeacherClassModel(
      id: json['id']?.toString() ?? '',
      classId: json['classId']?.toString() ?? '',
      sectionId: json['sectionId']?.toString() ?? '',
      name: json['className']?.toString() ?? '',
      grade: gradeParts.isEmpty ? 'Level $level' : gradeParts,
      studentCount: int.tryParse(json['studentCount']?.toString() ?? '0') ?? 0,
      attendanceSubmitted: json['isMarkedToday'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'classId': classId,
    'sectionId': sectionId,
    'className': name,
    'grade': grade,
    'studentCount': studentCount,
    'attendanceSubmitted': attendanceSubmitted,
  };
}

/// Serializable model for [Student].
class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.name,
    required super.rollNo,
    this.status = StudentAttendanceStatus.present,
  });

  /// The student's existing / default attendance status from the roster.
  final StudentAttendanceStatus status;

  /// Maps a `/attendance/students` entry. `rollNo` is stored as a display
  /// label ("Roll No. 32") matching the existing roster UI.
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final roll = json['rollNo']?.toString() ?? '';
    return StudentModel(
      id: json['studentId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      rollNo: roll.isEmpty ? '' : 'Roll No. $roll',
      status: _statusFromServer(json['status']?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'studentId': id,
    'rollNo': rollNo,
    'name': name,
  };
}

/// Serializable model for [ClassAttendance].
class ClassAttendanceModel extends ClassAttendance {
  const ClassAttendanceModel({
    required super.teacherClass,
    required super.students,
    super.savedStatuses = const {},
  });

  /// Parses the `/attendance/students` payload:
  /// `{ summary: { isMarked, ... }, students: [...] }`. When the sheet has
  /// already been submitted the roster statuses become the saved statuses.
  factory ClassAttendanceModel.fromJson(Map<String, dynamic> json) {
    final summary =
        (json['summary'] as Map? ?? const <String, dynamic>{})
            .cast<String, dynamic>();
    final isMarked = summary['isMarked'] == true;
    final students = (json['students'] as List? ?? const <dynamic>[])
        .map((e) => StudentModel.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    final savedStatuses = <String, StudentAttendanceStatus>{};
    if (isMarked) {
      for (final student in students.cast<StudentModel>()) {
        savedStatuses[student.id] = student.status;
      }
    }

    return ClassAttendanceModel(
      teacherClass: TeacherClass(
        id: '',
        name: summary['className']?.toString() ??
            summary['class_name']?.toString() ??
            '',
        grade: summary['sectionName']?.toString() ??
            summary['section_name']?.toString() ??
            '',
        studentCount: students.length,
      ),
      students: students,
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

  /// Counts the saved records returned by `/attendance/mark`:
  /// `data: [{ status: "Present" | "Absent" | "Leave" | "Late", ... }]`.
  factory AttendanceSubmissionResultModel.fromSavedRecords(
    List<dynamic> records,
  ) {
    var present = 0, absent = 0, leave = 0, late = 0;
    for (final record in records) {
      final map = (record as Map).cast<String, dynamic>();
      switch (_statusFromServer(map['status']?.toString())) {
        case StudentAttendanceStatus.present:
          present++;
        case StudentAttendanceStatus.absent:
          absent++;
        case StudentAttendanceStatus.leave:
          leave++;
        case StudentAttendanceStatus.late:
          late++;
      }
    }
    return AttendanceSubmissionResultModel(
      present: present,
      absent: absent,
      leave: leave,
      late: late,
    );
  }

  factory AttendanceSubmissionResultModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSubmissionResultModel(
      present: int.tryParse(json['present']?.toString() ?? '0') ?? 0,
      absent: int.tryParse(json['absent']?.toString() ?? '0') ?? 0,
      leave: int.tryParse(json['leave']?.toString() ?? '0') ?? 0,
      late: int.tryParse(json['late']?.toString() ?? '0') ?? 0,
    );
  }
}

// Maps the server's capitalised status strings to the entity enum.
StudentAttendanceStatus _statusFromServer(String? value) {
  return switch (value?.toLowerCase()) {
    'absent' => StudentAttendanceStatus.absent,
    'leave' => StudentAttendanceStatus.leave,
    'late' => StudentAttendanceStatus.late,
    _ => StudentAttendanceStatus.present,
  };
}
