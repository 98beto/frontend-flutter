import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/products/domain/entities/product_category.dart';
import 'package:pos_desktop/features/products/presentation/providers/products_repository_provider.dart';

final productCategoriesProvider = FutureProvider<List<ProductCategory>>((ref) async {
  return ref.watch(productsRepositoryProvider).getCategories();
});
