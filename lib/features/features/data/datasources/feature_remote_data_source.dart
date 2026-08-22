import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/feature.dart';
import '../models/feature_model.dart';

/// Remote data source backed by [Dio].
abstract class FeatureRemoteDataSource {
  Future<Result<List<Feature>>> fetchFeatures({required String accessToken});
  Future<Result<void>> createFeature({
    required String accessToken,
    required String name,
  });
  Future<Result<void>> updateFeature({
    required String accessToken,
    required Feature feature,
  });
}

class FeatureRemoteDataSourceImpl implements FeatureRemoteDataSource {
  FeatureRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<Result<List<Feature>>> fetchFeatures({
    required String accessToken,
  }) {
    return guardApi(() async {
      final response = await dio.get<List<dynamic>>(
        ApiEndpoints.features,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final list = response.data ?? const <dynamic>[];
      return list
          .map((e) => FeatureModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    });
  }

  @override
  Future<Result<void>> createFeature({
    required String accessToken,
    required String name,
  }) {
    return guardApi(() async {
      await dio.post<void>(
        ApiEndpoints.features,
        data: {'name': name},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    });
  }

  @override
  Future<Result<void>> updateFeature({
    required String accessToken,
    required Feature feature,
  }) {
    return guardApi(() async {
      await dio.put<void>(
        '${ApiEndpoints.features}/${feature.id}',
        data: FeatureModel.fromEntity(feature).toJson(),
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    });
  }
}