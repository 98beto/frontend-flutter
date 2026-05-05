class SaleListItem {
  const SaleListItem({
    required this.id,
    required this.saleDate,
    required this.paymentMethod,
    required this.status,
    required this.totalAmount,
    this.customerName,
    this.cashSessionId,
  });

  final int id;
  final DateTime saleDate;
  final String paymentMethod;
  final String status;
  final double totalAmount;
  final String? customerName;
  final int? cashSessionId;
}
