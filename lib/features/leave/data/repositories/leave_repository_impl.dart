import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/leave.dart';
import '../../domain/repositories/leave_repository.dart';
import '../datasources/leave_data_source.dart';

/// Implements [LeaveRepository] over the live portal API with a graceful
/// fallback to the mock source when the network is unreachable.
class LeaveRepositoryImpl implements LeaveRepository {
  const LeaveRepositoryImpl(this._mockDataSource, this._remoteDataSource);

  final LeaveDataSource _mockDataSource;
  final LeaveDataSource _remoteDataSource;

  @override
  Future<Result<List<LeaveRequest>>> fetchLeaves({
    required String accessToken,
    LeaveStatus? filter,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to view leaves.'));
    }
    final remote = await _remoteDataSource.fetchLeaves(accessToken, filter: filter);
    if (remote is Success<List<LeaveRequest>>) return remote;
    if (remote is Failure<List<LeaveRequest>> && remote.failure is NetworkFailure) {
      return _mockDataSource.fetchLeaves(accessToken, filter: filter);
    }
    return remote;
  }

  @override
  Future<Result<void>> createLeave({
    required String accessToken,
    required CreateLeaveInput input,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to apply for leave.'));
    }
    final remote = await _remoteDataSource.createLeave(
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
    if (remote is Success<void>) return remote;
    if (remote is Failure<void> && remote.failure is NetworkFailure) {
      return _mockDataSource.createLeave(
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
    return remote;
  }
}