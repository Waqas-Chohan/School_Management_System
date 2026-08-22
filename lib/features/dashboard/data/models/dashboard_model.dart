import '../../domain/entities/dashboard.dart';

/// Serializable DTO for [DashboardSummary].
class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.greeting,
    required super.dateLabel,
    required super.quickActions,
    required super.timetable,
    required super.classStatuses,
    required super.upcoming,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      greeting: json['greeting']?.toString() ?? '',
      dateLabel: json['date_label']?.toString() ?? '',
      quickActions: (json['quick_actions'] as List? ?? const <dynamic>[])
          .map((e) => QuickActionModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      timetable: (json['timetable'] as List? ?? const <dynamic>[])
          .map((e) => TimetablePeriodModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      classStatuses: (json['class_statuses'] as List? ?? const <dynamic>[])
          .map((e) =>
              ClassAttendanceStatusModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      upcoming: (json['upcoming'] as List? ?? const <dynamic>[])
          .map((e) => UpcomingEventModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  factory DashboardSummaryModel.fromEntity(DashboardSummary entity) {
    return DashboardSummaryModel(
      greeting: entity.greeting,
      dateLabel: entity.dateLabel,
      quickActions: entity.quickActions,
      timetable: entity.timetable,
      classStatuses: entity.classStatuses,
      upcoming: entity.upcoming,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'greeting': greeting,
      'date_label': dateLabel,
      'quick_actions': quickActions
          .map((e) => QuickActionModel.fromEntity(e).toJson())
          .toList(),
      'timetable': timetable
          .map((e) => TimetablePeriodModel.fromEntity(e).toJson())
          .toList(),
      'class_statuses': classStatuses
          .map((e) => ClassAttendanceStatusModel.fromEntity(e).toJson())
          .toList(),
      'upcoming': upcoming
          .map((e) => UpcomingEventModel.fromEntity(e).toJson())
          .toList(),
    };
  }
}
class QuickActionModel extends QuickAction {
  const QuickActionModel({
    required super.id,
    required super.title,
    required super.type,
  });

  factory QuickActionModel.fromJson(Map<String, dynamic> json) {
    return QuickActionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: _quickActionTypeFromJson(json['type']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'type': type.name};
  }

  factory QuickActionModel.fromEntity(QuickAction entity) {
    return QuickActionModel(id: entity.id, title: entity.title, type: entity.type);
  }
}

class TimetablePeriodModel extends TimetablePeriod {
  const TimetablePeriodModel({
    required super.subject,
    required super.role,
    required super.room,
    required super.className,
    required super.timeRange,
  });

  factory TimetablePeriodModel.fromJson(Map<String, dynamic> json) {
    return TimetablePeriodModel(
      subject: json['subject']?.toString() ?? '',
      role: json['role']?.toString() == 'class_incharge'
          ? TimetableRole.classIncharge
          : TimetableRole.subjectTeacher,
      room: json['room']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
      timeRange: json['time_range']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'role': role.name == 'classIncharge' ? 'class_incharge' : 'subject_teacher',
      'room': room,
      'class_name': className,
      'time_range': timeRange,
    };
  }

  factory TimetablePeriodModel.fromEntity(TimetablePeriod entity) {
    return TimetablePeriodModel(
      subject: entity.subject,
      role: entity.role,
      room: entity.room,
      className: entity.className,
      timeRange: entity.timeRange,
    );
  }
}
class ClassAttendanceStatusModel extends ClassAttendanceStatus {
  const ClassAttendanceStatusModel({
    required super.className,
    required super.subject,
    super.percent,
    super.status,
  });

  factory ClassAttendanceStatusModel.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() == 'marked'
        ? AttendanceMarkStatus.marked
        : AttendanceMarkStatus.notMarked;
    return ClassAttendanceStatusModel(
      className: json['class_name']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      percent: int.tryParse(json['percent']?.toString() ?? '0') ?? 0,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_name': className,
      'subject': subject,
      'percent': percent,
      'status': status.name == 'marked' ? 'marked' : 'not_marked',
    };
  }

  factory ClassAttendanceStatusModel.fromEntity(ClassAttendanceStatus entity) {
    return ClassAttendanceStatusModel(
      className: entity.className,
      subject: entity.subject,
      percent: entity.percent,
      status: entity.status,
    );
  }
}

class UpcomingEventModel extends UpcomingEvent {
  const UpcomingEventModel({
    required super.title,
    required super.date,
    super.kind,
  });

  factory UpcomingEventModel.fromJson(Map<String, dynamic> json) {
    return UpcomingEventModel(
      title: json['title']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      kind: _upcomingKindFromJson(json['kind']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'date': date, 'kind': kind.name};
  }

  factory UpcomingEventModel.fromEntity(UpcomingEvent entity) {
    return UpcomingEventModel(title: entity.title, date: entity.date, kind: entity.kind);
  }
}

QuickActionType _quickActionTypeFromJson(String? value) {
  return switch (value) {
    'apply_leave' => QuickActionType.applyLeave,
    'view_datesheet' => QuickActionType.viewDatesheet,
    _ => QuickActionType.myAttendance,
  };
}

UpcomingEventKind _upcomingKindFromJson(String? value) {
  return switch (value) {
    'meeting' => UpcomingEventKind.meeting,
    'leave' => UpcomingEventKind.leave,
    _ => UpcomingEventKind.holiday,
  };
}