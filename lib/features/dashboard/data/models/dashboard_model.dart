import 'package:intl/intl.dart';

import '../../domain/entities/dashboard.dart';

/// Serializable DTO for [DashboardSummary].
///
/// Maps the SMS portal dashboard payload:
/// `{ teacher, stats, todays_timetable, class_attendance_records,
///    upcoming_schedule }` onto the existing display-oriented entity. Quick
/// actions are app-level shortcuts, so they are always rebuilt locally.
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
    final teacher =
        (json['teacher'] as Map? ?? const <String, dynamic>{})
            .cast<String, dynamic>();
    final name = teacher['name']?.toString().trim() ?? '';
    final firstName = name.isEmpty ? 'Teacher' : name.split(' ').first;
    final now = DateTime.now();

    final rawTimetable =
        (json['todaysTimetable'] ?? json['todays_timetable']) as List? ??
        const <dynamic>[];
    final rawClassRecords =
        (json['classAttendanceRecords'] ?? json['class_attendance_records'])
                as List? ??
            const <dynamic>[];

    return DashboardSummaryModel(
      greeting: 'Hy, $firstName',
      dateLabel: DateFormat('EEEE, MMMM d, yyyy').format(now),
      quickActions: _defaultQuickActions(),
      timetable: rawTimetable
          .map(
            (e) => TimetablePeriodModel.fromJson(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .toList(),
      classStatuses: rawClassRecords
          .map(
            (e) => ClassAttendanceStatusModel.fromJson(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .toList(),
      upcoming: _upcomingFrom(json['upcomingSchedule'] ?? json['upcoming_schedule']),
    );
  }

  /// The three dashboard quick-action shortcuts (app-level, always present).
  static List<QuickAction> _defaultQuickActions() => const [
    QuickAction(
      id: '1',
      title: 'My Attendance',
      type: QuickActionType.myAttendance,
    ),
    QuickAction(
      id: '2',
      title: 'Apply For Leave',
      type: QuickActionType.applyLeave,
    ),
    QuickAction(
      id: '3',
      title: 'View Datesheet',
      type: QuickActionType.viewDatesheet,
    ),
  ];

  /// Combines the optional `events` and `holidays` groups from
  /// `upcoming_schedule` into the single [UpcomingEvent] list the UI renders.
  static List<UpcomingEvent> _upcomingFrom(Object? raw) {
    final schedule =
        (raw as Map? ?? const <String, dynamic>{}).cast<String, dynamic>();
    final events = (schedule['events'] as List? ?? const <dynamic>[])
        .map((e) => (e as Map).cast<String, dynamic>())
        .map(
          (e) => UpcomingEvent(
            title: e['title']?.toString() ?? e['name']?.toString() ?? '',
            date: e['date']?.toString() ?? '',
            kind: _upcomingKindFromJson(e['kind']?.toString(),
                defaultKind: UpcomingEventKind.meeting),
          ),
        )
        .toList();
    final holidays = (schedule['holidays'] as List? ?? const <dynamic>[])
        .map((e) => (e as Map).cast<String, dynamic>())
        .map(
          (e) => UpcomingEvent(
            title: e['title']?.toString() ?? e['name']?.toString() ?? '',
            date: e['date']?.toString() ?? '',
            kind: _upcomingKindFromJson(e['kind']?.toString(),
                defaultKind: UpcomingEventKind.holiday),
          ),
        )
        .toList();
    return [...events, ...holidays];
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

  /// Tolerant parser for the timetable entries. Accepts both the live portal's
  /// camelCase keys (`subjectName`, `className`, `room`, `startTime`,
  /// `endTime`) and the older snake_case aliases.
  factory TimetablePeriodModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject']?.toString() ??
        json['subjectName']?.toString() ??
        json['subject_name']?.toString() ??
        '';
    final className = json['className']?.toString() ??
        json['class_name']?.toString() ??
        '';
    final room = json['room']?.toString() ??
        json['roomNo']?.toString() ??
        json['room_no']?.toString() ??
        '';
    final start = json['startTime']?.toString() ??
        json['start_time']?.toString() ??
        json['start']?.toString() ??
        '';
    final end = json['endTime']?.toString() ??
        json['end_time']?.toString() ??
        json['end']?.toString() ??
        '';
    final timeRange = json['time_range']?.toString() ??
        (start.isEmpty && end.isEmpty ? '' : '$start - $end');
    final role = json['isClassTeacher'] == true ||
        json['is_class_teacher'] == true
        ? TimetableRole.classIncharge
        : TimetableRole.subjectTeacher;
    return TimetablePeriodModel(
      subject: subject,
      role: role,
      room: room,
      className: className,
      timeRange: timeRange,
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

  /// Maps a `class_attendance_records` entry. The dashboard card shows the
  /// class + section as its name and uses `marked_percentage` /
  /// `is_marked_today` for the completion pill. The live portal returns
  /// camelCase keys (`sectionName`, `subjectName`, `markedPercentage`,
  /// `isMarkedToday`).
  factory ClassAttendanceStatusModel.fromJson(Map<String, dynamic> json) {
    final section = json['sectionName']?.toString() ??
        json['section_name']?.toString() ??
        '';
    final className = '${json['className']?.toString() ?? ''}'
        '${section.isEmpty ? '' : ' - $section'}';
    final marked = json['isMarkedToday'] == true ||
        json['is_marked_today'] == true;
    final percent = int.tryParse(
      json['markedPercentage']?.toString() ??
          json['marked_percentage']?.toString() ??
          '0',
    ) ?? 0;
    return ClassAttendanceStatusModel(
      className: className,
      subject: json['subjectName']?.toString() ??
          json['subject_name']?.toString() ??
          '',
      percent: percent,
      status: marked
          ? AttendanceMarkStatus.marked
          : AttendanceMarkStatus.notMarked,
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

UpcomingEventKind _upcomingKindFromJson(
  String? value, {
  UpcomingEventKind defaultKind = UpcomingEventKind.holiday,
}) {
  return switch (value) {
    'meeting' => UpcomingEventKind.meeting,
    'leave' => UpcomingEventKind.leave,
    'holiday' => UpcomingEventKind.holiday,
    _ => defaultKind,
  };
}