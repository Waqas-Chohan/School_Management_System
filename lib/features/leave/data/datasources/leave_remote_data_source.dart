import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/leave.dart';
import '../models/leave_model.dart';
import 'leave_data_source.dart';

/// Remote leave data source backed by [Dio].
class LeaveRemoteDataSourceImpl implements LeaveDataSource {
  LeaveRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<Result<List<LeaveRequest>>> fetchLeaves(
    String accessToken, {
    LeaveStatus? filter,
  }) {
    return guardApi(() async {
      final response = await dio.get<List<dynamic>>(
        ApiEndpoints.leaveRequests,
        queryParameters: filter == null
            ? null
            : {'status': filter.name},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final list = response.data ?? const <dynamic>[];
      return list
          .map((e) => LeaveModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    });
  }

  @override
  Future<Result<void>> createLeave(String accessToken, LeaveDraft draft) {
    return guardApi(() async {
      await dio.post<void>(
        ApiEndpoints.applyLeave,
        data: {
          'type': draft.type.name,
          'mode': draft.mode.name,
          'start_date': draft.startDate.toIso8601String(),
          'end_date': draft.endDate.toIso8601String(),
          'reason': draft.reason,
          'attachments': draft.attachments,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    });
  }
}