import 'package:flutter_test/flutter_test.dart';

import 'package:school_management_system/core/network/portal_time.dart';

void main() {
  group('PortalTime', () {
    test('converts a bare UTC 24h time to the device local timezone', () {
      final local = PortalTime.toLocal(date: '2026-09-04', time: '20:57');
      expect(local, DateTime.utc(2026, 9, 4, 20, 57).toLocal());
    });

    test('keeps morning times on the same local calendar day', () {
      final local = PortalTime.toLocal(date: '2026-09-04', time: '08:15');
      expect(local, DateTime.utc(2026, 9, 4, 8, 15).toLocal());
    });

    test('returns null for unparseable input', () {
      expect(PortalTime.toLocal(date: '', time: 'xx'), isNull);
      expect(PortalTime.toLocal(date: '2026-09-04', time: ''), isNull);
      expect(PortalTime.toLocal(date: 'nope', time: '20:57'), isNull);
      expect(PortalTime.toLocal(date: '2026-09-04', time: '25:99'), isNull);
    });

    test('isBareTime recognises 24h values and rejects formatted ones', () {
      expect(PortalTime.isBareTime('20:57'), isTrue);
      expect(PortalTime.isBareTime('8:15'), isTrue);
      expect(PortalTime.isBareTime('08:55 AM'), isFalse);
      expect(PortalTime.isBareTime('In: 08:55 AM'), isFalse);
      expect(PortalTime.isBareTime('nope'), isFalse);
    });

    test('isServerDate recognises YYYY-MM-DD dates', () {
      expect(PortalTime.isServerDate('2026-09-04'), isTrue);
      expect(PortalTime.isServerDate('Mon, 4 Aug 2026'), isFalse);
    });
  });
}
