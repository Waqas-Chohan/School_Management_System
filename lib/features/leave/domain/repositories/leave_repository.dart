import '../../../../core/result/result.dart';
import '../entities/leave.dart';

/// Parameters required to create a new leave request.
class CreateLeaveInput {
  const CreateLeaveInput({
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

/// Contract implemented by the data layer.
abstract class LeaveRepository {
  Future<Result<List<LeaveRequest>>> fetchLeaves({
    required String accessToken,
    LeaveStatus? filter,
  });

  Future<Result<void>> createLeave({
    required String accessToken,
    required CreateLeaveInput input,
  });
}