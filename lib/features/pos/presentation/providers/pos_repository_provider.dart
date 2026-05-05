import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/config/operation_context_provider.dart';
import 'package:pos_desktop/core/network/dio_provider.dart';
import 'package:pos_desktop/features/pos/data/datasources/pos_remote_datasource.dart';
import 'package:pos_desktop/features/pos/data/repositories/pos_repository_impl.dart';
import 'package:pos_desktop/features/pos/domain/repositories/pos_repository.dart';

final posRemoteDatasourceProvider = Provider<PosRemoteDatasource>((ref) {
  return PosRemoteDatasource(
    ref.watch(dioProvider),
    ref.watch(operationContextProvider),
  );
});

final posRepositoryProvider = Provider<PosRepository>((ref) {
  return PosRepositoryImpl(ref.watch(posRemoteDatasourceProvider));
});
