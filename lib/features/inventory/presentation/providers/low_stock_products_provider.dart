import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/inventory_repository_provider.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';

final lowStockProductsProvider = FutureProvider<List<ProductRecord>>((
  ref,
) async {
  final response = await ref
      .watch(inventoryRepositoryProvider)
      .getLowStockProducts();
  return response.items;
});
