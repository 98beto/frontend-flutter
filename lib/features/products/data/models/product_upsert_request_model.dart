class ProductUpsertRequestModel {
  const ProductUpsertRequestModel({
    required this.name,
    required this.price,
    required this.stockQuantity,
    required this.minStock,
    required this.isActive,
    this.description,
    this.costPrice,
    this.unitMeasure,
    this.barcode,
    this.sku,
    this.categoryId,
    this.brandId,
  });

  final String name;
  final String? description;
  final double? costPrice;
  final double price;
  final int stockQuantity;
  final int minStock;
  final String? unitMeasure;
  final String? barcode;
  final String? sku;
  final bool isActive;
  final int? categoryId;
  final int? brandId;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': _normalizeNullableText(description),
      'cost_price': costPrice,
      'price': price,
      'stock_quantity': stockQuantity,
      'min_stock': minStock,
      'unit_measure': _normalizeNullableText(unitMeasure),
      'barcode': _normalizeNullableText(barcode),
      'sku': _normalizeNullableText(sku),
      'is_active': isActive,
      'category_id': categoryId,
      'brand_id': brandId,
    };
  }

  String? _normalizeNullableText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
