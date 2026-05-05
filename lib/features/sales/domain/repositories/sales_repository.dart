import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/sales/domain/entities/sale_detail.dart';
import 'package:pos_desktop/features/sales/domain/entities/sale_list_item.dart';

abstract class SalesRepository {
  Future<PaginatedResponse<SaleListItem>> getSales({
    int page = 1,
    String? search,
    String? paymentMethod,
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<SaleDetail> getSaleById(int id);
}
