import 'package:pos_desktop/core/network/api_config.dart';
import 'package:pos_desktop/features/settings/domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.branchId,
    required super.branchName,
    required super.deviceIdentifier,
    required super.deviceName,
    required super.apiBaseUrl,
    required super.defaultTaxRate,
    required super.defaultPaymentMethod,
    required super.themeMode,
  });

  static const branchIdKey = 'settings.branch_id';
  static const branchNameKey = 'settings.branch_name';
  static const deviceIdentifierKey = 'settings.device_identifier';
  static const deviceNameKey = 'settings.device_name';
  static const apiBaseUrlKey = 'settings.api_base_url';
  static const defaultTaxRateKey = 'settings.default_tax_rate';
  static const defaultPaymentMethodKey = 'settings.default_payment_method';
  static const themeModeKey = 'settings.theme_mode';

  factory AppSettingsModel.defaults() {
    return const AppSettingsModel(
      branchId: 1,
      branchName: '',
      deviceIdentifier: 'POS-01',
      deviceName: 'Caja principal',
      apiBaseUrl: ApiConfig.baseUrl,
      defaultTaxRate: 16,
      defaultPaymentMethod: 'cash',
      themeMode: 'system',
    );
  }

  factory AppSettingsModel.fromSettings(AppSettings settings) {
    return AppSettingsModel(
      branchId: settings.branchId,
      branchName: settings.branchName,
      deviceIdentifier: settings.deviceIdentifier,
      deviceName: settings.deviceName,
      apiBaseUrl: settings.apiBaseUrl,
      defaultTaxRate: settings.defaultTaxRate,
      defaultPaymentMethod: settings.defaultPaymentMethod,
      themeMode: settings.themeMode,
    );
  }
}
