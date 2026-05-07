import 'package:dio/dio.dart';
import 'package:pos_desktop/core/network/api_exception.dart';

class SettingsRemoteDatasource {
  const SettingsRemoteDatasource();

  Future<void> testConnection(String baseUrl) async {
    final normalizedBaseUrl = _normalizeBaseUrl(baseUrl);
    final dio = Dio(
      BaseOptions(
        baseUrl: normalizedBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    try {
      await dio.get('/auth/device/me');
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        return;
      }

      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        throw ApiException(
          message:
              responseData['message'] as String? ??
              'No fue posible conectar con la API.',
          statusCode: error.response?.statusCode,
          errors: responseData['errors'] as Map<String, dynamic>?,
        );
      }

      throw ApiException(
        message: 'No fue posible conectar con la API.',
        statusCode: error.response?.statusCode,
      );
    }
  }

  String _normalizeBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim();
    final uri = Uri.tryParse(trimmed);
    if (trimmed.isEmpty || uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const ApiException(message: 'Ingresa una URL valida para la API.');
    }

    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
