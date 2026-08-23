/// Attendance status a student can be marked with in a class session
/// (matches the P / A / L / LA radio buttons in the Figma "Mark Attendance"
/// variation-01 design).
enum StudentAttendanceStatus { present, absent, leave, late }

/// A school class assigned to the teacher, shown on the "My Classes" screen
/// (Figma frame 65:7154).
class TeacherClass {
  const TeacherClass({
    required this.id,
    required this.name,
    required this.grade,
    required this.studentCount,
    this.attendanceSubmitted = false,
  });

  final String id;
  final String name; // e.g. "Class A"
  final String grade; // e.g. "Grade 5"
  final int studentCount;

  /// Whether attendance for this class has already been submitted. Drives the
  /// "Mark" (green) vs "View" (purple) pill on the My Classes card.
  final bool attendanceSubmitted;

  /// "Class A - Grade 5" used on the class list cards.
  String get displayName => '$name - $grade';

  /// "Class B • Grade 6" used on the Mark Attendance subtitle.
  String get bulletName => '$name • $grade';
}

/// A single student in a class roster shown on the Mark Attendance screen.
class Student {
  const Student({required this.id, required this.name, required this.rollNo});

  final String id;
  final String name;
  final String rollNo; // e.g. "Roll No. 01"

  @override
  bool operator ==(Object other) => other is Student && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// The roster of a class plus its display metadata.
class ClassAttendance {
  const ClassAttendance({
    required this.teacherClass,
    required this.students,
    this.savedStatuses = const {},
  });

  final TeacherClass teacherClass;
  final List<Student> students;

  /// Student-id → status for attendance that was already saved for this class.
  /// Empty for a brand-new (not yet submitted) roster.
  final Map<String, StudentAttendanceStatus> savedStatuses;
}

/// Aggregated counts shown in the success dialog after submission.
class AttendanceSubmissionResult {
  const AttendanceSubmissionResult({
    required this.present,
    required this.absent,
    required this.leave,
    required this.late,
  });

  final int present;
  final int absent;
  final int leave;
  final int late;

  int get total => present + absent + leave + late;
}
