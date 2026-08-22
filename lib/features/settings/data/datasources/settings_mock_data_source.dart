import '../../domain/entities/settings.dart';
import 'settings_data_source.dart';

/// Mock settings items matching the Figma "settings" design (65:5573):
/// Features (Edit Profile / Attendance / Change Password), Notifications
/// (Push Notifications toggle) and Legal (About App).
class SettingsMockDataSourceImpl implements SettingsDataSource {
  SettingsMockDataSourceImpl();

  static const List<SettingsItem> _items = [
    SettingsItem(
      id: '1',
      type: SettingsItemType.editProfile,
      title: 'Edit Profile',
    ),
    SettingsItem(
      id: '2',
      type: SettingsItemType.myAttendance,
      title: 'Attendance',
    ),
    SettingsItem(
      id: '3',
      type: SettingsItemType.changePassword,
      title: 'Change Password',
    ),
    SettingsItem(
      id: '4',
      type: SettingsItemType.about,
      title: 'About App',
    ),
  ];

  @override
  Future<List<SettingsItem>> fetchItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_items);
  }
}