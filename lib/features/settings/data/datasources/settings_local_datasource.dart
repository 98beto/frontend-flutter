import 'package:pos_desktop/features/settings/data/models/app_settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalDatasource {
  const SettingsLocalDatasource(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  AppSettingsModel getSettings() {
    final defaults = AppSettingsModel.defaults();

    return AppSettingsModel(
      branchId: _sharedPreferences.getInt(AppSettingsModel.branchIdKey) ??
          defaults.branchId,
      branchName:
          _sharedPreferences.getString(AppSettingsModel.branchNameKey) ??
          defaults.branchName,
      deviceIdentifier: _sharedPreferences
              .getString(AppSettingsModel.deviceIdentifierKey) ??
          defaults.deviceIdentifier,
      deviceName: _sharedPreferences.getString(AppSettingsModel.deviceNameKey) ??
          defaults.deviceName,
      apiBaseUrl: _sharedPreferences.getString(AppSettingsModel.apiBaseUrlKey) ??
          defaults.apiBaseUrl,
      defaultTaxRate: _sharedPreferences
              .getDouble(AppSettingsModel.defaultTaxRateKey) ??
          defaults.defaultTaxRate,
      defaultPaymentMethod: _sharedPreferences
              .getString(AppSettingsModel.defaultPaymentMethodKey) ??
          defaults.defaultPaymentMethod,
      themeMode: _sharedPreferences.getString(AppSettingsModel.themeModeKey) ??
          defaults.themeMode,
    );
  }

  AppSettingsModel saveSettings(AppSettingsModel settings) {
    _sharedPreferences.setInt(AppSettingsModel.branchIdKey, settings.branchId);
    _sharedPreferences.setString(
      AppSettingsModel.branchNameKey,
      settings.branchName,
    );
    _sharedPreferences.setString(
      AppSettingsModel.deviceIdentifierKey,
      settings.deviceIdentifier,
    );
    _sharedPreferences.setString(
      AppSettingsModel.deviceNameKey,
      settings.deviceName,
    );
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
    _sharedPreferences.remove(AppSettingsModel.branchIdKey);
    _sharedPreferences.remove(AppSettingsModel.branchNameKey);
    _sharedPreferences.remove(AppSettingsModel.deviceIdentifierKey);
    _sharedPreferences.remove(AppSettingsModel.deviceNameKey);
    _sharedPreferences.remove(AppSettingsModel.apiBaseUrlKey);
    _sharedPreferences.remove(AppSettingsModel.defaultTaxRateKey);
    _sharedPreferences.remove(AppSettingsModel.defaultPaymentMethodKey);
    _sharedPreferences.remove(AppSettingsModel.themeModeKey);

    return getSettings();
  }
}
