import 'package:pos_desktop/features/pos/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.sku,
    required super.price,
    required super.stock,
    required super.category,
    super.categoryId,
    super.barcode,
    super.brand,
    super.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final brand = json['brand'] as Map<String, dynamic>?;

    return ProductModel(
      id: '${json['id']}',
      name: json['name'] as String? ?? 'Producto sin nombre',
      sku: json['sku'] as String? ?? 'SIN-SKU',
      price: _toDouble(json['price']),
      stock: json['stock_quantity'] as int? ?? 0,
      category: category?['name'] as String? ?? 'Sin categoria',
      categoryId: json['category_id'] as int?,
      barcode: json['barcode'] as String?,
      brand: brand?['name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
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
