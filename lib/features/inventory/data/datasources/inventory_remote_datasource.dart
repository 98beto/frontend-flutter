import 'package:dio/dio.dart';
import 'package:pos_desktop/core/config/operation_context.dart';
import 'package:pos_desktop/core/network/api_envelope.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/inventory/data/models/inventory_movement_model.dart';
import 'package:pos_desktop/features/inventory/data/models/inventory_movement_request_model.dart';
import 'package:pos_desktop/features/products/data/models/product_record_model.dart';

class InventoryRemoteDatasource {
  const InventoryRemoteDatasource(this._dio, this._operationContext);

  final Dio _dio;
  final OperationContext _operationContext;

  Future<PaginatedResponse<InventoryMovementModel>> getMovements({
    int page = 1,
    int? productId,
    String? type,
    String? source,
  }) async {
    try {
      final response = await _dio.get(
        '/inventory/movements',
        queryParameters: {
          'page': page,
          'branch_id': _operationContext.branchId,
          'product_id': productId,
          if (type != null && type.isNotEmpty) 'type': type,
          if (source != null && source.isNotEmpty) 'source': source,
        },
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => PaginatedResponse.fromJson(
          raw as Map<String, dynamic>,
          InventoryMovementModel.fromJson,
        ),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<InventoryMovementModel> getMovementById(int id) async {
    try {
      final response = await _dio.get('/inventory/movements/$id');

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => InventoryMovementModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<InventoryMovementModel> createMovement(
    InventoryMovementRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/inventory/movements',
        data: request.toJson(),
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => InventoryMovementModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<PaginatedResponse<ProductRecordModel>> getLowStockProducts({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {
          'page': page,
          'low_stock': 1,
        },
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => PaginatedResponse.fromJson(
          raw as Map<String, dynamic>,
          ProductRecordModel.fromJson,
        ),
      );

      return envelope.data;
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
