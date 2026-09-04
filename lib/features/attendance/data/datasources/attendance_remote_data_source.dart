import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/attendance.dart';
import '../models/attendance_model.dart';
import 'attendance_data_source.dart';

/// Remote attendance data source backed by [Dio]. Reads the teacher's own
/// check-in / check-out history from the SMS portal:
/// `GET /teacher-portal/profile/attendance?month=&year=`.
class AttendanceRemoteDataSourceImpl implements AttendanceDataSource {
  AttendanceRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<Result<AttendanceSummary>> fetchSummary(
    String accessToken, {
    String? month,
  }) async {
    return guardApi(() async {
      final now = DateTime.now();
      final selectedMonth = int.tryParse(month ?? '') ?? now.month;
      final selectedYear = now.year;
      final response = await dio.get<Map<String, dynamic>>(
        ApiEndpoints.profileAttendance,
        queryParameters: {'month': selectedMonth, 'year': selectedYear},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final payload = envelopeMap(response.data);
      return AttendanceSummaryModel.fromJson(
        payload,
        monthLabel: DateFormat('MMMM yyyy').format(now),
      );
    });
  }
}
