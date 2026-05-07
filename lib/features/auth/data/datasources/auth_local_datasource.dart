import 'package:pos_desktop/features/auth/data/models/device_session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDatasource {
  const AuthLocalDatasource(this._sharedPreferences);

  static const lastIdentifierKey = 'auth.last_identifier';

  final SharedPreferences _sharedPreferences;

  String getLastIdentifier() {
    return _sharedPreferences.getString(lastIdentifierKey)?.trim() ?? '';
  }

  Future<void> saveLastIdentifier(String identifier) async {
    final normalized = identifier.trim();
    if (normalized.isEmpty) {
      await _sharedPreferences.remove(lastIdentifierKey);
      return;
    }

    await _sharedPreferences.setString(lastIdentifierKey, normalized);
  }

  DeviceSessionModel? getSession() {
    final token =
        _sharedPreferences.getString(DeviceSessionModel.tokenKey)?.trim() ?? '';
    if (token.isEmpty) {
      return null;
    }

    return DeviceSessionModel(
      token: token,
      deviceId: _sharedPreferences.getInt(DeviceSessionModel.deviceIdKey) ?? 0,
      branchId: _sharedPreferences.getInt(DeviceSessionModel.branchIdKey) ?? 0,
      deviceName:
          _sharedPreferences.getString(DeviceSessionModel.deviceNameKey) ?? '',
      deviceIdentifier:
          _sharedPreferences.getString(
            DeviceSessionModel.deviceIdentifierKey,
          ) ??
          '',
      branchName:
          _sharedPreferences.getString(DeviceSessionModel.branchNameKey) ?? '',
    );
  }

  DeviceSessionModel saveSession(DeviceSessionModel session) {
    _sharedPreferences.setString(DeviceSessionModel.tokenKey, session.token);
    _sharedPreferences.setInt(DeviceSessionModel.deviceIdKey, session.deviceId);
    _sharedPreferences.setInt(DeviceSessionModel.branchIdKey, session.branchId);
    _sharedPreferences.setString(
      DeviceSessionModel.deviceNameKey,
      session.deviceName,
    );
    _sharedPreferences.setString(
      DeviceSessionModel.deviceIdentifierKey,
      session.deviceIdentifier,
    );
    _sharedPreferences.setString(
      DeviceSessionModel.branchNameKey,
      session.branchName,
    );
    _sharedPreferences.setString(lastIdentifierKey, session.deviceIdentifier);
    return session;
  }

  Future<void> clearSession() async {
    await _sharedPreferences.remove(DeviceSessionModel.tokenKey);
    await _sharedPreferences.remove(DeviceSessionModel.deviceIdKey);
    await _sharedPreferences.remove(DeviceSessionModel.branchIdKey);
    await _sharedPreferences.remove(DeviceSessionModel.deviceNameKey);
    await _sharedPreferences.remove(DeviceSessionModel.deviceIdentifierKey);
    await _sharedPreferences.remove(DeviceSessionModel.branchNameKey);
  }
}
