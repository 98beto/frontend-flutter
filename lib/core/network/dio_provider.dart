import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/api_config.dart';
import 'package:pos_desktop/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:pos_desktop/features/settings/presentation/providers/settings_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final session = ref.watch(authSessionProvider);
  final settings = ref.watch(settingsProvider);

  final headers = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  final token = session?.token.trim() ?? '';
  if (token.isNotEmpty) {
    headers['Authorization'] = 'Bearer $token';
  }

  return Dio(
    BaseOptions(
      baseUrl: settings.apiBaseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: headers,
    ),
  );
});
