class SupplierUpsertRequestModel {
  const SupplierUpsertRequestModel({
    required this.name,
    this.contactPerson,
    this.email,
    this.phone,
    this.address,
    this.creditDays,
    this.bankInfo,
  });

  final String name;
  final String? contactPerson;
  final String? email;
  final String? phone;
  final String? address;
  final int? creditDays;
  final String? bankInfo;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact_person': _nullable(contactPerson),
      'email': _nullable(email),
      'phone': _nullable(phone),
      'address': _nullable(address),
      'credit_days': creditDays,
      'bank_info': _nullable(bankInfo),
    };
  }

  String? _nullable(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
