import 'package:pos_desktop/features/pos/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.sku,
    required super.branchId,
    required super.price,
    required super.stock,
    required super.category,
    super.categoryId,
    super.brand,
    super.isAvailable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final brand = json['brand'] as Map<String, dynamic>?;
    final branchProduct =
        json['branch_product'] as Map<String, dynamic>? ?? const {};

    return ProductModel(
      id: '${json['id']}',
      name: json['name'] as String? ?? 'Producto sin nombre',
      sku: json['sku'] as String? ?? 'SIN-SKU',
      branchId: _toInt(branchProduct['branch_id']),
      price: _toDouble(branchProduct['price']),
      stock: _toInt(branchProduct['stock_quantity']),
      category: category?['name'] as String? ?? 'Sin categoria',
      categoryId: _toNullableInt(json['category_id']),
      brand: brand?['name'] as String?,
      isAvailable: branchProduct['is_available'] as bool? ?? true,
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
