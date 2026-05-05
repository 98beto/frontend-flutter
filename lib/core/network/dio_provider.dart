import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/api_config.dart';
import 'package:pos_desktop/features/settings/presentation/providers/settings_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final settings = ref.watch(settingsProvider);

  return Dio(
    BaseOptions(
      baseUrl: settings.apiBaseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
});
