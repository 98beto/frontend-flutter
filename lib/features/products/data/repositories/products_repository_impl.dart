import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/products/data/datasources/products_remote_datasource.dart';
import 'package:pos_desktop/features/products/data/models/product_branch_update_request_model.dart';
import 'package:pos_desktop/features/products/data/models/product_upsert_request_model.dart';
import 'package:pos_desktop/features/products/domain/entities/product_category.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';
import 'package:pos_desktop/features/products/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl(this._remoteDatasource);

  final ProductsRemoteDatasource _remoteDatasource;

  @override
  Future<PaginatedResponse<ProductRecord>> getProducts({
    int page = 1,
    String? search,
    int? categoryId,
    bool? isAvailable,
    bool lowStockOnly = false,
  }) async {
    final response = await _remoteDatasource.getProducts(
      page: page,
      search: search,
      categoryId: categoryId,
      isAvailable: isAvailable,
      lowStockOnly: lowStockOnly,
    );

    return PaginatedResponse<ProductRecord>(
      items: response.items,
      currentPage: response.currentPage,
      lastPage: response.lastPage,
      perPage: response.perPage,
      total: response.total,
      nextPageUrl: response.nextPageUrl,
    );
  }

  @override
  Future<List<ProductCategory>> getCategories() {
    return _remoteDatasource.getCategories();
  }

  @override
  Future<ProductRecord> getProductById(int id) {
    return _remoteDatasource.getProductById(id);
  }

  @override
  Future<ProductRecord> createProduct(ProductUpsertRequestModel request) {
    return _remoteDatasource.createProduct(request);
  }

  @override
  Future<ProductRecord> updateProduct(
    int id,
    ProductUpsertRequestModel request,
  ) {
    return _remoteDatasource.updateProduct(id, request);
  }

  @override
  Future<ProductRecord> updateBranchProduct(
    int id,
    ProductBranchUpdateRequestModel request,
  ) {
    return _remoteDatasource.updateBranchProduct(id, request);
  }

  @override
  Future<void> deleteProduct(int id) {
    return _remoteDatasource.deleteProduct(id);
  }
}
