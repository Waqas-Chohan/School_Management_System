import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/settings.dart';
import 'settings_data_source.dart';

/// Remote data source for the portal's settings / security endpoints.
class SettingsRemoteDataSourceImpl implements SettingsDataSource {
  SettingsRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<List<SettingsItem>> fetchItems() {
    throw UnimplementedError('Remote settings source not configured yet.');
  }

  @override
  Future<void> changePassword(
    String accessToken, {
    required String currentPassword,
    required String newPassword,
  }) async {
    await guardApi(() async {
      final response = await dio.put<Map<String, dynamic>>(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      // Surface `success: false` (thrown by unwrapEnvelope) as an AppFailure.
      unwrapEnvelope(response.data);
    });
  }
}