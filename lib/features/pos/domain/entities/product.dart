class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    required this.category,
    this.categoryId,
    this.barcode,
    this.brand,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String sku;
  final double price;
  final int stock;
  final String category;
  final int? categoryId;
  final String? barcode;
  final String? brand;
  final bool isActive;
}
