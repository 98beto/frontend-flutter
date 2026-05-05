import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/clients/data/datasources/clients_remote_datasource.dart';
import 'package:pos_desktop/features/clients/data/models/client_upsert_request_model.dart';
import 'package:pos_desktop/features/clients/domain/entities/client_record.dart';
import 'package:pos_desktop/features/clients/domain/repositories/clients_repository.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  const ClientsRepositoryImpl(this._remoteDatasource);

  final ClientsRemoteDatasource _remoteDatasource;

  @override
  Future<PaginatedResponse<ClientRecord>> getClients({
    int page = 1,
    String? search,
  }) async {
    final response = await _remoteDatasource.getClients(page: page, search: search);

    return PaginatedResponse<ClientRecord>(
      items: response.items,
      currentPage: response.currentPage,
      lastPage: response.lastPage,
      perPage: response.perPage,
      total: response.total,
      nextPageUrl: response.nextPageUrl,
    );
  }

  @override
  Future<ClientRecord> createClient(ClientUpsertRequestModel request) {
    return _remoteDatasource.createClient(request);
  }

  @override
  Future<ClientRecord> updateClient(int id, ClientUpsertRequestModel request) {
    return _remoteDatasource.updateClient(id, request);
  }

  @override
  Future<void> deleteClient(int id) {
    return _remoteDatasource.deleteClient(id);
  }
}
