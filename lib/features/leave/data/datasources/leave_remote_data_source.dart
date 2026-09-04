import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/leave.dart';
import '../models/leave_model.dart';
import 'leave_data_source.dart';

/// Remote leave data source backed by the SMS portal:
/// - `GET  /teacher-portal/leaves?status=&from=&to=`
/// - `POST /teacher-portal/leaves` with `{ type, from, to, days, reason }`.
///
/// The GET response is wrapped as `{ stats, leaves }` inside the envelope.
class LeaveRemoteDataSourceImpl implements LeaveDataSource {
  LeaveRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  static final DateFormat _apiDate = DateFormat('yyyy-MM-dd');

  @override
  Future<Result<List<LeaveRequest>>> fetchLeaves(
    String accessToken, {
    LeaveStatus? filter,
  }) {
    return guardApi(() async {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final endOfYear = DateTime(now.year, 12, 31);
      // Use `get<dynamic>`: the body is the envelope Map (`{ stats, leaves }`),
      // not a raw list — a typed `get<List<T>>` would throw a cast DioException.
      final response = await dio.get<dynamic>(
        ApiEndpoints.leaveRequests,
        queryParameters: {
          'status': filter == null ? 'all' : _statusParam(filter),
          'from': _apiDate.format(startOfYear),
          'to': _apiDate.format(endOfYear),
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      // The endpoint returns `{ stats, leaves }` as the envelope's data map.
      final data = unwrapEnvelope(response.data);
      if (data is Map) {
        final leaves = data['leaves'] as List? ?? const <dynamic>[];
        return leaves
            .map((e) => LeaveModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      }
      if (data is List) {
        return data
            .map((e) => LeaveModel.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      }
      return const <LeaveRequest>[];
    });
  }

  @override
  Future<Result<void>> createLeave(String accessToken, LeaveDraft draft) {
    return guardApi(() async {
      await dio.post<void>(
        ApiEndpoints.applyLeave,
        data: {
          'type': _typeParam(draft.type),
          'from': _apiDate.format(draft.startDate),
          'to': _apiDate.format(draft.endDate),
          'days': draft.endDate.difference(draft.startDate).inDays + 1,
          'reason': draft.reason,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    });
  }

  static String _statusParam(LeaveStatus status) => switch (status) {
    LeaveStatus.pending => 'Pending',
    LeaveStatus.approved => 'Approved',
    LeaveStatus.rejected => 'Rejected',
    LeaveStatus.cancelled => 'Cancelled',
  };

  static String _typeParam(LeaveType type) => switch (type) {
    LeaveType.casual => 'Casual',
    LeaveType.sick => 'Sick',
    LeaveType.annual => 'Annual',
    LeaveType.family => 'Family',
    LeaveType.other => 'Other',
  };
}