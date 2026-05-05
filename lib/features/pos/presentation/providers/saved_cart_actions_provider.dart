import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/config/operation_context_provider.dart';
import 'package:pos_desktop/features/pos/data/models/saved_cart_item_request_model.dart';
import 'package:pos_desktop/features/pos/data/models/saved_cart_request_model.dart';
import 'package:pos_desktop/features/pos/domain/entities/cart_item.dart';
import 'package:pos_desktop/features/pos/domain/entities/saved_cart.dart';
import 'package:pos_desktop/features/pos/presentation/providers/cash_session_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/pos_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/pos_repository_provider.dart';

final savedCartActionsProvider =
    AsyncNotifierProvider<SavedCartActionsNotifier, SavedCart?>(
  SavedCartActionsNotifier.new,
);

class SavedCartActionsNotifier extends AsyncNotifier<SavedCart?> {
  @override
  Future<SavedCart?> build() async => null;

  Future<SavedCart> saveCart({
    required List<CartItem> items,
    required double discountAmount,
    String? notes,
    String? existingSavedCartId,
  }) async {
    final cashSession = await ref.read(cashSessionProvider.future);
    final posState = ref.read(posProvider);
    final now = DateTime.now();
    final name =
        'Venta pausada ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final request = SavedCartRequestModel(
      name: name,
      branchId: ref.read(operationContextProvider).branchId,
      customerId: posState.selectedCustomerId,
      cashSessionId: cashSession?.id,
      discountAmount: discountAmount,
      status: 'saved',
      notes: notes,
      items: _mapItems(items, 0.16),
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => existingSavedCartId == null
          ? ref.read(posRepositoryProvider).createSavedCart(request)
          : ref.read(posRepositoryProvider).updateSavedCart(
                existingSavedCartId,
                request,
              ),
    );

    return state.requireValue!;
  }

  Future<SavedCart> recoverCart(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(posRepositoryProvider).recoverSavedCart(id),
    );

    return state.requireValue!;
  }

  Future<void> deleteCart(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(posRepositoryProvider).deleteSavedCart(id);
      return null;
    });
  }

  List<SavedCartItemRequestModel> _mapItems(List<CartItem> items, double taxRate) {
    return items.map((item) {
      final subtotal = item.product.price * item.quantity;
      final taxAmount = subtotal * taxRate;
      final total = subtotal + taxAmount;

      return SavedCartItemRequestModel(
        productId: int.tryParse(item.product.id) ?? 0,
        quantity: item.quantity,
        unitPrice: item.product.price,
        taxAmount: taxAmount,
        subtotal: subtotal,
        total: total,
      );
    }).toList();
  }
}
