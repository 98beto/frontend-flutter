import 'package:pos_desktop/features/sales/data/models/sale_detail_item_model.dart';
import 'package:pos_desktop/features/sales/domain/entities/sale_detail.dart';

class SaleDetailModel extends SaleDetail {
  const SaleDetailModel({
    required super.id,
    required super.saleDate,
    required super.paymentMethod,
    required super.status,
    required super.subtotal,
    required super.taxAmount,
    required super.discountAmount,
    required super.totalAmount,
    required super.items,
    super.customerName,
    super.cashSessionId,
  });

  factory SaleDetailModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final cashSession = json['cash_session'] as Map<String, dynamic>?;
    final saleDetails = json['sale_details'] as List<dynamic>? ?? const [];

    return SaleDetailModel(
      id: json['id'] as int? ?? 0,
      saleDate:
          DateTime.tryParse(json['sale_date'] as String? ?? '') ??
          DateTime.now(),
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      status: json['status'] as String? ?? 'completed',
      subtotal: _toDouble(json['subtotal']),
      taxAmount: _toDouble(json['tax_amount']),
      discountAmount: _toDouble(json['discount_amount']),
      totalAmount: _toDouble(json['total_amount']),
      customerName: customer?['name'] as String?,
      cashSessionId: cashSession?['id'] as int?,
      items: saleDetails
          .map(
            (item) =>
                SaleDetailItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
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
