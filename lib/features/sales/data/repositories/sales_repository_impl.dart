import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:pos_desktop/features/sales/domain/entities/sale_detail.dart';
import 'package:pos_desktop/features/sales/domain/entities/sale_list_item.dart';
import 'package:pos_desktop/features/sales/domain/repositories/sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  const SalesRepositoryImpl(this._remoteDatasource);

  final SalesRemoteDatasource _remoteDatasource;

  @override
  Future<PaginatedResponse<SaleListItem>> getSales({
    int page = 1,
    String? search,
    String? paymentMethod,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final response = await _remoteDatasource.getSales(
      page: page,
      search: search,
      paymentMethod: paymentMethod,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    return PaginatedResponse<SaleListItem>(
      items: response.items,
      currentPage: response.currentPage,
      lastPage: response.lastPage,
      perPage: response.perPage,
      total: response.total,
      nextPageUrl: response.nextPageUrl,
    );
  }

  @override
  Future<SaleDetail> getSaleById(int id) {
    return _remoteDatasource.getSaleById(id);
  }
}
