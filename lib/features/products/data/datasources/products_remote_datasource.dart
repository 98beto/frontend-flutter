import 'package:dio/dio.dart';
import 'package:pos_desktop/core/network/api_envelope.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/products/data/models/product_category_model.dart';
import 'package:pos_desktop/features/products/data/models/product_record_model.dart';
import 'package:pos_desktop/features/products/data/models/product_upsert_request_model.dart';

class ProductsRemoteDatasource {
  const ProductsRemoteDatasource(this._dio);

  final Dio _dio;

  Future<PaginatedResponse<ProductRecordModel>> getProducts({
    int page = 1,
    String? search,
    int? categoryId,
    bool? isActive,
    bool lowStockOnly = false,
  }) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {
          'page': page,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          'category_id': categoryId,
          'is_active': isActive == null ? null : (isActive ? 1 : 0),
          if (lowStockOnly) 'low_stock': 1,
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

  Future<List<ProductCategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/categories');

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) {
          if (raw is Map<String, dynamic>) {
            return PaginatedResponse.fromJson(raw, ProductCategoryModel.fromJson).items;
          }
          if (raw is List<dynamic>) {
            return raw
                .map((item) => ProductCategoryModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <ProductCategoryModel>[];
        },
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<ProductRecordModel> getProductById(int id) async {
    try {
      final response = await _dio.get('/products/$id');

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => ProductRecordModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<ProductRecordModel> createProduct(ProductUpsertRequestModel request) async {
    try {
      final response = await _dio.post('/products', data: request.toJson());

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => ProductRecordModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<ProductRecordModel> updateProduct(
    int id,
    ProductUpsertRequestModel request,
  ) async {
    try {
      final response = await _dio.patch('/products/$id', data: request.toJson());

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => ProductRecordModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('/products/$id');
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
