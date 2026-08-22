/// Type of a settings menu item.
enum SettingsItemType {
  editProfile,
  myAttendance,
  changePassword,
  about,
  logout,
}

/// A pure domain entity describing a settings menu row.
class SettingsItem {
  const SettingsItem({
    required this.id,
    required this.type,
    required this.title,
  });

  final String id;
  final SettingsItemType type;
  final String title;
}