/// The type of a quick-action shortcut card on the dashboard.
enum QuickActionType {
  myAttendance,
  applyLeave,
  viewDatesheet,
}

/// A shortcut card shown in the "Quick Actions" section.
class QuickAction {
  const QuickAction({
    required this.id,
    required this.title,
    required this.type,
  });

  final String id;
  final String title;
  final QuickActionType type;
}

/// The role badge attached to a timetable period.
enum TimetableRole {
  subjectTeacher,
  classIncharge,
}

/// A single period inside "Today's Timetable".
class TimetablePeriod {
  const TimetablePeriod({
    required this.subject,
    required this.role,
    required this.room,
    required this.className,
    required this.timeRange,
  });

  final String subject;
  final TimetableRole role;
  final String room;
  final String className;
  final String timeRange;
}

/// Attendance completion state of a class.
enum AttendanceMarkStatus {
  marked,
  notMarked,
}

/// A class card inside the "Class Attendance Records" section.
class ClassAttendanceStatus {
  const ClassAttendanceStatus({
    required this.className,
    required this.subject,
    this.percent = 0,
    this.status = AttendanceMarkStatus.notMarked,
  });

  final String className;
  final String subject;
  final int percent;
  final AttendanceMarkStatus status;

  String get label => status == AttendanceMarkStatus.marked
      ? '$percent% Marked'
      : 'Not Marked';
}

/// The category of an upcoming event.
enum UpcomingEventKind {
  holiday,
  meeting,
  leave,
}

/// A row inside the "Upcoming Schedule" card.
class UpcomingEvent {
  const UpcomingEvent({
    required this.title,
    required this.date,
    this.kind = UpcomingEventKind.holiday,
  });

  final String title;
  final String date;
  final UpcomingEventKind kind;
}

/// Aggregate view-model for the Dashboard home screen.
class DashboardSummary {
  const DashboardSummary({
    required this.greeting,
    required this.dateLabel,
    required this.quickActions,
    required this.timetable,
    required this.classStatuses,
    required this.upcoming,
  });

  final String greeting;
  final String dateLabel;
  final List<QuickAction> quickActions;
  final List<TimetablePeriod> timetable;
  final List<ClassAttendanceStatus> classStatuses;
  final List<UpcomingEvent> upcoming;
}