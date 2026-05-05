import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/dio_provider.dart';
import 'package:pos_desktop/features/products/data/datasources/products_remote_datasource.dart';
import 'package:pos_desktop/features/products/data/repositories/products_repository_impl.dart';
import 'package:pos_desktop/features/products/domain/repositories/products_repository.dart';

final productsRemoteDatasourceProvider = Provider<ProductsRemoteDatasource>((ref) {
  return ProductsRemoteDatasource(ref.watch(dioProvider));
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(ref.watch(productsRemoteDatasourceProvider));
});
