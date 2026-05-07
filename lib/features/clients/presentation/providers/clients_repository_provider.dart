import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/dio_provider.dart';
import 'package:pos_desktop/features/clients/data/datasources/clients_remote_datasource.dart';
import 'package:pos_desktop/features/clients/data/repositories/clients_repository_impl.dart';
import 'package:pos_desktop/features/clients/domain/repositories/clients_repository.dart';

final clientsRemoteDatasourceProvider = Provider<ClientsRemoteDatasource>((
  ref,
) {
  return ClientsRemoteDatasource(ref.watch(dioProvider));
});

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) {
  return ClientsRepositoryImpl(ref.watch(clientsRemoteDatasourceProvider));
});
