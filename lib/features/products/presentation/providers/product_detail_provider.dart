import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';
import 'package:pos_desktop/features/products/presentation/providers/products_repository_provider.dart';

final productDetailProvider = FutureProvider.family<ProductRecord, int>((ref, id) async {
  return ref.watch(productsRepositoryProvider).getProductById(id);
});
