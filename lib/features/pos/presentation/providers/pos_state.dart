import 'package:pos_desktop/features/pos/domain/entities/cart_item.dart';
class PosState {
  const PosState({
    required this.cartItems,
    this.activeSavedCartId,
    this.selectedCustomerId,
    this.selectedCustomerName,
    this.discount = 0,
    this.taxRate = 0.16,
  });

  final List<CartItem> cartItems;
  final String? activeSavedCartId;
  final int? selectedCustomerId;
  final String? selectedCustomerName;
  final double discount;
  final double taxRate;

  bool get isCartEmpty => cartItems.isEmpty;

  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + item.lineTotal);
  }

  double get taxes {
    return subtotal * taxRate;
  }

  double get total {
    final discountedTotal = subtotal + taxes - discount;
    return discountedTotal < 0 ? 0 : discountedTotal;
  }

  int get totalItems {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  PosState copyWith({
    List<CartItem>? cartItems,
    Object? activeSavedCartId = _sentinel,
    Object? selectedCustomerId = _sentinel,
    Object? selectedCustomerName = _sentinel,
    double? discount,
    double? taxRate,
  }) {
    return PosState(
      cartItems: cartItems ?? this.cartItems,
      activeSavedCartId: identical(activeSavedCartId, _sentinel)
          ? this.activeSavedCartId
          : activeSavedCartId as String?,
      selectedCustomerId: identical(selectedCustomerId, _sentinel)
          ? this.selectedCustomerId
          : selectedCustomerId as int?,
      selectedCustomerName: identical(selectedCustomerName, _sentinel)
          ? this.selectedCustomerName
          : selectedCustomerName as String?,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
    );
  }
}

const _sentinel = Object();
