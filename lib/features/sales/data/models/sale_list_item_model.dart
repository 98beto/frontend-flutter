import 'package:pos_desktop/features/sales/domain/entities/sale_list_item.dart';

class SaleListItemModel extends SaleListItem {
  const SaleListItemModel({
    required super.id,
    required super.saleDate,
    required super.paymentMethod,
    required super.status,
    required super.totalAmount,
    super.customerName,
    super.cashSessionId,
  });

  factory SaleListItemModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final cashSession = json['cash_session'] as Map<String, dynamic>?;

    return SaleListItemModel(
      id: json['id'] as int? ?? 0,
      saleDate:
          DateTime.tryParse(json['sale_date'] as String? ?? '') ??
          DateTime.now(),
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      status: json['status'] as String? ?? 'completed',
      totalAmount: _toDouble(json['total_amount']),
      customerName: customer?['name'] as String?,
      cashSessionId: cashSession?['id'] as int?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}
