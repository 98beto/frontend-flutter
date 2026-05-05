class SavedCartItemRequestModel {
  const SavedCartItemRequestModel({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.taxAmount,
    required this.subtotal,
    required this.total,
  });

  final int productId;
  final int quantity;
  final double unitPrice;
  final double taxAmount;
  final double subtotal;
  final double total;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'tax_amount': taxAmount,
      'subtotal': subtotal,
      'total': total,
    };
  }
}
