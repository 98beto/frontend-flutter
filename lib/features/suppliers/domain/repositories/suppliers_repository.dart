import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/suppliers/data/models/supplier_upsert_request_model.dart';
import 'package:pos_desktop/features/suppliers/domain/entities/supplier_record.dart';

abstract class SuppliersRepository {
  Future<PaginatedResponse<SupplierRecord>> getSuppliers({
    int page = 1,
    String? search,
  });

  Future<SupplierRecord> createSupplier(SupplierUpsertRequestModel request);

  Future<SupplierRecord> updateSupplier(int id, SupplierUpsertRequestModel request);

  Future<void> deleteSupplier(int id);
}
