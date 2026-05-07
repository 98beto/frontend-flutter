import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/clients/data/models/client_upsert_request_model.dart';
import 'package:pos_desktop/features/clients/domain/entities/client_record.dart';
import 'package:pos_desktop/features/clients/presentation/providers/clients_provider.dart';
import 'package:pos_desktop/features/clients/presentation/providers/clients_repository_provider.dart';

final clientActionsProvider =
    AsyncNotifierProvider<ClientActionsNotifier, ClientRecord?>(
      ClientActionsNotifier.new,
    );

class ClientActionsNotifier extends AsyncNotifier<ClientRecord?> {
  @override
  Future<ClientRecord?> build() async => null;

  Future<ClientRecord> createClient(ClientUpsertRequestModel request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clientsRepositoryProvider).createClient(request),
    );

    ref.invalidate(clientsProvider);
    return state.requireValue!;
  }

  Future<ClientRecord> updateClient(
    int id,
    ClientUpsertRequestModel request,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clientsRepositoryProvider).updateClient(id, request),
    );

    ref.invalidate(clientsProvider);
    return state.requireValue!;
  }

  Future<void> deleteClient(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(clientsRepositoryProvider).deleteClient(id);
      return null;
    });

    ref.invalidate(clientsProvider);
  }
}
