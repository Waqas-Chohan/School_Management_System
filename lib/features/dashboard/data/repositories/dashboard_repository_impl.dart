import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_data_source.dart';

/// Implements [DashboardRepository] over the live portal API with a graceful
/// fallback to the mock source when the network is unreachable, so the app
/// remains fully usable offline / during the demo.
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._mockDataSource, this._remoteDataSource);

  final DashboardDataSource _mockDataSource;
  final DashboardDataSource _remoteDataSource;

  @override
  Future<Result<DashboardSummary>> fetchSummary({
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to view the dashboard.'));
    }
    final remote = await _remoteDataSource.fetchSummary(accessToken: accessToken);
    if (remote is Success<DashboardSummary>) return remote;
    if (remote is Failure<DashboardSummary> && remote.failure is NetworkFailure) {
      return _mockDataSource.fetchSummary(accessToken: accessToken);
    }
    return remote;
  }
}