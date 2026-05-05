class CashMovement {
  const CashMovement({
    required this.id,
    required this.cashSessionId,
    required this.branchId,
    required this.type,
    required this.category,
    required this.amount,
    required this.source,
    required this.createdAt,
    this.referenceId,
    this.notes,
  });

  final int id;
  final int cashSessionId;
  final int branchId;
  final String type;
  final String category;
  final double amount;
  final String source;
  final int? referenceId;
  final String? notes;
  final DateTime createdAt;
}
