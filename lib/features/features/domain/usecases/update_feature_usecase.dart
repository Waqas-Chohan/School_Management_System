import '../../../../core/result/result.dart';
import '../entities/feature.dart';
import '../repositories/feature_repository.dart';

class UpdateFeatureParams {
  const UpdateFeatureParams({required this.accessToken, required this.feature});
  final String accessToken;
  final Feature feature;
}

class UpdateFeatureUseCase {
  const UpdateFeatureUseCase(this._repository);
  final FeatureRepository _repository;

  Future<Result<void>> call(UpdateFeatureParams params) {
    return _repository.updateFeature(
      accessToken: params.accessToken,
      feature: params.feature,
    );
  }
}