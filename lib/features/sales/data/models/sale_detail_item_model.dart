import 'package:pos_desktop/features/sales/domain/entities/sale_detail_item.dart';

class SaleDetailItemModel extends SaleDetailItem {
  const SaleDetailItemModel({
    required super.productName,
    required super.quantity,
    required super.unitPrice,
    required super.taxAmount,
    required super.subtotal,
    required super.total,
    super.sku,
  });

  factory SaleDetailItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    return SaleDetailItemModel(
      productName: product?['name'] as String? ?? 'Producto sin nombre',
      sku: product?['sku'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: _toDouble(json['unit_price']),
      taxAmount: _toDouble(json['tax_amount']),
      subtotal: _toDouble(json['subtotal']),
      total: _toDouble(json['total']),
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
