import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/feature.dart';
import '../../domain/repositories/feature_repository.dart';
import '../datasources/feature_remote_data_source.dart';

/// Implements [FeatureRepository] using the configured data source.
class FeatureRepositoryImpl implements FeatureRepository {
  const FeatureRepositoryImpl(this._remoteDataSource);

  final FeatureRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Feature>>> fetchFeatures({
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to view features.'));
    }
    return _remoteDataSource.fetchFeatures(accessToken: accessToken);
  }

  @override
  Future<Result<void>> createFeature({
    required String accessToken,
    required String name,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to create a feature.'));
    }
    if (name.trim().isEmpty) {
      return const Failure(ValidationFailure('Feature name is required.'));
    }
    return _remoteDataSource.createFeature(accessToken: accessToken, name: name);
  }

  @override
  Future<Result<void>> updateFeature({
    required String accessToken,
    required Feature feature,
  }) async {
    if (accessToken.isEmpty) {
      return const Failure(UnauthorizedFailure('Please login to update a feature.'));
    }
    return _remoteDataSource.updateFeature(accessToken: accessToken, feature: feature);
  }
}