class CloseCashRequestModel {
  const CloseCashRequestModel({required this.closingBalance, this.notes});

  final double closingBalance;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {'closing_balance': closingBalance, 'notes': notes};
  }
}
