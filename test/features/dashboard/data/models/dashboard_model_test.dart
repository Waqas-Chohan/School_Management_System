import 'package:flutter_test/flutter_test.dart';

import 'package:school_management_system/features/dashboard/data/models/dashboard_model.dart';
import 'package:school_management_system/features/dashboard/domain/entities/dashboard.dart';

void main() {
  group('DashboardSummaryModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'greeting': 'Hy, Ms. Sharma',
        'date_label': 'Monday, October 16, 2026',
        'quick_actions': [
          {'id': '1', 'title': 'My Attendance', 'type': 'my_attendance'},
          {'id': '2', 'title': 'Apply For Leave', 'type': 'apply_leave'},
          {'id': '3', 'title': 'View Datesheet', 'type': 'view_datesheet'},
        ],
        'timetable': [
          {
            'subject': 'Mathematics',
            'role': 'subject_teacher',
            'room': 'Room-01',
            'class_name': 'Class 8-A',
            'time_range': '08:00 - 08:45 AM',
          },
        ],
        'class_statuses': [
          {
            'class_name': 'Class 8-A',
            'subject': 'Mathematics',
            'percent': 92,
            'status': 'marked',
          },
        ],
        'upcoming': [
          {'title': 'Independence Day Holiday', 'date': 'Aug 14', 'kind': 'holiday'},
        ],
      };

      final model = DashboardSummaryModel.fromJson(json);
      expect(model.greeting, 'Hy, Ms. Sharma');
      expect(model.quickActions, hasLength(3));
      expect(model.quickActions[1].type, QuickActionType.applyLeave);
      expect(model.timetable, hasLength(1));
      expect(model.timetable[0].role, TimetableRole.subjectTeacher);
      expect(model.classStatuses, hasLength(1));
      expect(model.classStatuses[0].label, '92% Marked');
      expect(model.upcoming, hasLength(1));
      expect(model.upcoming[0].kind, UpcomingEventKind.holiday);
    });

    test('status defaults to not marked when missing', () {
      final model = ClassAttendanceStatusModel.fromJson(
        {'class_name': 'Class 10-C', 'subject': 'Algebra'},
      );
      expect(model.status, AttendanceMarkStatus.notMarked);
      expect(model.label, 'Not Marked');
    });

    test('role defaults to subject teacher for unknown values', () {
      final model = TimetablePeriodModel.fromJson({
        'subject': 'Physics',
        'role': 'guest_teacher',
        'room': 'Room-12',
        'class_name': 'Class 9-B',
        'time_range': '08:50 - 09:35 AM',
      });
      expect(model.role, TimetableRole.subjectTeacher);
    });
  });
}