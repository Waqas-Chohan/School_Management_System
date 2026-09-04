import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/dashboard.dart';
import '../models/dashboard_model.dart';
import 'dashboard_data_source.dart';

/// Remote data source backed by [Dio]. Parses the SMS portal envelope and maps
/// the live dashboard payload onto the existing [DashboardSummary] entity.
class DashboardRemoteDataSourceImpl implements DashboardDataSource {
  DashboardRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<Result<DashboardSummary>> fetchSummary({String accessToken = ''}) {
    return guardApi(() async {
      final response = await dio.get<Map<String, dynamic>>(
        ApiEndpoints.dashboardSummary,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final payload = envelopeMap(response.data);
      return DashboardSummaryModel.fromJson(payload);
    });
  }
}