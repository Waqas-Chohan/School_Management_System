import '../../domain/entities/feature.dart';

/// Serializable DTO for [Feature].
class FeatureModel extends Feature {
  const FeatureModel({required super.id, required super.name, super.status});

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'status': status};
  }

  factory FeatureModel.fromEntity(Feature entity) {
    return FeatureModel(id: entity.id, name: entity.name, status: entity.status);
  }
}