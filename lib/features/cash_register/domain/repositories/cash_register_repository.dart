import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/cash_register/data/models/close_cash_request_model.dart';
import 'package:pos_desktop/features/cash_register/data/models/cash_movement_request_model.dart';
import 'package:pos_desktop/features/cash_register/data/models/open_cash_request_model.dart';
import 'package:pos_desktop/features/cash_register/domain/entities/cash_close_result.dart';
import 'package:pos_desktop/features/cash_register/domain/entities/cash_movement.dart';
import 'package:pos_desktop/features/cash_register/domain/entities/cash_session_history_item.dart';
import 'package:pos_desktop/features/pos/domain/entities/cash_session.dart';

abstract class CashRegisterRepository {
  Future<CashSession?> getCurrentCashSession();

  Future<CashSession> openCashSession(OpenCashRequestModel request);

  Future<CashCloseResult> closeCashSession(
    int id,
    CloseCashRequestModel request,
  );

  Future<void> createCashMovement(int id, CashMovementRequestModel request);

  Future<PaginatedResponse<CashSessionHistoryItem>> getCashSessions({
    int page = 1,
  });

  Future<PaginatedResponse<CashMovement>> getCashMovements(
    int id, {
    int page = 1,
    String? type,
    String? category,
    String? source,
  });
}
