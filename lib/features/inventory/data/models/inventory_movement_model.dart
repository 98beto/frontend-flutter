import 'package:pos_desktop/features/inventory/domain/entities/inventory_movement.dart';

class InventoryMovementModel extends InventoryMovement {
  const InventoryMovementModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.type,
    required super.quantity,
    required super.source,
    required super.createdAt,
    super.notes,
    super.referenceId,
    super.productSku,
    super.productStockQuantity,
    super.productMinStock,
    super.productUnitMeasure,
  });

  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    return InventoryMovementModel(
      id: _toInt(json['id']),
      productId: _toInt(json['product_id'] ?? product?['id']),
      productName: product?['name'] as String? ?? 'Producto desconocido',
      type: json['type'] as String? ?? 'adjustment',
      quantity: _toInt(json['quantity']),
      source: json['source'] as String? ?? 'manual',
      createdAt: _parseDate(
        json['created_at'] as String? ?? json['movement_date'] as String? ?? '',
      ),
      notes: json['notes'] as String?,
      referenceId: _toNullableInt(json['reference_id']),
      productSku: product?['sku'] as String?,
      productStockQuantity: _toNullableInt(product?['stock_quantity']),
      productMinStock: _toNullableInt(product?['min_stock']),
      productUnitMeasure: product?['unit_measure'] as String?,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    return _toInt(value);
  }

  static DateTime _parseDate(String value) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}
