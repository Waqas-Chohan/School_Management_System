/// Central place for all backend endpoint constants.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.schoolmgmt.dev/v1';

  // ── Auth ───────────────────────────────────────────
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // ── Profile ────────────────────────────────────────
  static const String profile = '/profile';

  // ── Dashboard ──────────────────────────────────────
  static const String dashboardSummary = '/dashboard/summary';

  // ── Attendance ─────────────────────────────────────
  static const String markAttendance = '/attendance/mark';
  static const String myAttendance = '/attendance/my';
  static const String classAttendance = '/attendance/class';

  // ── Leave ──────────────────────────────────────────
  static const String leaveRequests = '/leave/requests';
  static const String applyLeave = '/leave/apply';

  // ── Features (generic module) ──────────────────────
  static const String features = '/features';
}