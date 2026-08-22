import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_data_source.dart';

/// Implements [DashboardRepository] using the configured data source.
/// Swap between mock and remote by changing the provider (master prompt §10).
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._dataSource);

  final DashboardDataSource _dataSource;

  @override
  Future<Result<DashboardSummary>> fetchSummary({
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to view the dashboard.'));
    }
    return _dataSource.fetchSummary(accessToken: accessToken);
  }
}