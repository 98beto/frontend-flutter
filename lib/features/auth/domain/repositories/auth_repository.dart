import 'package:pos_desktop/features/auth/domain/entities/device_session.dart';

abstract class AuthRepository {
  DeviceSession? getSession();

  DeviceSession saveSession(DeviceSession session);

  Future<DeviceSession> login({
    required String identifier,
    required String secret,
  });

  Future<bool> validateSession();

  Future<void> logout();

  Future<void> clearSession();
}
