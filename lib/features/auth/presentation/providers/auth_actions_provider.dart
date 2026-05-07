import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/dio_provider.dart';
import 'package:pos_desktop/core/notifications/app_notification_provider.dart';
import 'package:pos_desktop/core/widgets/app_section_provider.dart';
import 'package:pos_desktop/core/widgets/app_sidebar.dart';
import 'package:pos_desktop/features/auth/domain/entities/device_session.dart';
import 'package:pos_desktop/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:pos_desktop/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:pos_desktop/features/cash_register/presentation/providers/cash_sessions_history_provider.dart';
import 'package:pos_desktop/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/inventory_movements_provider.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/low_stock_products_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/cash_session_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/products_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/saved_carts_provider.dart';
import 'package:pos_desktop/features/products/presentation/providers/products_provider.dart'
    as admin_products;
import 'package:pos_desktop/features/sales/presentation/providers/sales_provider.dart';

final authActionsProvider =
    AsyncNotifierProvider<AuthActionsNotifier, DeviceSession?>(
      AuthActionsNotifier.new,
    );

class AuthActionsNotifier extends AsyncNotifier<DeviceSession?> {
  @override
  Future<DeviceSession?> build() async {
    return ref.watch(authSessionProvider);
  }

  Future<DeviceSession> login({
    required String identifier,
    required String secret,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.read(appNotificationProvider.notifier).clear();
      final session = await ref
          .read(authRepositoryProvider)
          .login(identifier: identifier.trim(), secret: secret);

      ref.read(authSessionProvider.notifier).saveSession(session);
      _refreshOperationalState();
      return session;
    });

    return state.requireValue!;
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      ref.read(appNotificationProvider.notifier).clear();
      await ref.read(authRepositoryProvider).logout();
      await ref.read(authSessionProvider.notifier).clearSession();
      _refreshOperationalState();
      ref.read(appSectionProvider.notifier).state = AppSection.pos;
      return null;
    });
  }

  void _refreshOperationalState() {
    ref.invalidate(dioProvider);
    ref.invalidate(cashSessionProvider);
    ref.invalidate(productsProvider);
    ref.invalidate(savedCartsProvider);
    ref.invalidate(salesProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(inventoryMovementsProvider);
    ref.invalidate(lowStockProductsProvider);
    ref.invalidate(cashSessionsHistoryProvider);
    ref.invalidate(admin_products.productsProvider);
  }
}
