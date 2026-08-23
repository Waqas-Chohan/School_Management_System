import '../../../../core/result/result.dart';
import '../../domain/entities/attendance.dart';
import 'attendance_data_source.dart';

/// Mock attendance summary matching the Figma "Teacher Attendance" design
/// (frame 92:1268): KPI ring 92%, stats Present 24 / Absent 2 / Leave 1 /
/// Late 3, and the Recent Attendance History log.
class AttendanceMockDataSourceImpl implements AttendanceDataSource {
  AttendanceMockDataSourceImpl();

  @override
  Future<Result<AttendanceSummary>> fetchSummary(
    String accessToken, {
    String? month,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    return const Success(
      AttendanceSummary(
        monthLabel: 'August 2026',
        percent: 92,
        headline: 'Excellent Consistency!',
        subtitle: 'You have maintained the target attendance rate of over 90%.',
        stats: [
          AttendanceStat(
            type: AttendanceStatType.present,
            label: 'Present',
            count: 24,
          ),
          AttendanceStat(
            type: AttendanceStatType.absent,
            label: 'Absent',
            count: 2,
          ),
          AttendanceStat(
            type: AttendanceStatType.leave,
            label: 'Leave',
            count: 1,
          ),
          AttendanceStat(
            type: AttendanceStatType.late,
            label: 'Late',
            count: 3,
          ),
        ],
        history: [
          AttendanceLogEntry(
            date: 'Mon, 4 Aug 2026',
            inTime: 'In: 08:55 AM',
            outTime: 'Out: 04:30 PM',
            status: AttendanceDayStatus.present,
          ),
          AttendanceLogEntry(
            date: 'Thu, 3 Aug 2026',
            inTime: 'In: 08:50 AM',
            outTime: 'Out: 04:30 PM',
            status: AttendanceDayStatus.absent,
          ),
          AttendanceLogEntry(
            date: 'Wed, 2 Aug 2026',
            inTime: 'In: 09:05 AM',
            outTime: 'Out: 04:30 PM',
            status: AttendanceDayStatus.late,
          ),
          AttendanceLogEntry(
            date: 'Tue, 1 Aug 2026',
            inTime: 'In: 08:45 AM',
            outTime: 'Out: 04:30 PM',
            status: AttendanceDayStatus.present,
          ),
          AttendanceLogEntry(
            date: 'Fri, 31 Jul 2026',
            inTime: 'In: 09:12 AM',
            outTime: 'Out: 04:30 PM',
            status: AttendanceDayStatus.leave,
          ),
          AttendanceLogEntry(
            date: 'Mon, 30 Jul 2026',
            inTime: 'In: 08:40 AM',
            outTime: 'Out: 04:30 PM',
            status: AttendanceDayStatus.present,
          ),
          AttendanceLogEntry(
            date: 'Sun, 29 Jul 2026',
            inTime: 'In: 09:00 AM',
            outTime: 'Out: 04:30 PM',
            status: AttendanceDayStatus.present,
          ),
        ],
      ),
    );
  }
}
