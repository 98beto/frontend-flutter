class ProductRecord {
  const ProductRecord({
    required this.id,
    required this.name,
    required this.branchId,
    required this.price,
    required this.stockQuantity,
    required this.minStock,
    required this.unitMeasure,
    required this.isAvailable,
    this.description,
    this.costPrice,
    this.sku,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
  });

  final int id;
  final String name;
  final int branchId;
  final String? description;
  final double? costPrice;
  final double price;
  final int stockQuantity;
  final int minStock;
  final String unitMeasure;
  final String? sku;
  final bool isAvailable;
  final int? categoryId;
  final String? categoryName;
  final int? brandId;
  final String? brandName;

  bool get isLowStock => stockQuantity <= minStock;
}
