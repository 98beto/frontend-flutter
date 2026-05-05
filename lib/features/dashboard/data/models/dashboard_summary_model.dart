import 'package:pos_desktop/features/dashboard/domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.todaySalesCount,
    required super.todayRevenue,
    required super.todayItemsSold,
    required super.totalProducts,
    required super.activeProducts,
    required super.lowStockCount,
    super.cashSessionId,
    super.cashSessionOpenedAt,
    super.cashSessionOpeningBalance,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final today = json['today'] as Map<String, dynamic>? ?? const {};
    final inventory = json['inventory'] as Map<String, dynamic>? ?? const {};
    final cashSession = json['cash_session'] as Map<String, dynamic>?;

    return DashboardSummaryModel(
      todaySalesCount: today['sales_count'] as int? ?? 0,
      todayRevenue: _toDouble(today['revenue']),
      todayItemsSold: today['items_sold'] as int? ?? 0,
      totalProducts: inventory['total_products'] as int? ?? 0,
      activeProducts: inventory['active_products'] as int? ?? 0,
      lowStockCount: inventory['low_stock_count'] as int? ?? 0,
      cashSessionId: cashSession?['id'] as int?,
      cashSessionOpenedAt: cashSession == null
          ? null
          : DateTime.tryParse(cashSession['opened_at'] as String? ?? ''),
      cashSessionOpeningBalance:
          cashSession == null ? null : _toDouble(cashSession['opening_balance']),
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
