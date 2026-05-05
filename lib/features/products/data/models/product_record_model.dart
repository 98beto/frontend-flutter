import 'package:pos_desktop/features/products/domain/entities/product_record.dart';

class ProductRecordModel extends ProductRecord {
  const ProductRecordModel({
    required super.id,
    required super.name,
    required super.price,
    required super.stockQuantity,
    required super.minStock,
    required super.unitMeasure,
    required super.isActive,
    super.description,
    super.costPrice,
    super.barcode,
    super.sku,
    super.categoryId,
    super.categoryName,
    super.brandId,
    super.brandName,
  });

  factory ProductRecordModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final brand = json['brand'] as Map<String, dynamic>?;

    return ProductRecordModel(
      id: _toInt(json['id']),
      name: json['name'] as String? ?? 'Producto sin nombre',
      description: json['description'] as String?,
      costPrice: _toNullableDouble(json['cost_price']),
      price: _toDouble(json['price']),
      stockQuantity: _toInt(json['stock_quantity']),
      minStock: _toInt(json['min_stock'], fallback: 5),
      unitMeasure: (json['unit_measure'] as String?)?.trim().isNotEmpty == true
          ? (json['unit_measure'] as String).trim()
          : 'PZA',
      barcode: json['barcode'] as String?,
      sku: json['sku'] as String?,
      isActive: json['is_active'] as bool? ?? false,
      categoryId: _toNullableInt(json['category_id']),
      categoryName: category?['name'] as String?,
      brandId: _toNullableInt(json['brand_id']),
      brandName: brand?['name'] as String?,
    );
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    return _toInt(value);
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String && value.trim().isEmpty) {
      return null;
    }
    return _toDouble(value);
  }
}
