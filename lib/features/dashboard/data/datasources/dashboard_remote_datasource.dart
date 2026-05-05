import 'package:dio/dio.dart';
import 'package:pos_desktop/core/config/operation_context.dart';
import 'package:pos_desktop/core/network/api_envelope.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/features/dashboard/data/models/dashboard_summary_model.dart';

class DashboardRemoteDatasource {
  const DashboardRemoteDatasource(this._dio, this._operationContext);

  final Dio _dio;
  final OperationContext _operationContext;

  Future<DashboardSummaryModel> getSummary() async {
    try {
      final response = await _dio.get(
        '/dashboard',
        queryParameters: {'branch_id': _operationContext.branchId},
      );

      final envelope = ApiEnvelope.fromJson(
        response.data as Map<String, dynamic>,
        (raw) => DashboardSummaryModel.fromJson(raw as Map<String, dynamic>),
      );

      return envelope.data;
    } on DioException catch (error) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        throw ApiException(
          message: responseData['message'] as String? ??
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
}
