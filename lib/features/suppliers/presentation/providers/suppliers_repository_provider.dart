import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/dio_provider.dart';
import 'package:pos_desktop/features/suppliers/data/datasources/suppliers_remote_datasource.dart';
import 'package:pos_desktop/features/suppliers/data/repositories/suppliers_repository_impl.dart';
import 'package:pos_desktop/features/suppliers/domain/repositories/suppliers_repository.dart';

final suppliersRemoteDatasourceProvider = Provider<SuppliersRemoteDatasource>((
  ref,
) {
  return SuppliersRemoteDatasource(ref.watch(dioProvider));
});

final suppliersRepositoryProvider = Provider<SuppliersRepository>((ref) {
  return SuppliersRepositoryImpl(ref.watch(suppliersRemoteDatasourceProvider));
});
