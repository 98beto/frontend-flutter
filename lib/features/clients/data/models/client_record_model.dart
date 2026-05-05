import 'package:pos_desktop/features/clients/domain/entities/client_record.dart';

class ClientRecordModel extends ClientRecord {
  const ClientRecordModel({
    required super.id,
    required super.name,
    super.email,
    super.phone,
    super.address,
    super.taxId,
  });

  factory ClientRecordModel.fromJson(Map<String, dynamic> json) {
    return ClientRecordModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      taxId: json['tax_id'] as String?,
    );
  }
}
