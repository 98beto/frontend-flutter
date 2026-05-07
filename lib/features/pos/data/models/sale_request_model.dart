import 'package:pos_desktop/features/pos/data/models/sale_item_request_model.dart';

class SaleRequestModel {
  const SaleRequestModel({
    required this.cashSessionId,
    required this.paymentMethod,
    required this.discountAmount,
    required this.items,
    this.customerId,
  });

  final int? customerId;
  final int cashSessionId;
  final String paymentMethod;
  final double discountAmount;
  final List<SaleItemRequestModel> items;

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'cash_session_id': cashSessionId,
      'payment_method': paymentMethod,
      'discount_amount': discountAmount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
