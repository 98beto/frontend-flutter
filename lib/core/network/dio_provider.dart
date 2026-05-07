import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/api_config.dart';
import 'package:pos_desktop/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:pos_desktop/features/settings/presentation/providers/settings_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final session = ref.watch(authSessionProvider);
  final settings = ref.watch(settingsProvider);
  var didHandleUnauthorized = false;

  final headers = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  final token = session?.token.trim() ?? '';
  if (token.isNotEmpty) {
    headers['Authorization'] = 'Bearer $token';
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: settings.apiBaseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: headers,
    ),
  );

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onError: (error, handler) async {
        final path = error.requestOptions.path;
        final isUnauthorized = error.response?.statusCode == 401;
        final isLoginRequest = path == '/auth/device/login';

        if (
          isUnauthorized &&
          !isLoginRequest &&
          !didHandleUnauthorized &&
          session?.isAuthenticated == true
        ) {
          didHandleUnauthorized = true;
          await ref.read(authSessionProvider.notifier).clearSession();
        }

        handler.next(error);
      },
    ),
  );

  return dio;
});
