import 'package:dio/dio.dart';
import 'package:pos_desktop/core/network/api_envelope.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/suppliers/data/models/supplier_record_model.dart';
import 'package:pos_desktop/features/suppliers/data/models/supplier_upsert_request_model.dart';

class SuppliersRemoteDatasource {
  const SuppliersRemoteDatasource(this._dio);

  final Dio _dio;

  Future<PaginatedResponse<SupplierRecordModel>> getSuppliers({
    int page = 1,
    String? search,
  }) async {
    try {
      final response = await _dio.get(
        '/suppliers',
        queryParameters: {
          'page': page,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => PaginatedResponse.fromJson(
          raw as Map<String, dynamic>,
          SupplierRecordModel.fromJson,
        ),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<SupplierRecordModel> createSupplier(SupplierUpsertRequestModel request) async {
    try {
      final response = await _dio.post('/suppliers', data: request.toJson());

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => SupplierRecordModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<SupplierRecordModel> updateSupplier(
    int id,
    SupplierUpsertRequestModel request,
  ) async {
    try {
      final response = await _dio.patch('/suppliers/$id', data: request.toJson());

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => SupplierRecordModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await _dio.delete('/suppliers/$id');
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
