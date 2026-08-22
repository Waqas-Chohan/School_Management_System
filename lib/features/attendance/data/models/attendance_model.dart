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

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      monthLabel: json['month_label']?.toString() ?? '',
      percent: int.tryParse(json['percent']?.toString() ?? '0') ?? 0,
      headline: json['headline']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      stats: (json['stats'] as List? ?? const <dynamic>[])
          .map((e) => AttendanceStatModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      history: (json['history'] as List? ?? const <dynamic>[])
          .map((e) => AttendanceLogModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  factory AttendanceSummaryModel.fromEntity(AttendanceSummary entity) {
    return AttendanceSummaryModel(
      monthLabel: entity.monthLabel,
      percent: entity.percent,
      headline: entity.headline,
      subtitle: entity.subtitle,
      stats: entity.stats
          .map((s) => AttendanceStatModel(type: s.type, label: s.label, count: s.count))
          .toList(),
      history: entity.history
          .map((h) => AttendanceLogModel(
                date: h.date,
                inTime: h.inTime,
                outTime: h.outTime,
                status: h.status,
              ))
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
          .map((h) => {
                'date': h.date,
                'in_time': h.inTime,
                'out_time': h.outTime,
                'status': h.status.name,
              })
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

  factory AttendanceLogModel.fromJson(Map<String, dynamic> json) {
    final status = switch (json['status']?.toString()) {
      'absent' => AttendanceDayStatus.absent,
      'leave' => AttendanceDayStatus.leave,
      'late' => AttendanceDayStatus.late,
      _ => AttendanceDayStatus.present,
    };
    return AttendanceLogModel(
      date: json['date']?.toString() ?? '',
      inTime: json['in_time']?.toString() ?? '',
      outTime: json['out_time']?.toString() ?? '',
      status: status,
    );
  }
}