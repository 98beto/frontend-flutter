class AppSettings {
  const AppSettings({
    required this.branchId,
    required this.branchName,
    required this.deviceIdentifier,
    required this.deviceName,
    required this.apiBaseUrl,
    required this.defaultTaxRate,
    required this.defaultPaymentMethod,
    required this.themeMode,
  });

  final int branchId;
  final String branchName;
  final String deviceIdentifier;
  final String deviceName;
  final String apiBaseUrl;
  final double defaultTaxRate;
  final String defaultPaymentMethod;
  final String themeMode;

  AppSettings copyWith({
    int? branchId,
    String? branchName,
    String? deviceIdentifier,
    String? deviceName,
    String? apiBaseUrl,
    double? defaultTaxRate,
    String? defaultPaymentMethod,
    String? themeMode,
  }) {
    return AppSettings(
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
      deviceName: deviceName ?? this.deviceName,
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
        other.branchId == branchId &&
        other.branchName == branchName &&
        other.deviceIdentifier == deviceIdentifier &&
        other.deviceName == deviceName &&
        other.apiBaseUrl == apiBaseUrl &&
        other.defaultTaxRate == defaultTaxRate &&
        other.defaultPaymentMethod == defaultPaymentMethod &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode => Object.hash(
    branchId,
    branchName,
    deviceIdentifier,
    deviceName,
    apiBaseUrl,
    defaultTaxRate,
    defaultPaymentMethod,
    themeMode,
  );
}
