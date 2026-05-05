import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:pos_desktop/features/inventory/data/models/inventory_movement_request_model.dart';
import 'package:pos_desktop/features/inventory/domain/entities/inventory_movement.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/inventory_movement_detail_provider.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/inventory_movements_provider.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/inventory_repository_provider.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/low_stock_products_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/products_provider.dart'
    as pos_products;
import 'package:pos_desktop/features/products/presentation/providers/products_provider.dart';

final inventoryMovementActionsProvider =
    AsyncNotifierProvider<InventoryMovementActionsNotifier, InventoryMovement?>(
  InventoryMovementActionsNotifier.new,
);

class InventoryMovementActionsNotifier extends AsyncNotifier<InventoryMovement?> {
  @override
  Future<InventoryMovement?> build() async => null;

  Future<InventoryMovement> createMovement(InventoryMovementRequestModel request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(inventoryRepositoryProvider).createMovement(request),
    );

    final movement = state.requireValue!;
    ref.invalidate(inventoryMovementDetailProvider(movement.id));
    _invalidateRelatedData();
    return movement;
  }

  void _invalidateRelatedData() {
    ref.invalidate(inventoryMovementsProvider);
    ref.invalidate(lowStockProductsProvider);
    ref.invalidate(productsProvider);
    ref.invalidate(pos_products.productsProvider);
    ref.invalidate(dashboardProvider);
  }
}
