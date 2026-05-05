class SaleResult {
  const SaleResult({
    required this.id,
    required this.totalAmount,
    required this.paymentMethod,
    required this.saleDate,
  });

  final int id;
  final double totalAmount;
  final String paymentMethod;
  final DateTime saleDate;
}
