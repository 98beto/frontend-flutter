import 'package:pos_desktop/features/auth/domain/entities/device_session.dart';

class DeviceSessionModel extends DeviceSession {
  const DeviceSessionModel({
    required super.token,
    required super.deviceId,
    required super.branchId,
    required super.deviceName,
    required super.deviceIdentifier,
    required super.branchName,
  });

  static const tokenKey = 'auth.token';
  static const deviceIdKey = 'auth.device_id';
  static const branchIdKey = 'auth.branch_id';
  static const deviceNameKey = 'auth.device_name';
  static const deviceIdentifierKey = 'auth.device_identifier';
  static const branchNameKey = 'auth.branch_name';

  factory DeviceSessionModel.fromSession(DeviceSession session) {
    return DeviceSessionModel(
      token: session.token,
      deviceId: session.deviceId,
      branchId: session.branchId,
      deviceName: session.deviceName,
      deviceIdentifier: session.deviceIdentifier,
      branchName: session.branchName,
    );
  }

  factory DeviceSessionModel.fromJson(Map<String, dynamic> json) {
    final device = json['device'] as Map<String, dynamic>? ?? const {};
    final branch = device['branch'] as Map<String, dynamic>? ?? const {};

    return DeviceSessionModel(
      token: json['token'] as String? ?? '',
      deviceId: _toInt(device['id']),
      branchId: _toInt(device['branch_id']),
      deviceName: device['name'] as String? ?? '',
      deviceIdentifier: device['identifier'] as String? ?? '',
      branchName: branch['name'] as String? ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
