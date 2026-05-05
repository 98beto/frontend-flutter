import 'package:pos_desktop/features/cash_register/domain/entities/cash_session_history_item.dart';

class CashSessionHistoryItemModel extends CashSessionHistoryItem {
  const CashSessionHistoryItemModel({
    required super.id,
    required super.status,
    required super.openingBalance,
    required super.openedAt,
    super.closingBalance,
    super.closedAt,
    super.notes,
    super.deviceIdentifier,
    super.branchId,
  });

  factory CashSessionHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return CashSessionHistoryItemModel(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? 'closed',
      openingBalance: _toDouble(json['opening_balance']),
      closingBalance: _toNullableDouble(json['closing_balance']),
      openedAt: DateTime.tryParse(json['opened_at'] as String? ?? '') ?? DateTime.now(),
      closedAt: DateTime.tryParse(json['closed_at'] as String? ?? ''),
      notes: json['notes'] as String?,
      deviceIdentifier: json['device_identifier'] as String?,
      branchId: json['branch_id'] as int?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
