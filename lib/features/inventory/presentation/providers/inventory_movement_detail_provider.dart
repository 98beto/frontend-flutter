import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/inventory/domain/entities/inventory_movement.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/inventory_repository_provider.dart';

final inventoryMovementDetailProvider =
    FutureProvider.family<InventoryMovement, int>((ref, id) async {
      return ref.watch(inventoryRepositoryProvider).getMovementById(id);
    });
