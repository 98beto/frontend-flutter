import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/cash_register/data/models/cash_movement_request_model.dart';
import 'package:pos_desktop/features/cash_register/data/models/close_cash_request_model.dart';
import 'package:pos_desktop/features/cash_register/data/models/open_cash_request_model.dart';
import 'package:pos_desktop/features/cash_register/domain/entities/cash_close_result.dart';
import 'package:pos_desktop/features/cash_register/presentation/providers/cash_register_repository_provider.dart';
import 'package:pos_desktop/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/cash_session_provider.dart';

final cashRegisterActionsProvider =
    AsyncNotifierProvider<CashRegisterActionsNotifier, CashCloseResult?>(
      CashRegisterActionsNotifier.new,
    );

class CashRegisterActionsNotifier extends AsyncNotifier<CashCloseResult?> {
  @override
  Future<CashCloseResult?> build() async => null;

  void clearCloseResult() {
    state = const AsyncData(null);
  }

  Future<void> openCashSession({
    required double openingBalance,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(cashRegisterRepositoryProvider)
          .openCashSession(
            OpenCashRequestModel(openingBalance: openingBalance, notes: notes),
          );

      ref.invalidate(cashSessionProvider);
      ref.invalidate(dashboardProvider);
      return null;
    });
  }

  Future<void> closeCashSession({
    required int sessionId,
    required double closingBalance,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(cashRegisterRepositoryProvider)
          .closeCashSession(
            sessionId,
            CloseCashRequestModel(closingBalance: closingBalance, notes: notes),
          );

      ref.invalidate(cashSessionProvider);
      ref.invalidate(dashboardProvider);
      return result;
    });
  }

  Future<void> withdrawCash({
    required int sessionId,
    required double amount,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(cashRegisterRepositoryProvider)
          .createCashMovement(
            sessionId,
            CashMovementRequestModel(
              type: 'out',
              category: 'withdrawal',
              amount: amount,
              notes: notes,
            ),
          );

      ref.invalidate(cashSessionProvider);
      ref.invalidate(dashboardProvider);
      return null;
    });
  }
}
