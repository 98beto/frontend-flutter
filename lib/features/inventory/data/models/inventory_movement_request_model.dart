class InventoryMovementRequestModel {
  const InventoryMovementRequestModel({
    required this.productId,
    required this.type,
    required this.quantity,
    this.notes,
  });

  final int productId;
  final String type;
  final int quantity;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'notes': _normalizeNullableText(notes),
    };
  }

  String? _normalizeNullableText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
