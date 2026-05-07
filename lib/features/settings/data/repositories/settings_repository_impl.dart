import 'package:pos_desktop/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:pos_desktop/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:pos_desktop/features/settings/data/models/app_settings_model.dart';
import 'package:pos_desktop/features/settings/domain/entities/app_settings.dart';
import 'package:pos_desktop/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._localDatasource, this._remoteDatasource);

  final SettingsLocalDatasource _localDatasource;
  final SettingsRemoteDatasource _remoteDatasource;

  @override
  AppSettings getSettings() {
    return _localDatasource.getSettings();
  }

  @override
  AppSettings saveSettings(AppSettings settings) {
    return _localDatasource.saveSettings(
      AppSettingsModel.fromSettings(settings),
    );
  }

  @override
  AppSettings resetSettings() {
    return _localDatasource.resetSettings();
  }

  @override
  Future<void> testConnection(String baseUrl) {
    return _remoteDatasource.testConnection(baseUrl);
  }
}
