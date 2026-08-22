import '../../../../core/result/result.dart';
import '../../domain/entities/dashboard.dart';
import 'dashboard_data_source.dart';

/// Mock dashboard data used while the backend is unavailable.
class DashboardMockDataSourceImpl implements DashboardDataSource {
  DashboardMockDataSourceImpl();

  @override
  Future<Result<DashboardSummary>> fetchSummary({String accessToken = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    return const Success(DashboardSummary(
      greeting: 'Hy, Ms. Sharma',
      dateLabel: 'Monday, October 16, 2026',
      quickActions: [
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
      ],
      timetable: [
        TimetablePeriod(
          subject: 'Mathematics',
          role: TimetableRole.subjectTeacher,
          room: 'Room-01',
          className: 'Class 8-A',
          timeRange: '08:00 - 08:45 AM',
        ),
        TimetablePeriod(
          subject: 'Physics',
          role: TimetableRole.classIncharge,
          room: 'Room-12',
          className: 'Class 9-B',
          timeRange: '08:50 - 09:35 AM',
        ),
        TimetablePeriod(
          subject: 'English Literature',
          role: TimetableRole.subjectTeacher,
          room: 'Room-09',
          className: 'Class 8-A',
          timeRange: '09:40 - 10:25 AM',
        ),
      ],
      classStatuses: [
        ClassAttendanceStatus(
          className: 'Class 8-A',
          subject: 'Mathematics',
          percent: 92,
          status: AttendanceMarkStatus.marked,
        ),
        ClassAttendanceStatus(
          className: 'Class 9-B',
          subject: 'Physics',
          percent: 96,
          status: AttendanceMarkStatus.marked,
        ),
        ClassAttendanceStatus(
          className: 'Class 10-C',
          subject: 'Algebra',
          status: AttendanceMarkStatus.notMarked,
        ),
      ],
      upcoming: [
        UpcomingEvent(
          title: 'Independence Day Holiday',
          date: 'Aug 14',
          kind: UpcomingEventKind.holiday,
        ),
        UpcomingEvent(
          title: 'Parent-Teacher Meeting',
          date: 'Aug 20',
          kind: UpcomingEventKind.meeting,
        ),
        UpcomingEvent(
          title: 'Casual Leave (2 Days)',
          date: 'Pending',
          kind: UpcomingEventKind.leave,
        ),
      ],
    ));
  }
}