import 'package:pos_desktop/features/pos/domain/entities/cart_item.dart';
import 'package:pos_desktop/features/pos/domain/entities/product.dart';

class CartItemModel extends CartItem {
  const CartItemModel({required super.product, required super.quantity});

  factory CartItemModel.fromProduct(Product product, {int quantity = 1}) {
    return CartItemModel(product: product, quantity: quantity);
  }
}
