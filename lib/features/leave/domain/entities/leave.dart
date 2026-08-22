/// The status of a leave request.
enum LeaveStatus { pending, approved, rejected, cancelled }

extension LeaveStatusX on LeaveStatus {
  String get label => switch (this) {
        LeaveStatus.pending => 'Pending',
        LeaveStatus.approved => 'Approved',
        LeaveStatus.rejected => 'Rejected',
        LeaveStatus.cancelled => 'Cancelled',
      };
}

/// Whether the leave is for a single day or multiple consecutive days.
enum LeaveMode { single, multiple }

/// Category of leave requested.
enum LeaveType { casual, sick, annual, family, other }

/// A pure domain entity representing a single leave request.
class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.type,
    required this.mode,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = LeaveStatus.pending,
    this.attachments = const [],
  });

  final String id;
  final LeaveType type;
  final LeaveMode mode;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final List<String> attachments;

  int get days => endDate.difference(startDate).inDays + 1;

  String get daysLabel => '$days ${days == 1 ? 'Day' : 'Days'}';

  String get typeLabel => switch (type) {
        LeaveType.casual => 'Casual Leave',
        LeaveType.sick => 'Sick Leave',
        LeaveType.annual => 'Annual Leave',
        LeaveType.family => 'Family Function',
        LeaveType.other => 'Other',
      };

  String get statusLabel => switch (status) {
        LeaveStatus.pending => 'Pending',
        LeaveStatus.approved => 'Approved',
        LeaveStatus.rejected => 'Rejected',
        LeaveStatus.cancelled => 'Cancelled',
      };

  static String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }

  String get dateRangeLabel {
    if (mode == LeaveMode.single) {
      return formatDate(startDate);
    }
    return '${formatDate(startDate)} - ${formatDate(endDate)}';
  }

  @override
  String toString() => 'LeaveRequest(id: $id, type: $typeLabel, '
      'status: $statusLabel)';
}