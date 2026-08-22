import '../../../../core/result/result.dart';
import '../entities/feature.dart';
import '../repositories/feature_repository.dart';

class GetFeaturesParams {
  const GetFeaturesParams({required this.accessToken});
  final String accessToken;
}

class GetFeaturesUseCase {
  const GetFeaturesUseCase(this._repository);
  final FeatureRepository _repository;

  Future<Result<List<Feature>>> call(GetFeaturesParams params) {
    return _repository.fetchFeatures(accessToken: params.accessToken);
  }
}