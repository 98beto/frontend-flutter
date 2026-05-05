class DashboardSummary {
  const DashboardSummary({
    required this.todaySalesCount,
    required this.todayRevenue,
    required this.todayItemsSold,
    required this.totalProducts,
    required this.activeProducts,
    required this.lowStockCount,
    this.cashSessionId,
    this.cashSessionOpenedAt,
    this.cashSessionOpeningBalance,
  });

  final int todaySalesCount;
  final double todayRevenue;
  final int todayItemsSold;
  final int totalProducts;
  final int activeProducts;
  final int lowStockCount;
  final int? cashSessionId;
  final DateTime? cashSessionOpenedAt;
  final double? cashSessionOpeningBalance;

  bool get hasOpenCashSession => cashSessionId != null;
}
