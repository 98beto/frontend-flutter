class CashSession {
  const CashSession({
    required this.id,
    required this.status,
    required this.openingBalance,
    required this.openedAt,
    this.notes,
  });

  final int id;
  final String status;
  final double openingBalance;
  final DateTime openedAt;
  final String? notes;
}
