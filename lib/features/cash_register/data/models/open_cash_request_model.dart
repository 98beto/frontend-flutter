class OpenCashRequestModel {
  const OpenCashRequestModel({required this.openingBalance, this.notes});

  final double openingBalance;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {'opening_balance': openingBalance, 'notes': notes};
  }
}
