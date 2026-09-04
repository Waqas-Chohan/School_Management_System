/// Central place for all backend endpoint constants.
///
/// Live backend: SMS Teacher Portal API on `sba.snowberrysys.com`.
/// All responses are wrapped in the `{ success, message, data }` envelope
/// (see `api_response.dart`).
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://sba.snowberrysys.com/api';

  // -- Auth --
  static const String login = '/teacher-portal/login';
  static const String logout = '/teacher-portal/logout';

  // -- Dashboard --
  static const String dashboardSummary = '/teacher-portal/dashboard';

  // -- Classes & Class Attendance --
  static const String classes = '/teacher-portal/classes';
  static const String attendanceStudents = '/teacher-portal/attendance/students';
  static const String markAttendance = '/teacher-portal/attendance/mark';

  // -- Teacher Check-In / Check-Out --
  static const String checkIn = '/teacher-portal/attendance/check-in';
  static const String checkOut = '/teacher-portal/attendance/check-out';

  // -- Leave --
  static const String leaveRequests = '/teacher-portal/leaves';
  static const String applyLeave = '/teacher-portal/leaves';

  // -- Exams & Datesheet --
  static const String datesheets = '/teacher-portal/datesheets';
  static const String exams = '/teacher-portal/exams';

  // -- Profile & Security --
  static const String profile = '/teacher-portal/profile';
  static const String profileAttendance = '/teacher-portal/profile/attendance';
  static const String changePassword = '/teacher-portal/profile/change-password';
  static const String uploadAvatar = '/teacher-portal/upload';
  static const String notifications = '/teacher-portal/settings/notifications';
}