import 'package:flutter_test/flutter_test.dart';

import 'package:school_management_system/features/attendance/data/models/class_attendance_model.dart';
import 'package:school_management_system/features/attendance/domain/entities/class_attendance.dart';

void main() {
  group('TeacherClassModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'class-b',
        'name': 'Class B',
        'grade': 'Grade 6',
        'student_count': 28,
      };

      final model = TeacherClassModel.fromJson(json);
      expect(model.id, 'class-b');
      expect(model.name, 'Class B');
      expect(model.grade, 'Grade 6');
      expect(model.studentCount, 28);
      expect(model.displayName, 'Class B - Grade 6');
      expect(model.bulletName, 'Class B • Grade 6');
    });

    test('toJson serializes fields', () {
      const model = TeacherClassModel(
        id: 'class-a',
        name: 'Class A',
        grade: 'Grade 5',
        studentCount: 32,
        attendanceSubmitted: true,
      );
      final json = model.toJson();
      expect(json['id'], 'class-a');
      expect(json['name'], 'Class A');
      expect(json['grade'], 'Grade 5');
      expect(json['student_count'], 32);
      expect(json['attendance_submitted'], isTrue);
    });
  });

  group('StudentModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'class-b-s01',
        'name': 'Aarav Kumar',
        'roll_no': 'Roll No. 01',
      };

      final model = StudentModel.fromJson(json);
      expect(model.id, 'class-b-s01');
      expect(model.name, 'Aarav Kumar');
      expect(model.rollNo, 'Roll No. 01');
    });

    test('equality is based on id', () {
      const a = Student(id: 's1', name: 'Aarav Kumar', rollNo: 'Roll No. 01');
      const b = Student(
        id: 's1',
        name: 'Different Name',
        rollNo: 'Roll No. 02',
      );
      const c = Student(id: 's2', name: 'Aarav Kumar', rollNo: 'Roll No. 01');
      expect(a == b, isTrue, reason: 'same id should be equal');
      expect(a == c, isFalse, reason: 'different id should not be equal');
    });
  });

  group('ClassAttendanceModel', () {
    test('fromJson parses teacher class and students', () {
      final json = {
        'teacher_class': {
          'id': 'class-b',
          'name': 'Class B',
          'grade': 'Grade 6',
          'student_count': 28,
        },
        'students': [
          {'id': 's1', 'name': 'Aarav Kumar', 'roll_no': 'Roll No. 01'},
          {'id': 's2', 'name': 'Isha Kapoor', 'roll_no': 'Roll No. 02'},
        ],
      };

      final model = ClassAttendanceModel.fromJson(json);
      expect(model.teacherClass.bulletName, 'Class B • Grade 6');
      expect(model.students, hasLength(2));
      expect(model.students[1].name, 'Isha Kapoor');
      expect(model.savedStatuses, isEmpty);
    });

    test('fromJson parses saved_statuses into statuses', () {
      final json = {
        'teacher_class': {
          'id': 'class-b',
          'name': 'Class B',
          'grade': 'Grade 6',
          'student_count': 28,
        },
        'students': [
          {'id': 's1', 'name': 'Aarav Kumar', 'roll_no': 'Roll No. 01'},
          {'id': 's2', 'name': 'Isha Kapoor', 'roll_no': 'Roll No. 02'},
        ],
        'saved_statuses': {'s1': 'present', 's2': 'absent'},
      };

      final model = ClassAttendanceModel.fromJson(json);
      expect(model.savedStatuses['s1'], StudentAttendanceStatus.present);
      expect(model.savedStatuses['s2'], StudentAttendanceStatus.absent);
      expect(model.savedStatuses, hasLength(2));
    });
  });

  group('AttendanceSubmissionResultModel', () {
    test('fromJson parses counts', () {
      final json = {'present': 20, 'absent': 4, 'leave': 2, 'late': 2};
      final model = AttendanceSubmissionResultModel.fromJson(json);
      expect(model.present, 20);
      expect(model.absent, 4);
      expect(model.leave, 2);
      expect(model.late, 2);
      expect(model.total, 28);
    });
  });
}
