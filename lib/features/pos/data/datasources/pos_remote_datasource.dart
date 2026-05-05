import 'package:dio/dio.dart';
import 'package:pos_desktop/core/config/operation_context.dart';
import 'package:pos_desktop/core/network/api_envelope.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/pos/data/models/cash_session_model.dart';
import 'package:pos_desktop/features/pos/data/models/category_model.dart';
import 'package:pos_desktop/features/pos/data/models/product_model.dart';
import 'package:pos_desktop/features/pos/data/models/saved_cart_model.dart';
import 'package:pos_desktop/features/pos/data/models/saved_cart_request_model.dart';
import 'package:pos_desktop/features/pos/data/models/sale_request_model.dart';
import 'package:pos_desktop/features/pos/data/models/sale_response_model.dart';

class PosRemoteDatasource {
  const PosRemoteDatasource(this._dio, this._operationContext);

  final Dio _dio;
  final OperationContext _operationContext;

  Future<PaginatedResponse<ProductModel>> getProducts({
    int page = 1,
    String? search,
    int? categoryId,
  }) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {
          'page': page,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          'category_id': categoryId,
        },
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => PaginatedResponse.fromJson(
          raw as Map<String, dynamic>,
          ProductModel.fromJson,
        ),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/categories');

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) {
          if (raw is Map<String, dynamic>) {
            return PaginatedResponse.fromJson(raw, CategoryModel.fromJson).items;
          }
          if (raw is List<dynamic>) {
            return raw
                .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <CategoryModel>[];
        },
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<CashSessionModel?> getCurrentCashSession() async {
    try {
      final response = await _dio.get(
        '/cash-sessions/current',
        queryParameters: {
          'branch_id': _operationContext.branchId,
          'device_identifier': _operationContext.deviceIdentifier,
        },
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => CashSessionModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }

      throw _mapDioException(error);
    }
  }

  Future<SaleResponseModel> createSale(SaleRequestModel request) async {
    try {
      final response = await _dio.post('/sales', data: request.toJson());

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => SaleResponseModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<PaginatedResponse<SavedCartModel>> getSavedCarts() async {
    try {
      final response = await _dio.get(
        '/saved-carts',
        queryParameters: {'branch_id': _operationContext.branchId},
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => PaginatedResponse.fromJson(
          raw as Map<String, dynamic>,
          SavedCartModel.fromJson,
        ),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<SavedCartModel> createSavedCart(SavedCartRequestModel request) async {
    try {
      final response = await _dio.post('/saved-carts', data: request.toJson());

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => SavedCartModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<SavedCartModel> recoverSavedCart(String id) async {
    try {
      final response = await _dio.patch(
        '/saved-carts/$id/recover',
        queryParameters: {'branch_id': _operationContext.branchId},
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => SavedCartModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<SavedCartModel> updateSavedCart(
    String id,
    SavedCartRequestModel request,
  ) async {
    try {
      final response = await _dio.patch('/saved-carts/$id', data: request.toJson());

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => SavedCartModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<void> deleteSavedCart(String id) async {
    try {
      await _dio.delete('/saved-carts/$id');
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
