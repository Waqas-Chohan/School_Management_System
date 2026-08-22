import 'package:flutter_test/flutter_test.dart';

import 'package:school_management_system/features/features/data/models/feature_model.dart';

void main() {
  group('FeatureModel', () {
    test('fromJson parses correctly', () {
      final json = {'id': '1', 'name': 'Test', 'status': 'approved'};
      final model = FeatureModel.fromJson(json);
      expect(model.id, '1');
      expect(model.name, 'Test');
      expect(model.status, 'approved');
      expect(model.statusLabel, 'Approved');
    });

    test('fromJson defaults missing status to pending', () {
      final model = FeatureModel.fromJson({'id': '2', 'name': 'Test 2'});
      expect(model.status, 'pending');
      expect(model.statusLabel, 'Pending');
    });

    test('toJson serializes correctly', () {
      const model = FeatureModel(id: '1', name: 'Test', status: 'approved');
      final json = model.toJson();
      expect(json['id'], '1');
      expect(json['name'], 'Test');
      expect(json['status'], 'approved');
    });
  });
}