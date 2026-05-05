import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/pos/domain/entities/category.dart';
import 'package:pos_desktop/features/pos/presentation/providers/pos_repository_provider.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.watch(posRepositoryProvider).getCategories();
});
