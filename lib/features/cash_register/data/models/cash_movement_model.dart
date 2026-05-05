import 'package:pos_desktop/features/cash_register/domain/entities/cash_movement.dart';

class CashMovementModel extends CashMovement {
  const CashMovementModel({
    required super.id,
    required super.cashSessionId,
    required super.branchId,
    required super.type,
    required super.category,
    required super.amount,
    required super.source,
    required super.createdAt,
    super.referenceId,
    super.notes,
  });

  factory CashMovementModel.fromJson(Map<String, dynamic> json) {
    return CashMovementModel(
      id: json['id'] as int? ?? 0,
      cashSessionId: json['cash_session_id'] as int? ?? 0,
      branchId: json['branch_id'] as int? ?? 0,
      type: json['type'] as String? ?? 'out',
      category: json['category'] as String? ?? 'withdrawal',
      amount: _toDouble(json['amount']),
      source: json['source'] as String? ?? 'manual',
      referenceId: json['reference_id'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
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
