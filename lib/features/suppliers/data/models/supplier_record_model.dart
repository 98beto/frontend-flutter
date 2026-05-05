import 'package:pos_desktop/features/suppliers/domain/entities/supplier_record.dart';

class SupplierRecordModel extends SupplierRecord {
  const SupplierRecordModel({
    required super.id,
    required super.name,
    super.contactPerson,
    super.email,
    super.phone,
    super.address,
    super.creditDays,
    super.bankInfo,
  });

  factory SupplierRecordModel.fromJson(Map<String, dynamic> json) {
    return SupplierRecordModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      contactPerson: json['contact_person'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      creditDays: _toNullableInt(json['credit_days']),
      bankInfo: json['bank_info'] as String?,
    );
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
