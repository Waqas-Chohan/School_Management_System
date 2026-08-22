import 'package:flutter_test/flutter_test.dart';

import 'package:school_management_system/features/attendance/data/models/attendance_model.dart';
import 'package:school_management_system/features/attendance/domain/entities/attendance.dart';

void main() {
  group('AttendanceSummaryModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'month_label': 'August 2026',
        'percent': 92,
        'headline': 'Excellent Consistency!',
        'subtitle': 'You have maintained the target attendance rate of over 90%.',
        'stats': [
          {'type': 'present', 'label': 'Present', 'count': 24},
          {'type': 'absent', 'label': 'Absent', 'count': 2},
          {'type': 'leave', 'label': 'Leave', 'count': 1},
          {'type': 'late', 'label': 'Late', 'count': 3},
        ],
        'history': [
          {
            'date': 'Mon, 4 Aug 2026',
            'in_time': '08:55 AM',
            'out_time': '04:30 PM',
            'status': 'present',
          },
        ],
      };

      final model = AttendanceSummaryModel.fromJson(json);
      expect(model.monthLabel, 'August 2026');
      expect(model.percent, 92);
      expect(model.headline, 'Excellent Consistency!');
      expect(model.stats, hasLength(4));
      expect(model.stats[1].type, AttendanceStatType.absent);
      expect(model.history, hasLength(1));
      expect(model.history[0].statusLabel, 'Present');
    });

    test('toJson serializes stats and history', () {
      final model = AttendanceSummaryModel(
        monthLabel: 'August 2026',
        percent: 92,
        headline: 'Excellent Consistency!',
        subtitle: 'target rate over 90%.',
        stats: const [
          AttendanceStat(
            type: AttendanceStatType.present,
            label: 'Present',
            count: 24,
          ),
        ],
        history: const [
          AttendanceLogEntry(
            date: 'Mon, 4 Aug 2026',
            inTime: '08:55 AM',
            outTime: '04:30 PM',
            status: AttendanceDayStatus.present,
          ),
        ],
      );
      final json = model.toJson();
      expect(json['month_label'], 'August 2026');
      expect(json['percent'], 92);
      expect((json['stats'] as List).first['type'], 'present');
      expect((json['history'] as List).first['status'], 'present');
    });
  });
}