import 'package:dio/dio.dart';
import 'package:pos_desktop/core/network/api_envelope.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/clients/data/models/client_record_model.dart';
import 'package:pos_desktop/features/clients/data/models/client_upsert_request_model.dart';

class ClientsRemoteDatasource {
  const ClientsRemoteDatasource(this._dio);

  final Dio _dio;

  Future<PaginatedResponse<ClientRecordModel>> getClients({
    int page = 1,
    String? search,
  }) async {
    try {
      final response = await _dio.get(
        '/customers',
        queryParameters: {
          'page': page,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => PaginatedResponse.fromJson(
          raw as Map<String, dynamic>,
          ClientRecordModel.fromJson,
        ),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<ClientRecordModel> createClient(ClientUpsertRequestModel request) async {
    try {
      final response = await _dio.post('/customers', data: request.toJson());

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => ClientRecordModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<ClientRecordModel> updateClient(
    int id,
    ClientUpsertRequestModel request,
  ) async {
    try {
      final response = await _dio.patch('/customers/$id', data: request.toJson());

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => ClientRecordModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      await _dio.delete('/customers/$id');
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  ApiException _mapDioException(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      return ApiException(
        message:
            responseData['message'] as String? ?? 'No fue posible conectar con la API.',
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
