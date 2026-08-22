import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/leave.dart';
import '../../domain/repositories/leave_repository.dart';
import '../datasources/leave_data_source.dart';

/// Implements [LeaveRepository] using the configured data source.
/// Swap between mock and remote by changing the provider (master prompt §10).
class LeaveRepositoryImpl implements LeaveRepository {
  const LeaveRepositoryImpl(this._dataSource);

  final LeaveDataSource _dataSource;

  @override
  Future<Result<List<LeaveRequest>>> fetchLeaves({
    required String accessToken,
    LeaveStatus? filter,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to view leaves.'));
    }
    return _dataSource.fetchLeaves(accessToken, filter: filter);
  }

  @override
  Future<Result<void>> createLeave({
    required String accessToken,
    required CreateLeaveInput input,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to apply for leave.'));
    }
    return _dataSource.createLeave(
      accessToken,
      LeaveDraft(
        type: input.type,
        mode: input.mode,
        startDate: input.startDate,
        endDate: input.endDate,
        reason: input.reason,
        attachments: input.attachments,
      ),
    );
  }
}