import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/products_provider.dart'
    as pos_products;
import 'package:pos_desktop/features/products/data/models/product_upsert_request_model.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';
import 'package:pos_desktop/features/products/presentation/providers/product_detail_provider.dart';
import 'package:pos_desktop/features/products/presentation/providers/products_provider.dart';
import 'package:pos_desktop/features/products/presentation/providers/products_repository_provider.dart';

final productActionsProvider =
    AsyncNotifierProvider<ProductActionsNotifier, ProductRecord?>(
  ProductActionsNotifier.new,
);

class ProductActionsNotifier extends AsyncNotifier<ProductRecord?> {
  @override
  Future<ProductRecord?> build() async => null;

  Future<ProductRecord> createProduct(ProductUpsertRequestModel request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productsRepositoryProvider).createProduct(request),
    );

    _invalidateRelatedData();
    return state.requireValue!;
  }

  Future<ProductRecord> updateProduct(
    int id,
    ProductUpsertRequestModel request,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productsRepositoryProvider).updateProduct(id, request),
    );

    ref.invalidate(productDetailProvider(id));
    _invalidateRelatedData();
    return state.requireValue!;
  }

  Future<void> deleteProduct(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(productsRepositoryProvider).deleteProduct(id);
      return null;
    });

    ref.invalidate(productDetailProvider(id));
    _invalidateRelatedData();
  }

  void _invalidateRelatedData() {
    ref.invalidate(productsProvider);
    ref.invalidate(pos_products.productsProvider);
    ref.invalidate(dashboardProvider);
  }
}
