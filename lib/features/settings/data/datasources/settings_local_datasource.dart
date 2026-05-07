import 'package:pos_desktop/features/settings/data/models/app_settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalDatasource {
  const SettingsLocalDatasource(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  AppSettingsModel getSettings() {
    final defaults = AppSettingsModel.defaults();

    return AppSettingsModel(
      apiBaseUrl:
          _sharedPreferences.getString(AppSettingsModel.apiBaseUrlKey) ??
          defaults.apiBaseUrl,
      defaultTaxRate:
          _sharedPreferences.getDouble(AppSettingsModel.defaultTaxRateKey) ??
          defaults.defaultTaxRate,
      defaultPaymentMethod:
          _sharedPreferences.getString(
            AppSettingsModel.defaultPaymentMethodKey,
          ) ??
          defaults.defaultPaymentMethod,
      themeMode:
          _sharedPreferences.getString(AppSettingsModel.themeModeKey) ??
          defaults.themeMode,
    );
  }

  AppSettingsModel saveSettings(AppSettingsModel settings) {
    _sharedPreferences.setString(
      AppSettingsModel.apiBaseUrlKey,
      settings.apiBaseUrl,
    );
    _sharedPreferences.setDouble(
      AppSettingsModel.defaultTaxRateKey,
      settings.defaultTaxRate,
    );
    _sharedPreferences.setString(
      AppSettingsModel.defaultPaymentMethodKey,
      settings.defaultPaymentMethod,
    );
    _sharedPreferences.setString(
      AppSettingsModel.themeModeKey,
      settings.themeMode,
    );

    return settings;
  }

  AppSettingsModel resetSettings() {
    _sharedPreferences.remove(AppSettingsModel.apiBaseUrlKey);
    _sharedPreferences.remove(AppSettingsModel.defaultTaxRateKey);
    _sharedPreferences.remove(AppSettingsModel.defaultPaymentMethodKey);
    _sharedPreferences.remove(AppSettingsModel.themeModeKey);

    return getSettings();
  }
}
