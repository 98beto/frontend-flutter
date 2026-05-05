import 'package:dio/dio.dart';
import 'package:pos_desktop/core/config/operation_context.dart';
import 'package:pos_desktop/core/network/api_envelope.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/cash_register/data/models/cash_session_history_item_model.dart';
import 'package:pos_desktop/features/cash_register/data/models/cash_movement_model.dart';
import 'package:pos_desktop/features/cash_register/data/models/cash_movement_request_model.dart';
import 'package:pos_desktop/features/cash_register/data/models/cash_close_result_model.dart';
import 'package:pos_desktop/features/cash_register/data/models/close_cash_request_model.dart';
import 'package:pos_desktop/features/cash_register/data/models/open_cash_request_model.dart';
import 'package:pos_desktop/features/pos/data/models/cash_session_model.dart';

class CashRegisterRemoteDatasource {
  const CashRegisterRemoteDatasource(this._dio, this._operationContext);

  final Dio _dio;
  final OperationContext _operationContext;

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

  Future<CashSessionModel> openCashSession(OpenCashRequestModel request) async {
    try {
      final response = await _dio.post(
        '/cash-sessions/open',
        data: request.toJson(),
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => CashSessionModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<CashCloseResultModel> closeCashSession(
    int id,
    CloseCashRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/cash-sessions/$id/close',
        data: request.toJson(),
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => CashCloseResultModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<void> createCashMovement(int id, CashMovementRequestModel request) async {
    try {
      await _dio.post('/cash-sessions/$id/movements', data: request.toJson());
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<PaginatedResponse<CashSessionHistoryItemModel>> getCashSessions({
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/cash-sessions',
        queryParameters: {
          'page': page,
          'branch_id': _operationContext.branchId,
        },
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => PaginatedResponse.fromJson(
          raw as Map<String, dynamic>,
          CashSessionHistoryItemModel.fromJson,
        ),
      );

      return envelope.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  Future<PaginatedResponse<CashMovementModel>> getCashMovements(
    int id, {
    int page = 1,
    String? type,
    String? category,
    String? source,
  }) async {
    try {
      final response = await _dio.get(
        '/cash-sessions/$id/movements',
        queryParameters: {
          'page': page,
          if (type != null && type.isNotEmpty) 'type': type,
          if (category != null && category.isNotEmpty) 'category': category,
          if (source != null && source.isNotEmpty) 'source': source,
        },
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => PaginatedResponse.fromJson(
          raw as Map<String, dynamic>,
          CashMovementModel.fromJson,
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
