import 'package:dio/dio.dart';
import 'package:pos_desktop/core/network/api_envelope.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/features/auth/data/models/device_session_model.dart';

class AuthRemoteDatasource {
  const AuthRemoteDatasource(this._dio);

  final Dio _dio;

  Future<DeviceSessionModel> login({
    required String identifier,
    required String secret,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/device/login',
        data: {'identifier': identifier, 'secret': secret},
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => DeviceSessionModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/device/logout');
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  ApiException _mapDioException(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      return ApiException(
        message:
            responseData['message'] as String? ??
            'No fue posible conectar con la API.',
        statusCode: error.response?.statusCode,
        errors: responseData['errors'] as Map<String, dynamic>?,
      );
    }

    return ApiException(
      message: 'No fue posible conectar con la API.',
      statusCode: error.response?.statusCode,
    );
  }
}
