import 'package:dio/dio.dart';
import 'package:pos_desktop/core/config/operation_context.dart';
import 'package:pos_desktop/core/network/api_envelope.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/sales/data/models/sale_detail_model.dart';
import 'package:pos_desktop/features/sales/data/models/sale_list_item_model.dart';

class SalesRemoteDatasource {
  const SalesRemoteDatasource(this._dio, this._operationContext);

  final Dio _dio;
  final OperationContext _operationContext;

  Future<PaginatedResponse<SaleListItemModel>> getSales({
    int page = 1,
    String? search,
    String? paymentMethod,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final response = await _dio.get(
        '/sales',
        queryParameters: {
          'page': page,
          'branch_id': _operationContext.branchId,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          if (paymentMethod != null && paymentMethod.isNotEmpty)
            'payment_method': paymentMethod,
          if (dateFrom != null) 'date_from': _formatDate(dateFrom),
          if (dateTo != null) 'date_to': _formatDate(dateTo),
        },
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => PaginatedResponse.fromJson(
          raw as Map<String, dynamic>,
          SaleListItemModel.fromJson,
        ),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<SaleDetailModel> getSaleById(int id) async {
    try {
      final response = await _dio.get('/sales/$id');

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => SaleDetailModel.fromJson(raw as Map<String, dynamic>),
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

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
