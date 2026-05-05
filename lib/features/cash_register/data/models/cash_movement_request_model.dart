class CashMovementRequestModel {
  const CashMovementRequestModel({
    required this.type,
    required this.category,
    required this.amount,
    this.notes,
  });

  final String type;
  final String category;
  final double amount;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'category': category,
      'amount': amount,
      'notes': _normalizeNullableText(notes),
    };
  }

  String? _normalizeNullableText(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
