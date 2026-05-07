import 'package:pos_desktop/core/network/api_config.dart';
import 'package:pos_desktop/features/settings/domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.apiBaseUrl,
    required super.defaultTaxRate,
    required super.defaultPaymentMethod,
    required super.themeMode,
  });

  static const apiBaseUrlKey = 'settings.api_base_url';
  static const defaultTaxRateKey = 'settings.default_tax_rate';
  static const defaultPaymentMethodKey = 'settings.default_payment_method';
  static const themeModeKey = 'settings.theme_mode';

  factory AppSettingsModel.defaults() {
    return const AppSettingsModel(
      apiBaseUrl: ApiConfig.baseUrl,
      defaultTaxRate: 16,
      defaultPaymentMethod: 'cash',
      themeMode: 'system',
    );
  }

  factory AppSettingsModel.fromSettings(AppSettings settings) {
    return AppSettingsModel(
      apiBaseUrl: settings.apiBaseUrl,
      defaultTaxRate: settings.defaultTaxRate,
      defaultPaymentMethod: settings.defaultPaymentMethod,
      themeMode: settings.themeMode,
    );
  }
}
