import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:pos_desktop/features/inventory/data/models/inventory_movement_request_model.dart';
import 'package:pos_desktop/features/inventory/domain/entities/inventory_movement.dart';
import 'package:pos_desktop/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  const InventoryRepositoryImpl(this._remoteDatasource);

  final InventoryRemoteDatasource _remoteDatasource;

  @override
  Future<PaginatedResponse<InventoryMovement>> getMovements({
    int page = 1,
    int? productId,
    String? type,
    String? source,
  }) async {
    final response = await _remoteDatasource.getMovements(
      page: page,
      productId: productId,
      type: type,
      source: source,
    );

    return PaginatedResponse<InventoryMovement>(
      items: response.items,
      currentPage: response.currentPage,
      lastPage: response.lastPage,
      perPage: response.perPage,
      total: response.total,
      nextPageUrl: response.nextPageUrl,
    );
  }

  @override
  Future<InventoryMovement> getMovementById(int id) {
    return _remoteDatasource.getMovementById(id);
  }

  @override
  Future<InventoryMovement> createMovement(
    InventoryMovementRequestModel request,
  ) {
    return _remoteDatasource.createMovement(request);
  }

  @override
  Future<PaginatedResponse<ProductRecord>> getLowStockProducts({
    int page = 1,
  }) async {
    final response = await _remoteDatasource.getLowStockProducts(page: page);

    return PaginatedResponse<ProductRecord>(
      items: response.items,
      currentPage: response.currentPage,
      lastPage: response.lastPage,
      perPage: response.perPage,
      total: response.total,
      nextPageUrl: response.nextPageUrl,
    );
  }
}
