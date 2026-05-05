import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/config/operation_context_provider.dart';
import 'package:pos_desktop/core/network/dio_provider.dart';
import 'package:pos_desktop/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:pos_desktop/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:pos_desktop/features/inventory/domain/repositories/inventory_repository.dart';

final inventoryRemoteDatasourceProvider = Provider<InventoryRemoteDatasource>((ref) {
  return InventoryRemoteDatasource(
    ref.watch(dioProvider),
    ref.watch(operationContextProvider),
  );
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(ref.watch(inventoryRemoteDatasourceProvider));
});
