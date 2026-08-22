import '../../domain/entities/settings.dart';

/// Common contract implemented by the mock and remote settings data sources so
/// the repository can swap between them with a one-line provider change.
abstract class SettingsDataSource {
  Future<List<SettingsItem>> fetchItems();
}