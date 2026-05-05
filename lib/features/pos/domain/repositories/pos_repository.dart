import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/pos/data/models/sale_request_model.dart';
import 'package:pos_desktop/features/pos/domain/entities/cash_session.dart';
import 'package:pos_desktop/features/pos/domain/entities/category.dart';
import 'package:pos_desktop/features/pos/domain/entities/product.dart';
import 'package:pos_desktop/features/pos/domain/entities/saved_cart.dart';
import 'package:pos_desktop/features/pos/data/models/saved_cart_request_model.dart';
import 'package:pos_desktop/features/pos/domain/entities/sale_result.dart';

abstract class PosRepository {
  Future<PaginatedResponse<Product>> getProducts({
    int page = 1,
    String? search,
    int? categoryId,
  });

  Future<List<Category>> getCategories();

  Future<CashSession?> getCurrentCashSession();

  Future<SaleResult> createSale(SaleRequestModel request);

  Future<PaginatedResponse<SavedCart>> getSavedCarts();

  Future<SavedCart> createSavedCart(SavedCartRequestModel request);

  Future<SavedCart> recoverSavedCart(String id);

  Future<SavedCart> updateSavedCart(String id, SavedCartRequestModel request);

  Future<void> deleteSavedCart(String id);
}
