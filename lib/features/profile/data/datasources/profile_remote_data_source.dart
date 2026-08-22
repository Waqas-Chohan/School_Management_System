import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/teacher_profile.dart';
import '../models/teacher_profile_model.dart';
import 'profile_data_source.dart';

/// Remote profile data source backed by [Dio].
class ProfileRemoteDataSourceImpl implements ProfileDataSource {
  ProfileRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<Result<TeacherProfile>> fetchProfile(String accessToken) {
    return guardApi(() async {
      final response = await dio.get<Map<String, dynamic>>(
        ApiEndpoints.profile,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final payload = (response.data ?? const <String, dynamic>{})
          .cast<String, dynamic>();
      return TeacherProfileModel.fromJson(payload);
    });
  }

  @override
  Future<Result<void>> updatePhone(String accessToken, String phone) {
    return guardApi(() async {
      await dio.put<void>(
        ApiEndpoints.profile,
        data: {'phone': phone},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    });
  }
}