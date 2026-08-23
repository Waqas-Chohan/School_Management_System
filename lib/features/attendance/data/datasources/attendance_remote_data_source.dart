import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/attendance.dart';
import '../models/attendance_model.dart';
import 'attendance_data_source.dart';

/// Remote attendance data source backed by [Dio].
class AttendanceRemoteDataSourceImpl implements AttendanceDataSource {
  AttendanceRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<Result<AttendanceSummary>> fetchSummary(
    String accessToken, {
    String? month,
  }) {
    return guardApi(() async {
      final response = await dio.get<Map<String, dynamic>>(
        ApiEndpoints.myAttendance,
        queryParameters: month == null ? null : {'month': month},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final payload = (response.data ?? const <String, dynamic>{})
          .cast<String, dynamic>();
      return AttendanceSummaryModel.fromJson(payload);
    });
  }
}
