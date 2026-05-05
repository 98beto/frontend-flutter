import 'package:pos_desktop/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:pos_desktop/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:pos_desktop/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remoteDatasource);

  final DashboardRemoteDatasource _remoteDatasource;

  @override
  Future<DashboardSummary> getSummary() {
    return _remoteDatasource.getSummary();
  }
}
