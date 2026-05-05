import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/pos/data/datasources/pos_remote_datasource.dart';
import 'package:pos_desktop/features/pos/data/models/saved_cart_request_model.dart';
import 'package:pos_desktop/features/pos/data/models/sale_request_model.dart';
import 'package:pos_desktop/features/pos/domain/entities/cash_session.dart';
import 'package:pos_desktop/features/pos/domain/entities/category.dart';
import 'package:pos_desktop/features/pos/domain/entities/product.dart';
import 'package:pos_desktop/features/pos/domain/entities/saved_cart.dart';
import 'package:pos_desktop/features/pos/domain/entities/sale_result.dart';
import 'package:pos_desktop/features/pos/domain/repositories/pos_repository.dart';

class PosRepositoryImpl implements PosRepository {
  const PosRepositoryImpl(this._remoteDatasource);

  final PosRemoteDatasource _remoteDatasource;

  @override
  Future<PaginatedResponse<Product>> getProducts({
    int page = 1,
    String? search,
    int? categoryId,
  }) async {
    final response = await _remoteDatasource.getProducts(
      page: page,
      search: search,
      categoryId: categoryId,
    );

    return PaginatedResponse<Product>(
      items: response.items,
      currentPage: response.currentPage,
      lastPage: response.lastPage,
      perPage: response.perPage,
      total: response.total,
      nextPageUrl: response.nextPageUrl,
    );
  }

  @override
  Future<List<Category>> getCategories() {
    return _remoteDatasource.getCategories();
  }

  @override
  Future<CashSession?> getCurrentCashSession() {
    return _remoteDatasource.getCurrentCashSession();
  }

  @override
  Future<SaleResult> createSale(SaleRequestModel request) {
    return _remoteDatasource.createSale(request);
  }

  @override
  Future<PaginatedResponse<SavedCart>> getSavedCarts() async {
    final response = await _remoteDatasource.getSavedCarts();

    return PaginatedResponse<SavedCart>(
      items: response.items,
      currentPage: response.currentPage,
      lastPage: response.lastPage,
      perPage: response.perPage,
      total: response.total,
      nextPageUrl: response.nextPageUrl,
    );
  }

  @override
  Future<SavedCart> createSavedCart(SavedCartRequestModel request) {
    return _remoteDatasource.createSavedCart(request);
  }

  @override
  Future<SavedCart> recoverSavedCart(String id) {
    return _remoteDatasource.recoverSavedCart(id);
  }

  @override
  Future<SavedCart> updateSavedCart(String id, SavedCartRequestModel request) {
    return _remoteDatasource.updateSavedCart(id, request);
  }

  @override
  Future<void> deleteSavedCart(String id) {
    return _remoteDatasource.deleteSavedCart(id);
  }
}
