import '../../../../core/result/result.dart';
import '../../domain/entities/dashboard.dart';

/// Common contract implemented by the mock and remote dashboard sources so
/// the repository can swap between them with a one-line provider change.
abstract class DashboardDataSource {
  Future<Result<DashboardSummary>> fetchSummary({String accessToken = ''});
}