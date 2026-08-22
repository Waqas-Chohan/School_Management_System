import '../../domain/entities/feature.dart';
import '../models/feature_model.dart';

/// Mock data source used while the backend is unavailable.
abstract class FeatureMockDataSource {
  Future<List<Feature>> fetchFeatures();
  Future<void> createFeature({required String name});
  Future<void> updateFeature(Feature feature);
}

class FeatureMockDataSourceImpl implements FeatureMockDataSource {
  FeatureMockDataSourceImpl();

  final List<FeatureModel> _features = [
    FeatureModel(id: '1', name: 'Sample Feature', status: 'approved'),
  ];

  @override
  Future<List<Feature>> fetchFeatures() async {
    await _mockLatency();
    return List.unmodifiable(_features);
  }

  @override
  Future<void> createFeature({required String name}) async {
    await _mockLatency();
    _features.add(
      FeatureModel(id: '${_features.length + 1}', name: name, status: 'pending'),
    );
  }

  @override
  Future<void> updateFeature(Feature feature) async {
    await _mockLatency();
    final index = _features.indexWhere((f) => f.id == feature.id);
    if (index != -1) {
      _features[index] = FeatureModel.fromEntity(feature);
    }
  }

  Future<void> _mockLatency() {
    return Future<void>.delayed(const Duration(milliseconds: 250));
  }
}