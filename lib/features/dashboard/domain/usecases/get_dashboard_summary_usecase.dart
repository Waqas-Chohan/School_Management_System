import '../../../../core/result/result.dart';
import '../entities/dashboard.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSummaryParams {
  const GetDashboardSummaryParams({required this.accessToken});
  final String accessToken;
}

class GetDashboardSummaryUseCase {
  const GetDashboardSummaryUseCase(this._repository);
  final DashboardRepository _repository;

  Future<Result<DashboardSummary>> call(GetDashboardSummaryParams params) {
    return _repository.fetchSummary(accessToken: params.accessToken);
  }
}