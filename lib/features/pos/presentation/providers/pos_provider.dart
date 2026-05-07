import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/pos/data/models/cart_item_model.dart';
import 'package:pos_desktop/features/pos/domain/entities/cart_item.dart';
import 'package:pos_desktop/features/pos/domain/entities/product.dart';
import 'package:pos_desktop/features/pos/presentation/providers/pos_state.dart';

final posProvider = NotifierProvider<PosNotifier, PosState>(PosNotifier.new);

class PosNotifier extends Notifier<PosState> {
  @override
  PosState build() {
    return const PosState(cartItems: []);
  }

  bool addProduct(Product product, {int quantity = 1}) {
    if (quantity <= 0 || product.stock <= 0) {
      return false;
    }

    final index = state.cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index == -1) {
      if (quantity > product.stock) {
        return false;
      }

      state = state.copyWith(
        cartItems: [
          ...state.cartItems,
          CartItemModel.fromProduct(product, quantity: quantity),
        ],
      );
      return true;
    }

    final items = [...state.cartItems];
    final item = items[index];
    final nextQuantity = item.quantity + quantity;
    if (nextQuantity > item.product.stock) {
      return false;
    }

    items[index] = item.copyWith(quantity: nextQuantity);
    state = state.copyWith(cartItems: items);
    return true;
  }

  bool incrementItem(String productId) {
    var didUpdate = false;

    final updated = state.cartItems.map((item) {
      if (item.product.id != productId) {
        return item;
      }

      if (item.quantity >= item.product.stock) {
        return item;
      }

      didUpdate = true;
      return item.copyWith(quantity: item.quantity + 1);
    }).toList();

    if (!didUpdate) {
      return false;
    }

    state = state.copyWith(cartItems: updated);
    return true;
  }

  void decrementItem(String productId) {
    final updated = <CartItem>[];
    for (final item in state.cartItems) {
      if (item.product.id != productId) {
        updated.add(item);
        continue;
      }

      if (item.quantity > 1) {
        updated.add(item.copyWith(quantity: item.quantity - 1));
      }
    }

    state = state.copyWith(cartItems: updated);
  }

  void removeItem(String productId) {
    state = state.copyWith(
      cartItems: state.cartItems
          .where((item) => item.product.id != productId)
          .toList(),
    );
  }

  bool setItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return true;
    }

    final index = state.cartItems.indexWhere(
      (item) => item.product.id == productId,
    );
    if (index == -1) {
      return false;
    }

    final item = state.cartItems[index];
    if (quantity > item.product.stock) {
      return false;
    }

    final items = [...state.cartItems];
    items[index] = item.copyWith(quantity: quantity);
    state = state.copyWith(cartItems: items);
    return true;
  }

  void setDiscount(double discount) {
    final normalizedDiscount = discount < 0
        ? 0.0
        : discount > state.subtotal
        ? state.subtotal
        : discount;

    state = state.copyWith(discount: normalizedDiscount);
  }

  void clearDiscount() {
    state = state.copyWith(discount: 0);
  }

  void loadSavedCart({
    required String savedCartId,
    required List<CartItem> items,
    required double discount,
    int? customerId,
    String? customerName,
  }) {
    state = state.copyWith(
      cartItems: items,
      activeSavedCartId: savedCartId,
      selectedCustomerId: customerId,
      selectedCustomerName: customerName,
      discount: discount,
    );
  }

  void assignCustomer({required int id, required String name}) {
    state = state.copyWith(selectedCustomerId: id, selectedCustomerName: name);
  }

  void clearCustomer() {
    state = state.copyWith(
      selectedCustomerId: null,
      selectedCustomerName: null,
    );
  }

  void clearCart() {
    state = state.copyWith(
      cartItems: const [],
      activeSavedCartId: null,
      selectedCustomerId: null,
      selectedCustomerName: null,
    );
  }
}
