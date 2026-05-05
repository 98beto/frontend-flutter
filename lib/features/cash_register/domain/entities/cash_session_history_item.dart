class CashSessionHistoryItem {
  const CashSessionHistoryItem({
    required this.id,
    required this.status,
    required this.openingBalance,
    required this.openedAt,
    this.closingBalance,
    this.closedAt,
    this.notes,
    this.deviceIdentifier,
    this.branchId,
  });

  final int id;
  final String status;
  final double openingBalance;
  final double? closingBalance;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String? notes;
  final String? deviceIdentifier;
  final int? branchId;

  bool get isOpen => status == 'open';

  bool get isClosed => status == 'closed';
}
