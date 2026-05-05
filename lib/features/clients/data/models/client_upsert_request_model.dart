class ClientUpsertRequestModel {
  const ClientUpsertRequestModel({
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.taxId,
  });

  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? taxId;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': _nullable(email),
      'phone': _nullable(phone),
      'address': _nullable(address),
      'tax_id': _nullable(taxId),
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
