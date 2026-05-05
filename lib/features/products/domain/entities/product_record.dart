class ProductRecord {
  const ProductRecord({
    required this.id,
    required this.name,
    required this.price,
    required this.stockQuantity,
    required this.minStock,
    required this.unitMeasure,
    required this.isActive,
    this.description,
    this.costPrice,
    this.barcode,
    this.sku,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
  });

  final int id;
  final String name;
  final String? description;
  final double? costPrice;
  final double price;
  final int stockQuantity;
  final int minStock;
  final String unitMeasure;
  final String? barcode;
  final String? sku;
  final bool isActive;
  final int? categoryId;
  final String? categoryName;
  final int? brandId;
  final String? brandName;

  bool get isLowStock => stockQuantity <= minStock;
}
