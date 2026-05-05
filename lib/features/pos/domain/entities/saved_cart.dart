import 'package:pos_desktop/features/pos/domain/entities/cart_item.dart';

class SavedCart {
  const SavedCart({
    required this.id,
    required this.name,
    required this.status,
    required this.discountAmount,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.items,
    this.customerId,
    this.customerName,
    this.cashSessionId,
    this.notes,
  });

  final String id;
  final String name;
  final String status;
  final int? customerId;
  final String? customerName;
  final int? cashSessionId;
  final double discountAmount;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String? notes;
  final List<CartItem> items;

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}
