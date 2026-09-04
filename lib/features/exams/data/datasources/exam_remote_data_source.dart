import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/exam.dart';
import 'exam_data_source.dart';

/// Remote exams / datesheet data source backed by the SMS portal:
/// - `GET /teacher-portal/exams`
/// - `GET /teacher-portal/datesheets?classId=`
class ExamRemoteDataSourceImpl implements ExamDataSource {
  ExamRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<Result<ExamOverview>> fetchExams(String accessToken) async {
    return guardApi(() async {
      final response = await dio.get<dynamic>(
        ApiEndpoints.exams,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final data = envelopeMap(response.data);
      final activeJson = _mapList(data['active']);
      final upcomingJson = _mapList(data['upcoming']);
      final completedJson = _mapList(data['completed']);
      final dsJson = _mapList(data['datesheets']);

      final overview = ExamOverview(
        active: activeJson.map(Exam.fromJson).toList(),
        upcoming: upcomingJson.map(Exam.fromJson).toList(),
        completed: completedJson.map(Exam.fromJson).toList(),
        datesheets: dsJson.map(DateSheet.fromJson).toList(),
      );
      return overview;
    });
  }

  @override
  Future<Result<List<DateSheet>>> fetchDateSheets(
    String accessToken, {
    String? classId,
  }) async {
    return guardApi(() async {
      final response = await dio.get<dynamic>(
        ApiEndpoints.datesheets,
        queryParameters: {
          if (classId != null && classId.isNotEmpty) 'classId': classId,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final data = envelopeList(response.data);
      final sheets = data
          .whereType<Map>()
          .map((e) => DateSheet.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return sheets;
    });
  }

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    // Sometimes the server wraps the list under a `datesheets`/`exams` key.
    if (value is Map) {
      for (final key in const ['exams', 'datesheets', 'items', 'list']) {
        final val = value[key];
        if (val is List) {
          return val
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }
    return const [];
  }
}