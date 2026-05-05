import 'package:pos_desktop/features/dashboard/domain/entities/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> getSummary();
}
