import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/dio_provider.dart';
import 'package:pos_desktop/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:pos_desktop/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:pos_desktop/features/sales/domain/repositories/sales_repository.dart';

final salesRemoteDatasourceProvider = Provider<SalesRemoteDatasource>((ref) {
  return SalesRemoteDatasource(ref.watch(dioProvider));
});

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepositoryImpl(ref.watch(salesRemoteDatasourceProvider));
});
