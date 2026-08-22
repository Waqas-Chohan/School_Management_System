import '../../../../core/result/result.dart';
import '../repositories/leave_repository.dart';

class CreateLeaveParams {
  const CreateLeaveParams({required this.accessToken, required this.input});
  final String accessToken;
  final CreateLeaveInput input;
}

class CreateLeaveUseCase {
  const CreateLeaveUseCase(this._repository);
  final LeaveRepository _repository;

  Future<Result<void>> call(CreateLeaveParams params) {
    return _repository.createLeave(
      accessToken: params.accessToken,
      input: params.input,
    );
  }
}