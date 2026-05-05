import 'package:pos_desktop/features/cash_register/domain/entities/cash_close_result.dart';

class CashCloseResultModel extends CashCloseResult {
  const CashCloseResultModel({
    required super.expectedBalance,
    required super.actualBalance,
    required super.difference,
  });

  factory CashCloseResultModel.fromJson(Map<String, dynamic> json) {
    return CashCloseResultModel(
      expectedBalance: _toDouble(json['expected_balance']),
      actualBalance: _toDouble(json['actual_balance']),
      difference: _toDouble(json['difference']),
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
