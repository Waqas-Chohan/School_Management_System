import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/teacher_profile.dart';
import '../models/teacher_profile_model.dart';
import 'profile_data_source.dart';

/// Remote profile data source backed by the SMS portal (`/teacher-portal/profile`).
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
      final payload = envelopeMap(response.data);
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

  @override
  Future<Result<void>> updateProfile(String accessToken, ProfileUpdate update) {
    return guardApi(() async {
      await dio.put<void>(
        ApiEndpoints.profile,
        data: update.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    });
  }

  @override
  Future<Result<void>> updateNotifications(
    String accessToken, {
    required bool enabled,
  }) {
    return guardApi(() async {
      await dio.put<void>(
        ApiEndpoints.notifications,
        data: {'pushNotificationsEnabled': enabled},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    });
  }

  @override
  Future<Result<String>> uploadAvatar(
    String accessToken, {
    required String filePath,
  }) {
    return guardApi(() async {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.uploadAvatar,
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final payload = envelopeMap(response.data);
      final url = payload['url']?.toString() ?? payload['path']?.toString() ?? '';
      if (url.isEmpty) {
        throw UnknownFailure('Upload succeeded but no url was returned.');
      }
      return url;
    });
  }
}