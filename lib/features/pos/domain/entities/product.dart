class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.branchId,
    required this.price,
    required this.stock,
    required this.category,
    this.categoryId,
    this.brand,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final String sku;
  final int branchId;
  final double price;
  final int stock;
  final String category;
  final int? categoryId;
  final String? brand;
  final bool isAvailable;
}
