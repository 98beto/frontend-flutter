import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/features/pos/data/models/sale_item_request_model.dart';
import 'package:pos_desktop/features/pos/data/models/sale_request_model.dart';
import 'package:pos_desktop/features/pos/domain/entities/cart_item.dart';
import 'package:pos_desktop/features/pos/domain/entities/sale_result.dart';
import 'package:pos_desktop/features/pos/presentation/providers/cash_session_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/pos_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/pos_repository_provider.dart';

final saleSubmissionProvider =
    AsyncNotifierProvider<SaleSubmissionNotifier, SaleResult?>(
      SaleSubmissionNotifier.new,
    );

class SaleSubmissionNotifier extends AsyncNotifier<SaleResult?> {
  @override
  Future<SaleResult?> build() async => null;

  Future<SaleResult> submitSale({
    required String paymentMethod,
    required List<CartItem> items,
    required double discountAmount,
    required double taxRate,
  }) async {
    final cashSession = await ref.read(cashSessionProvider.future);
    final posState = ref.read(posProvider);
    if (cashSession == null) {
      throw const ApiException(
        message: 'No hay una sesion de caja abierta para registrar la venta.',
      );
    }

    final saleItems = items.map((item) {
      final subtotal = item.product.price * item.quantity;
      final taxAmount = subtotal * taxRate;
      final total = subtotal + taxAmount;

      return SaleItemRequestModel(
        productId: int.tryParse(item.product.id) ?? 0,
        quantity: item.quantity,
        unitPrice: item.product.price,
        taxAmount: taxAmount,
        subtotal: subtotal,
        total: total,
      );
    }).toList();

    final request = SaleRequestModel(
      customerId: posState.selectedCustomerId,
      cashSessionId: cashSession.id,
      paymentMethod: paymentMethod,
      discountAmount: discountAmount,
      items: saleItems,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(posRepositoryProvider).createSale(request),
    );

    return state.requireValue!;
  }
}
