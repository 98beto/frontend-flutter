class SupplierRecord {
  const SupplierRecord({
    required this.id,
    required this.name,
    this.contactPerson,
    this.email,
    this.phone,
    this.address,
    this.creditDays,
    this.bankInfo,
  });

  final int id;
  final String name;
  final String? contactPerson;
  final String? email;
  final String? phone;
  final String? address;
  final int? creditDays;
  final String? bankInfo;
}
