import '../../domain/entities/settings.dart';
import 'settings_data_source.dart';

/// Remote data source (reserved for the real API; see master prompt §10).
class SettingsRemoteDataSourceImpl implements SettingsDataSource {
  SettingsRemoteDataSourceImpl();

  @override
  Future<List<SettingsItem>> fetchItems() {
    throw UnimplementedError('Remote settings source not configured yet.');
  }
}