import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/cash_register/data/datasources/cash_register_remote_datasource.dart';
import 'package:pos_desktop/features/cash_register/data/models/cash_movement_request_model.dart';
import 'package:pos_desktop/features/cash_register/data/models/close_cash_request_model.dart';
import 'package:pos_desktop/features/cash_register/data/models/open_cash_request_model.dart';
import 'package:pos_desktop/features/cash_register/domain/entities/cash_close_result.dart';
import 'package:pos_desktop/features/cash_register/domain/entities/cash_movement.dart';
import 'package:pos_desktop/features/cash_register/domain/entities/cash_session_history_item.dart';
import 'package:pos_desktop/features/cash_register/domain/repositories/cash_register_repository.dart';
import 'package:pos_desktop/features/pos/domain/entities/cash_session.dart';

class CashRegisterRepositoryImpl implements CashRegisterRepository {
  const CashRegisterRepositoryImpl(this._remoteDatasource);

  final CashRegisterRemoteDatasource _remoteDatasource;

  @override
  Future<CashSession?> getCurrentCashSession() {
    return _remoteDatasource.getCurrentCashSession();
  }

  @override
  Future<CashSession> openCashSession(OpenCashRequestModel request) {
    return _remoteDatasource.openCashSession(request);
  }

  @override
  Future<CashCloseResult> closeCashSession(
    int id,
    CloseCashRequestModel request,
  ) {
    return _remoteDatasource.closeCashSession(id, request);
  }

  @override
  Future<void> createCashMovement(int id, CashMovementRequestModel request) {
    return _remoteDatasource.createCashMovement(id, request);
  }

  @override
  Future<PaginatedResponse<CashSessionHistoryItem>> getCashSessions({
    int page = 1,
  }) async {
    final response = await _remoteDatasource.getCashSessions(page: page);

    return PaginatedResponse<CashSessionHistoryItem>(
      items: response.items,
      currentPage: response.currentPage,
      lastPage: response.lastPage,
      perPage: response.perPage,
      total: response.total,
      nextPageUrl: response.nextPageUrl,
    );
  }

  @override
  Future<PaginatedResponse<CashMovement>> getCashMovements(
    int id, {
    int page = 1,
    String? type,
    String? category,
    String? source,
  }) async {
    final response = await _remoteDatasource.getCashMovements(
      id,
      page: page,
      type: type,
      category: category,
      source: source,
    );

    return PaginatedResponse<CashMovement>(
      items: response.items,
      currentPage: response.currentPage,
      lastPage: response.lastPage,
      perPage: response.perPage,
      total: response.total,
      nextPageUrl: response.nextPageUrl,
    );
  }
}
