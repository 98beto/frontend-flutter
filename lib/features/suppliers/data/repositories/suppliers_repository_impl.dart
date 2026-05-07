import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/suppliers/data/datasources/suppliers_remote_datasource.dart';
import 'package:pos_desktop/features/suppliers/data/models/supplier_upsert_request_model.dart';
import 'package:pos_desktop/features/suppliers/domain/entities/supplier_record.dart';
import 'package:pos_desktop/features/suppliers/domain/repositories/suppliers_repository.dart';

class SuppliersRepositoryImpl implements SuppliersRepository {
  const SuppliersRepositoryImpl(this._remoteDatasource);

  final SuppliersRemoteDatasource _remoteDatasource;

  @override
  Future<PaginatedResponse<SupplierRecord>> getSuppliers({
    int page = 1,
    String? search,
  }) async {
    final response = await _remoteDatasource.getSuppliers(
      page: page,
      search: search,
    );

    return PaginatedResponse<SupplierRecord>(
      items: response.items,
      currentPage: response.currentPage,
      lastPage: response.lastPage,
      perPage: response.perPage,
      total: response.total,
      nextPageUrl: response.nextPageUrl,
    );
  }

  @override
  Future<SupplierRecord> createSupplier(SupplierUpsertRequestModel request) {
    return _remoteDatasource.createSupplier(request);
  }

  @override
  Future<SupplierRecord> updateSupplier(
    int id,
    SupplierUpsertRequestModel request,
  ) {
    return _remoteDatasource.updateSupplier(id, request);
  }

  @override
  Future<void> deleteSupplier(int id) {
    return _remoteDatasource.deleteSupplier(id);
  }
}
