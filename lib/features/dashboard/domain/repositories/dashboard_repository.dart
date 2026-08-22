import '../../../../core/result/result.dart';
import '../entities/dashboard.dart';

/// Contract implemented by the data layer.
abstract class DashboardRepository {
  Future<Result<DashboardSummary>> fetchSummary({required String accessToken});
}