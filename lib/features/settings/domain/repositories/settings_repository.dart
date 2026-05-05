import 'package:pos_desktop/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  AppSettings getSettings();

  AppSettings saveSettings(AppSettings settings);

  AppSettings resetSettings();

  Future<void> testConnection(String baseUrl);
}
