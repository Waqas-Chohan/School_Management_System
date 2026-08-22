import 'package:flutter_test/flutter_test.dart';

import 'package:school_management_system/features/leave/data/models/leave_model.dart';
import 'package:school_management_system/features/leave/domain/entities/leave.dart';

void main() {
  group('LeaveModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': '1',
        'type': 'sick',
        'mode': 'multiple',
        'start_date': '2026-06-12T00:00:00.000',
        'end_date': '2026-06-13T00:00:00.000',
        'reason': 'Viral fever, doctor advised complete rest.',
        'status': 'approved',
      };
      final model = LeaveModel.fromJson(json);
      expect(model.id, '1');
      expect(model.type, LeaveType.sick);
      expect(model.mode, LeaveMode.multiple);
      expect(model.days, 2);
      expect(model.daysLabel, '2 Days');
      expect(model.status, LeaveStatus.approved);
      expect(model.statusLabel, 'Approved');
    });

    test('toJson serializes correctly', () {
      final model = LeaveModel(
        id: '3',
        type: LeaveType.casual,
        mode: LeaveMode.single,
        startDate: DateTime(2026, 5, 28),
        endDate: DateTime(2026, 5, 28),
        reason: 'Personal family emergency, need a day off.',
        status: LeaveStatus.approved,
      );
      final json = model.toJson();
      expect(json['type'], 'casual');
      expect(json['mode'], 'single');
      expect(json['status'], 'approved');
      expect(json['reason'], 'Personal family emergency, need a day off.');
    });

    test('unknown type defaults to sick, unknown status to pending', () {
      final model = LeaveModel.fromJson({
        'id': '9',
        'type': 'unknown',
        'mode': 'single',
        'start_date': '2026-05-28T00:00:00.000',
        'end_date': '2026-05-28T00:00:00.000',
        'reason': '',
        'status': 'unknown',
      });
      expect(model.type, LeaveType.sick);
      expect(model.status, LeaveStatus.pending);
    });

    test('labels', () {
      expect(LeaveStatus.pending.label, 'Pending');
      expect(LeaveStatus.approved.label, 'Approved');
      expect(LeaveStatus.cancelled.label, 'Cancelled');
    });
  });
}