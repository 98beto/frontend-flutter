import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/config/operation_context_provider.dart';
import 'package:pos_desktop/core/network/dio_provider.dart';
import 'package:pos_desktop/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:pos_desktop/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:pos_desktop/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardRemoteDatasourceProvider = Provider<DashboardRemoteDatasource>((ref) {
  return DashboardRemoteDatasource(
    ref.watch(dioProvider),
    ref.watch(operationContextProvider),
  );
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDatasourceProvider));
});
