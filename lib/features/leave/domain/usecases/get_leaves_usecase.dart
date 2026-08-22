import '../../../../core/result/result.dart';
import '../entities/leave.dart';
import '../repositories/leave_repository.dart';

class GetLeavesParams {
  const GetLeavesParams({required this.accessToken, this.filter});
  final String accessToken;
  final LeaveStatus? filter;
}

class GetLeavesUseCase {
  const GetLeavesUseCase(this._repository);
  final LeaveRepository _repository;

  Future<Result<List<LeaveRequest>>> call(GetLeavesParams params) {
    return _repository.fetchLeaves(
      accessToken: params.accessToken,
      filter: params.filter,
    );
  }
}