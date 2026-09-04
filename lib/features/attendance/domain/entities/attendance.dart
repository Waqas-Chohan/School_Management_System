/// The status of a single attendance day in the log.
enum AttendanceDayStatus { present, absent, leave, late }

/// Result payload returned after a self check-in / check-out action.
class CheckInOutResult {
  const CheckInOutResult({
    required this.message,
    required this.status,
    this.checkIn,
    this.checkOut,
  });

  /// Server message, e.g. "Checked in successfully at 18:01".
  final String message;

  /// Attendance status, e.g. "Present".
  final String status;

  /// "HH:MM" 24h time of the check-in (null until checked in).
  final String? checkIn;

  /// "HH:MM" 24h time of the check-out (null until checked out).
  final String? checkOut;
}

/// Which stat badge is displayed in the summary row.
enum AttendanceStatType { present, absent, leave, late }

/// A single entry in the recent attendance history log.
class AttendanceLogEntry {
  const AttendanceLogEntry({
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.status,
  });

  final String date;
  final String inTime;
  final String outTime;
  final AttendanceDayStatus status;

  String get statusLabel => switch (status) {
    AttendanceDayStatus.present => 'Present',
    AttendanceDayStatus.absent => 'Absent',
    AttendanceDayStatus.leave => 'Leave',
    AttendanceDayStatus.late => 'Late In',
  };
}

/// A stat counter shown in the summary row.
class AttendanceStat {
  const AttendanceStat({
    required this.type,
    required this.label,
    required this.count,
  });

  final AttendanceStatType type;
  final String label;
  final int count;
}

/// Aggregate view-model for the Teacher Attendance screen.
class AttendanceSummary {
  const AttendanceSummary({
    required this.monthLabel,
    required this.percent,
    required this.headline,
    required this.subtitle,
    required this.stats,
    required this.history,
  });

  final String monthLabel;
  final int percent;
  final String headline;
  final String subtitle;
  final List<AttendanceStat> stats;
  final List<AttendanceLogEntry> history;
}
