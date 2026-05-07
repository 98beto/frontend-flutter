import 'package:pos_desktop/features/pos/domain/entities/sale_result.dart';

class SaleResponseModel extends SaleResult {
  const SaleResponseModel({
    required super.id,
    required super.totalAmount,
    required super.paymentMethod,
    required super.saleDate,
  });

  factory SaleResponseModel.fromJson(Map<String, dynamic> json) {
    return SaleResponseModel(
      id: json['id'] as int? ?? 0,
      totalAmount: _toDouble(json['total_amount']),
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      saleDate:
          DateTime.tryParse(json['sale_date'] as String? ?? '') ??
          DateTime.now(),
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
