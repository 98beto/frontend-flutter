import 'package:pos_desktop/features/sales/domain/entities/sale_detail_item.dart';

class SaleDetail {
  const SaleDetail({
    required this.id,
    required this.saleDate,
    required this.paymentMethod,
    required this.status,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.items,
    this.customerName,
    this.cashSessionId,
  });

  final int id;
  final DateTime saleDate;
  final String paymentMethod;
  final String status;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String? customerName;
  final int? cashSessionId;
  final List<SaleDetailItem> items;
}
