import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/products/data/models/product_upsert_request_model.dart';
import 'package:pos_desktop/features/products/domain/entities/product_category.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';

abstract class ProductsRepository {
  Future<PaginatedResponse<ProductRecord>> getProducts({
    int page = 1,
    String? search,
    int? categoryId,
    bool? isActive,
    bool lowStockOnly = false,
  });

  Future<List<ProductCategory>> getCategories();

  Future<ProductRecord> getProductById(int id);

  Future<ProductRecord> createProduct(ProductUpsertRequestModel request);

  Future<ProductRecord> updateProduct(int id, ProductUpsertRequestModel request);

  Future<void> deleteProduct(int id);
}
