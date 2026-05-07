class ProductBranchUpdateRequestModel {
  const ProductBranchUpdateRequestModel({
    required this.price,
    required this.stockQuantity,
    required this.minStock,
    required this.isAvailable,
  });

  final double price;
  final int stockQuantity;
  final int minStock;
  final bool isAvailable;

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'stock_quantity': stockQuantity,
      'min_stock': minStock,
      'is_available': isAvailable,
    };
  }
}
