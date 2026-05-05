import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/pos/domain/entities/saved_cart.dart';
import 'package:pos_desktop/features/pos/presentation/providers/pos_repository_provider.dart';

final savedCartsProvider = FutureProvider<List<SavedCart>>((ref) async {
  final response = await ref.watch(posRepositoryProvider).getSavedCarts();
  return response.items;
});
