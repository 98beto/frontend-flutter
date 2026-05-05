class ClientRecord {
  const ClientRecord({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.taxId,
  });

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? taxId;
}
