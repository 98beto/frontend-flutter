import 'package:pos_desktop/features/pos/domain/entities/cash_session.dart';

class CashSessionModel extends CashSession {
  const CashSessionModel({
    required super.id,
    required super.status,
    required super.openingBalance,
    required super.openedAt,
    super.notes,
  });

  factory CashSessionModel.fromJson(Map<String, dynamic> json) {
    return CashSessionModel(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? 'closed',
      openingBalance: _toDouble(json['opening_balance']),
      openedAt: DateTime.tryParse(json['opened_at'] as String? ?? '') ??
          DateTime.now(),
      notes: json['notes'] as String?,
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
}
