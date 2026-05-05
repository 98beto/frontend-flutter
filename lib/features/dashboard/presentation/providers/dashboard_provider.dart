import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:pos_desktop/features/dashboard/presentation/providers/dashboard_repository_provider.dart';

final dashboardProvider = FutureProvider<DashboardSummary>((ref) async {
  return ref.watch(dashboardRepositoryProvider).getSummary();
});
