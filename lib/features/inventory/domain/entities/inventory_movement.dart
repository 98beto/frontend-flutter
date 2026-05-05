class InventoryMovement {
  const InventoryMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.source,
    required this.createdAt,
    this.notes,
    this.referenceId,
    this.productSku,
    this.productStockQuantity,
    this.productMinStock,
    this.productUnitMeasure,
  });

  final int id;
  final int productId;
  final String productName;
  final String type;
  final int quantity;
  final String source;
  final DateTime createdAt;
  final String? notes;
  final int? referenceId;
  final String? productSku;
  final int? productStockQuantity;
  final int? productMinStock;
  final String? productUnitMeasure;

  bool get isLowStockProduct {
    final stock = productStockQuantity;
    final minStock = productMinStock;
    if (stock == null || minStock == null) {
      return false;
    }
    return stock <= minStock;
  }
}
