import 'package:pos_desktop/core/network/paginated_response.dart';
import 'package:pos_desktop/features/clients/data/models/client_upsert_request_model.dart';
import 'package:pos_desktop/features/clients/domain/entities/client_record.dart';

abstract class ClientsRepository {
  Future<PaginatedResponse<ClientRecord>> getClients({
    int page = 1,
    String? search,
  });

  Future<ClientRecord> createClient(ClientUpsertRequestModel request);

  Future<ClientRecord> updateClient(int id, ClientUpsertRequestModel request);

  Future<void> deleteClient(int id);
}
