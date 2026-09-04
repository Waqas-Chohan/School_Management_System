import 'package:intl/intl.dart';

import '../../../../core/network/portal_time.dart';
import '../../domain/entities/attendance.dart';

/// Serializable model for [AttendanceSummary].
class AttendanceSummaryModel extends AttendanceSummary {
  const AttendanceSummaryModel({
    required super.monthLabel,
    required super.percent,
    required super.headline,
    required super.subtitle,
    required super.stats,
    required super.history,
  });

  /// Parses the portal payload:
  /// `{ summary: { totalWorkingDays, present, absent, late, leave,
  /// attendancePercentage }, records: [...] }`.
  factory AttendanceSummaryModel.fromJson(
    Map<String, dynamic> json, {
    String? monthLabel,
  }) {
    final summary = (json['summary'] as Map? ?? const <String, dynamic>{})
        .cast<String, dynamic>();
    final percent =
        int.tryParse(
          summary['attendancePercentage']?.toString() ??
              summary['attendance_percentage']?.toString() ??
              '0',
        ) ??
        0;
    final records = json['records'] as List? ?? const <dynamic>[];

    return AttendanceSummaryModel(
      monthLabel: monthLabel ?? '',
      percent: percent,
      headline: percent >= 90
          ? 'Excellent Consistency!'
          : percent >= 75
          ? 'Good Consistency'
          : 'Keep it up!',
      subtitle: 'Your attendance rate is $percent%. Try to stay above 90%.',
      stats: _statsFrom(summary),
      history: records
          .map(
            (e) =>
                AttendanceLogModel.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
    );
  }

  static List<AttendanceStat> _statsFrom(Map<String, dynamic> summary) {
    int count(String key) => int.tryParse(summary[key]?.toString() ?? '0') ?? 0;
    return [
      AttendanceStat(
        type: AttendanceStatType.present,
        label: 'Present',
        count: count('present'),
      ),
      AttendanceStat(
        type: AttendanceStatType.absent,
        label: 'Absent',
        count: count('absent'),
      ),
      AttendanceStat(
        type: AttendanceStatType.leave,
        label: 'Leave',
        count: count('leave'),
      ),
      AttendanceStat(
        type: AttendanceStatType.late,
        label: 'Late',
        count: count('late'),
      ),
    ];
  }

  factory AttendanceSummaryModel.fromEntity(AttendanceSummary entity) {
    return AttendanceSummaryModel(
      monthLabel: entity.monthLabel,
      percent: entity.percent,
      headline: entity.headline,
      subtitle: entity.subtitle,
      stats: entity.stats
          .map(
            (s) => AttendanceStatModel(
              type: s.type,
              label: s.label,
              count: s.count,
            ),
          )
          .toList(),
      history: entity.history
          .map(
            (h) => AttendanceLogModel(
              date: h.date,
              inTime: h.inTime,
              outTime: h.outTime,
              status: h.status,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month_label': monthLabel,
      'percent': percent,
      'headline': headline,
      'subtitle': subtitle,
      'stats': stats
          .map((s) => {'type': s.type.name, 'label': s.label, 'count': s.count})
          .toList(),
      'history': history
          .map(
            (h) => {
              'date': h.date,
              'in_time': h.inTime,
              'out_time': h.outTime,
              'status': h.status.name,
            },
          )
          .toList(),
    };
  }
}

class AttendanceStatModel extends AttendanceStat {
  const AttendanceStatModel({
    required super.type,
    required super.label,
    required super.count,
  });

  factory AttendanceStatModel.fromJson(Map<String, dynamic> json) {
    final type = switch (json['type']?.toString()) {
      'absent' => AttendanceStatType.absent,
      'leave' => AttendanceStatType.leave,
      'late' => AttendanceStatType.late,
      _ => AttendanceStatType.present,
    };
    return AttendanceStatModel(
      type: type,
      label: json['label']?.toString() ?? '',
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
    );
  }
}

class AttendanceLogModel extends AttendanceLogEntry {
  const AttendanceLogModel({
    required super.date,
    required super.inTime,
    required super.outTime,
    required super.status,
  });

  /// Tolerant parser for a single attendance record. Accepts the documented
  /// keys (`date`, `status`, `check_in`, `check_out`) plus common aliases.
  factory AttendanceLogModel.fromJson(Map<String, dynamic> json) {
    final status = switch (json['status']?.toString().toLowerCase()) {
      'absent' => AttendanceDayStatus.absent,
      'leave' => AttendanceDayStatus.leave,
      'late' => AttendanceDayStatus.late,
      _ => AttendanceDayStatus.present,
    };
    final date =
        json['date']?.toString() ??
        json['attendanceDate']?.toString() ??
        json['attendance_date']?.toString() ??
        '';
    return AttendanceLogModel(
      date: date,
      inTime: _formatTime(
        json['checkIn'] ??
            json['check_in'] ??
            json['checkInTime'] ??
            json['in_time'],
        date: date,
      ),
      outTime: _formatTime(
        json['checkOut'] ??
            json['check_out'] ??
            json['checkOutTime'] ??
            json['out_time'],
        date: date,
      ),
      status: status,
    );
  }

  /// Formats a timestamp for display. Bare 24-hour values such as `"20:57"`
  /// are stored in UTC by the portal, so they are converted to the device's
  /// local timezone using the record's server [date]; ISO timestamps carry
  /// their own zone (a trailing `Z` is converted to local, naive values are
  /// left untouched); already-formatted values pass through unchanged.
  static String _formatTime(Object? raw, {String date = ''}) {
    if (raw == null) return '';
    final text = raw.toString().trim().isEmpty ? '' : raw.toString().trim();
    if (text.isEmpty) return '';
    if (PortalTime.isBareTime(text)) {
      final local = PortalTime.toLocal(date: date, time: text);
      if (local != null) return DateFormat('hh:mm a').format(local);
      return text;
    }
    final parsed = DateTime.tryParse(text);
    if (parsed != null) {
      final local = parsed.isUtc ? parsed.toLocal() : parsed;
      return DateFormat('hh:mm a').format(local);
    }
    return text;
  }
}
