import 'package:flutter_test/flutter_test.dart';

import 'package:school_management_system/features/auth/data/models/auth_session_model.dart';

void main() {
  group('AuthSessionModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'access_token': 'abc',
        'refresh_token': 'def',
        'expires_at': '2026-12-31T23:59:59.000',
        'employee_name': 'Abdullah Mubashir',
        'employee_id': 'M2024001',
      };
      final model = AuthSessionModel.fromJson(json);
      expect(model.accessToken, 'abc');
      expect(model.refreshToken, 'def');
      expect(model.employeeName, 'Abdullah Mubashir');
      expect(model.employeeId, 'M2024001');
      expect(model.expiresAt.isAfter(DateTime(2026, 12, 31)), isTrue);
    });

    test('toJson serializes correctly', () {
      final model = AuthSessionModel(
        accessToken: 'abc',
        refreshToken: 'def',
        expiresAt: DateTime.utc(2026, 12, 31),
        employeeName: 'Abdullah Mubashir',
        employeeId: 'M2024001',
      );
      final json = model.toJson();
      expect(json['access_token'], 'abc');
      expect(json['refresh_token'], 'def');
      expect(json['employee_name'], 'Abdullah Mubashir');
      expect(json['employee_id'], 'M2024001');
      expect(json['expires_at'], '2026-12-31T00:00:00.000Z');
    });

    test('fromJson handles a missing expires_at safely', () {
      final model = AuthSessionModel.fromJson({'access_token': 'x'});
      expect(model.accessToken, 'x');
      expect(model.isExpired, isFalse);
    });
  });
}