class SaleDetailItem {
  const SaleDetailItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.taxAmount,
    required this.subtotal,
    required this.total,
    this.sku,
  });

  final String productName;
  final String? sku;
  final int quantity;
  final double unitPrice;
  final double taxAmount;
  final double subtotal;
  final double total;
}
