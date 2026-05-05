import 'package:pos_desktop/features/pos/data/models/saved_cart_item_request_model.dart';

class SavedCartRequestModel {
  const SavedCartRequestModel({
    required this.name,
    required this.branchId,
    required this.discountAmount,
    required this.status,
    required this.items,
    this.customerId,
    this.cashSessionId,
    this.notes,
  });

  final String name;
  final int branchId;
  final int? customerId;
  final int? cashSessionId;
  final double discountAmount;
  final String status;
  final String? notes;
  final List<SavedCartItemRequestModel> items;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'branch_id': branchId,
      'customer_id': customerId,
      'cash_session_id': cashSessionId,
      'discount_amount': discountAmount,
      'status': status,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
