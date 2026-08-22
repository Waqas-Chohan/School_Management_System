import 'package:flutter_test/flutter_test.dart';

import 'package:school_management_system/features/settings/domain/entities/settings.dart';

void main() {
  group('SettingsItem', () {
    test('holds id, type and title', () {
      const item = SettingsItem(
        id: '1',
        type: SettingsItemType.editProfile,
        title: 'Edit Profile',
      );
      expect(item.id, '1');
      expect(item.type, SettingsItemType.editProfile);
      expect(item.title, 'Edit Profile');
    });

    test('all design types exist', () {
      expect(SettingsItemType.values, containsAll(<SettingsItemType>[
        SettingsItemType.editProfile,
        SettingsItemType.myAttendance,
        SettingsItemType.changePassword,
        SettingsItemType.about,
        SettingsItemType.logout,
      ]));
    });
  });
}