class AppSettings {
  const AppSettings({
    required this.apiBaseUrl,
    required this.defaultTaxRate,
    required this.defaultPaymentMethod,
    required this.themeMode,
  });

  final String apiBaseUrl;
  final double defaultTaxRate;
  final String defaultPaymentMethod;
  final String themeMode;

  AppSettings copyWith({
    String? apiBaseUrl,
    double? defaultTaxRate,
    String? defaultPaymentMethod,
    String? themeMode,
  }) {
    return AppSettings(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AppSettings &&
        other.apiBaseUrl == apiBaseUrl &&
        other.defaultTaxRate == defaultTaxRate &&
        other.defaultPaymentMethod == defaultPaymentMethod &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode =>
      Object.hash(apiBaseUrl, defaultTaxRate, defaultPaymentMethod, themeMode);
}
