import '../../../../core/result/result.dart';
import '../../domain/entities/leave.dart';

/// A draft leave request coming from the create form.
class LeaveDraft {
  const LeaveDraft({
    required this.type,
    required this.mode,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.attachments = const [],
  });

  final LeaveType type;
  final LeaveMode mode;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final List<String> attachments;
}

/// Common contract implemented by the mock and remote leave data sources so
/// the repository can swap between them with a one-line provider change.
abstract class LeaveDataSource {
  Future<Result<List<LeaveRequest>>> fetchLeaves(String accessToken,
      {LeaveStatus? filter});
  Future<Result<void>> createLeave(String accessToken, LeaveDraft draft);
}