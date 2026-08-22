import '../../../../core/result/result.dart';
import '../entities/feature.dart';

/// Contract implemented by the data layer.
abstract class FeatureRepository {
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