import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/auth/data/models/device_session_model.dart';
import 'package:pos_desktop/features/auth/domain/entities/device_session.dart';
import 'package:pos_desktop/features/auth/presentation/providers/auth_repository_provider.dart';

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, DeviceSession?>(
      AuthSessionNotifier.new,
    );

class AuthSessionNotifier extends Notifier<DeviceSession?> {
  @override
  DeviceSession? build() {
    return ref.watch(authLocalDatasourceProvider).getSession();
  }

  DeviceSession saveSession(DeviceSession session) {
    final savedSession = ref
        .read(authLocalDatasourceProvider)
        .saveSession(DeviceSessionModel.fromSession(session));
    state = savedSession;
    return savedSession;
  }

  Future<void> clearSession() async {
    await ref.read(authLocalDatasourceProvider).clearSession();
    state = null;
  }
}
