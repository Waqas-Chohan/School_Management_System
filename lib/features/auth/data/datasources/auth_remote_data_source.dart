import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/auth_session.dart';
import '../models/auth_session_model.dart';

/// Remote authentication data source backed by [Dio].
abstract class AuthRemoteDataSource {
  Future<Result<AuthSession>> login({
    required String username,
    required String password,
  });

  Future<Result<void>> logout({required String accessToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<Result<AuthSession>> login({
    required String username,
    required String password,
  }) {
    return guardApi(() async {
      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );
      final payload = (response.data ?? const <String, dynamic>{}).cast<String, dynamic>();
      return AuthSessionModel.fromJson(payload);
    });
  }

  @override
  Future<Result<void>> logout({required String accessToken}) {
    return guardApi(() async {
      await dio.post<void>(
        ApiEndpoints.logout,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    });
  }
}