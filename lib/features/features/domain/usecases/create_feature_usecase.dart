import '../../../../core/result/result.dart';
import '../repositories/feature_repository.dart';

class CreateFeatureParams {
  const CreateFeatureParams({required this.accessToken, required this.name});
  final String accessToken;
  final String name;
}

class CreateFeatureUseCase {
  const CreateFeatureUseCase(this._repository);
  final FeatureRepository _repository;

  Future<Result<void>> call(CreateFeatureParams params) {
    return _repository.createFeature(accessToken: params.accessToken, name: params.name);
  }
}