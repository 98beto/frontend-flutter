class DeviceSession {
  const DeviceSession({
    required this.token,
    required this.deviceId,
    required this.branchId,
    required this.deviceName,
    required this.deviceIdentifier,
    required this.branchName,
  });

  final String token;
  final int deviceId;
  final int branchId;
  final String deviceName;
  final String deviceIdentifier;
  final String branchName;

  bool get isAuthenticated => token.trim().isNotEmpty;
}
