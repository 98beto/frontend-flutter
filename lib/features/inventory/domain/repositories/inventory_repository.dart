import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/inventory/data/models/inventory_movement_request_model.dart';
import 'package:pos_desktop/features/inventory/domain/entities/inventory_movement.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';

abstract class InventoryRepository {
  Future<PaginatedResponse<InventoryMovement>> getMovements({
    int page = 1,
    int? productId,
    String? type,
    String? source,
  });

  Future<InventoryMovement> getMovementById(int id);

  Future<InventoryMovement> createMovement(InventoryMovementRequestModel request);

  Future<PaginatedResponse<ProductRecord>> getLowStockProducts({int page = 1});
}
