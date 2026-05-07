class ProductUpsertRequestModel {
  const ProductUpsertRequestModel({
    required this.name,
    this.description,
    this.costPrice,
    this.unitMeasure,
    this.sku,
    this.categoryId,
    this.brandId,
  });

  final String name;
  final String? description;
  final double? costPrice;
  final String? unitMeasure;
  final String? sku;
  final int? categoryId;
  final int? brandId;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': _normalizeNullableText(description),
      'cost_price': costPrice,
      'unit_measure': _normalizeNullableText(unitMeasure),
      'sku': _normalizeNullableText(sku),
      'category_id': categoryId,
      'brand_id': brandId,
    };
  }

  String? _normalizeNullableText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
