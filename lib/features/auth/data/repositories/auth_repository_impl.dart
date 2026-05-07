import 'package:pos_desktop/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pos_desktop/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pos_desktop/features/auth/data/models/device_session_model.dart';
import 'package:pos_desktop/features/auth/domain/entities/device_session.dart';
import 'package:pos_desktop/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._localDatasource, this._remoteDatasource);

  final AuthLocalDatasource _localDatasource;
  final AuthRemoteDatasource _remoteDatasource;

  @override
  DeviceSession? getSession() {
    return _localDatasource.getSession();
  }

  @override
  DeviceSession saveSession(DeviceSession session) {
    return _localDatasource.saveSession(
      DeviceSessionModel.fromSession(session),
    );
  }

  @override
  Future<DeviceSession> login({
    required String identifier,
    required String secret,
  }) async {
    final session = await _remoteDatasource.login(
      identifier: identifier,
      secret: secret,
    );

    return _localDatasource.saveSession(session);
  }

  @override
  Future<bool> validateSession() async {
    final session = _localDatasource.getSession();
    if (session == null) {
      return false;
    }

    await _remoteDatasource.validateSession();
    return true;
  }

  @override
  Future<void> logout() async {
    await _remoteDatasource.logout();
    await _localDatasource.clearSession();
  }

  @override
  Future<void> clearSession() {
    return _localDatasource.clearSession();
  }
}
