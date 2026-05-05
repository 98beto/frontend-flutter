class OpenCashRequestModel {
  const OpenCashRequestModel({
    required this.branchId,
    required this.deviceIdentifier,
    required this.openingBalance,
    this.notes,
  });

  final int branchId;
  final String deviceIdentifier;
  final double openingBalance;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'branch_id': branchId,
      'device_identifier': deviceIdentifier,
      'opening_balance': openingBalance,
      'notes': notes,
    };
  }
}
