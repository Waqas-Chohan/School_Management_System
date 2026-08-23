import '../../../../core/result/result.dart';
import '../../domain/entities/class_attendance.dart';
import 'class_attendance_data_source.dart';

/// Mock class-attendance data matching the Figma "Class Attendance" designs
/// (frames 65:7156 "My Classes" and 65:5984 "Mark Attendance" variation-1).
class ClassAttendanceMockDataSourceImpl implements ClassAttendanceDataSource {
  ClassAttendanceMockDataSourceImpl();

  /// In-memory persistence: classId → studentId → saved status.
  final Map<String, Map<String, StudentAttendanceStatus>> _savedByClass = {};

  @override
  Future<Result<List<TeacherClass>>> fetchClasses(String accessToken) async {
    await _latency();
    final classes = _classes.map((cls) {
      return TeacherClass(
        id: cls.id,
        name: cls.name,
        grade: cls.grade,
        studentCount: cls.studentCount,
        attendanceSubmitted: _savedByClass.containsKey(cls.id),
      );
    }).toList();
    return Success(classes);
  }

  @override
  Future<Result<ClassAttendance>> fetchClassAttendance(
    String accessToken,
    String classId,
  ) async {
    await _latency();
    final cls = _classes.firstWhere(
      (c) => c.id == classId,
      orElse: () => _classes.first,
    );
    return Success(
      ClassAttendance(
        teacherClass: cls,
        students: _rosterFor(cls),
        savedStatuses: _savedByClass[classId] ?? const {},
      ),
    );
  }

  @override
  Future<Result<ClassAttendance>> fetchSavedAttendance(
    String accessToken,
    String classId,
  ) async {
    await _latency();
    final cls = _classes.firstWhere(
      (c) => c.id == classId,
      orElse: () => _classes.first,
    );
    return Success(
      ClassAttendance(
        teacherClass: cls,
        students: _rosterFor(cls),
        savedStatuses: _savedByClass[classId] ?? const {},
      ),
    );
  }

  @override
  Future<Result<AttendanceSubmissionResult>> submitAttendance(
    String accessToken, {
    required String classId,
    required Map<String, StudentAttendanceStatus> statusByStudent,
  }) async {
    await _latency();
    var present = 0, absent = 0, leave = 0, late = 0;
    for (final status in statusByStudent.values) {
      switch (status) {
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
    final submitted = AttendanceSubmissionResult(
      present: present,
      absent: absent,
      leave: leave,
      late: late,
    );
    _savedByClass[classId] = statusByStudent;
    return Success(submitted);
  }

  static const List<TeacherClass> _classes = [
    TeacherClass(
      id: 'class-a',
      name: 'Class A',
      grade: 'Grade 5',
      studentCount: 32,
    ),
    TeacherClass(
      id: 'class-b',
      name: 'Class B',
      grade: 'Grade 6',
      studentCount: 28,
    ),
    TeacherClass(
      id: 'class-c',
      name: 'Class C',
      grade: 'Grade 7',
      studentCount: 36,
    ),
    TeacherClass(
      id: 'class-d',
      name: 'Class D',
      grade: 'Grade 8',
      studentCount: 42,
    ),
  ];

  /// Builds a roster for the given class. The displayed names/roll numbers come
  /// from the Figma Mark Attendance screen (students 01-12 for class B).
  List<Student> _rosterFor(TeacherClass cls) {
    const baseNames = [
      'Aarav Kumar',
      'Isha Kapoor',
      'Rohan Mehta',
      'Priya Singh',
      'Kabir Malhotra',
      'Ananya Iyer',
      'Dev Patel',
      'Siddharth Joshi',
      'Meera Patel',
      'Arjun Rao',
      'Sneha Kulkarni',
      'Vikram Singh',
    ];
    final count = cls.id == 'class-b' ? 28 : cls.studentCount;
    return List.generate(count, (i) {
      // Cycle through the designed names so rolls stay short & readable.
      final name = baseNames[i % baseNames.length];
      return Student(
        id: '${cls.id}-s${i + 1}',
        name: name,
        rollNo: 'Roll No. ${(i + 1).toString().padLeft(2, '0')}',
      );
    });
  }

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 400));
}
