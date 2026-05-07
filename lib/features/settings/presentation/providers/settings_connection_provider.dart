import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/features/settings/presentation/providers/settings_repository_provider.dart';

enum SettingsConnectionStateType { idle, testing, success, failure, invalidUrl }

class SettingsConnectionState {
  const SettingsConnectionState({
    required this.type,
    this.message,
    this.lastCheckedAt,
  });

  const SettingsConnectionState.idle()
    : this(type: SettingsConnectionStateType.idle);

  const SettingsConnectionState.testing()
    : this(type: SettingsConnectionStateType.testing);

  const SettingsConnectionState.success(DateTime checkedAt)
    : this(type: SettingsConnectionStateType.success, lastCheckedAt: checkedAt);

  const SettingsConnectionState.failure({String? message, DateTime? checkedAt})
    : this(
        type: SettingsConnectionStateType.failure,
        message: message,
        lastCheckedAt: checkedAt,
      );

  const SettingsConnectionState.invalidUrl({String? message})
    : this(type: SettingsConnectionStateType.invalidUrl, message: message);

  final SettingsConnectionStateType type;
  final String? message;
  final DateTime? lastCheckedAt;

  bool get isTesting => type == SettingsConnectionStateType.testing;
}

final settingsConnectionProvider =
    NotifierProvider<SettingsConnectionNotifier, SettingsConnectionState>(
      SettingsConnectionNotifier.new,
    );

class SettingsConnectionNotifier extends Notifier<SettingsConnectionState> {
  @override
  SettingsConnectionState build() {
    return const SettingsConnectionState.idle();
  }

  Future<void> testConnection(String baseUrl) async {
    final trimmedBaseUrl = baseUrl.trim();
    final uri = Uri.tryParse(trimmedBaseUrl);
    if (trimmedBaseUrl.isEmpty ||
        uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty) {
      state = const SettingsConnectionState.invalidUrl(
        message: 'Ingresa una URL valida. Ejemplo: http://127.0.0.1:8000/api',
      );
      return;
    }

    state = const SettingsConnectionState.testing();

    try {
      await ref.read(settingsRepositoryProvider).testConnection(trimmedBaseUrl);
      state = SettingsConnectionState.success(DateTime.now());
    } on ApiException catch (error) {
      state = SettingsConnectionState.failure(
        message: error.message,
        checkedAt: DateTime.now(),
      );
    } catch (_) {
      state = SettingsConnectionState.failure(
        message: 'No fue posible conectar con la API.',
        checkedAt: DateTime.now(),
      );
    }
  }

  void markAsUntested() {
    if (state.type == SettingsConnectionStateType.idle) {
      return;
    }

    state = const SettingsConnectionState.idle();
  }
}
