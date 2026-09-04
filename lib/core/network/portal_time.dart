/// Helpers for interpreting the portal's UTC-stored attendance timestamps.
///
/// The SMS backend records attendance times in UTC and returns them as bare
/// 24-hour strings (`"20:57"`) alongside the server-calendar `date`
/// (`"2026-09-04"`). This was verified against the live API: at the moment a
/// check-in was recorded the HTTP `Date` header read `04 Sep 2026 20:57:48
/// GMT` and the stored value was `"20:57"`. A device in UTC+5 must therefore
/// read `"20:57"` as `"1:57 AM"` the next day — the actual local clock time.
class PortalTime {
  const PortalTime._();

  static final RegExp _bareTime = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$');
  static final RegExp _serverDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');

  /// Whether [time] is a bare 24-hour clock value like `"20:57"`.
  static bool isBareTime(String time) => _bareTime.hasMatch(time.trim());

  /// Whether [date] is a server calendar date like `"2026-09-04"`.
  static bool isServerDate(String date) => _serverDate.hasMatch(date);

  /// Converts a server calendar [date] plus bare 24h [time] (stored in UTC)
  /// into the device's local [DateTime]. Returns null when either input
  /// cannot be parsed.
  static DateTime? toLocal({required String date, required String time}) {
    final d = _serverDate.firstMatch(date);
    final t = _bareTime.firstMatch(time.trim());
    if (d == null || t == null) return null;
    final hour = int.parse(t.group(1)!);
    final minute = int.parse(t.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return DateTime.utc(
      int.parse(d.group(1)!),
      int.parse(d.group(2)!),
      int.parse(d.group(3)!),
      hour,
      minute,
    ).toLocal();
  }
}
