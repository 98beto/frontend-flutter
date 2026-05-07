import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/features/suppliers/data/models/supplier_upsert_request_model.dart';
import 'package:pos_desktop/features/suppliers/domain/entities/supplier_record.dart';
import 'package:pos_desktop/features/suppliers/presentation/providers/suppliers_provider.dart';
import 'package:pos_desktop/features/suppliers/presentation/providers/suppliers_repository_provider.dart';

final supplierActionsProvider =
    AsyncNotifierProvider<SupplierActionsNotifier, SupplierRecord?>(
      SupplierActionsNotifier.new,
    );

class SupplierActionsNotifier extends AsyncNotifier<SupplierRecord?> {
  @override
  Future<SupplierRecord?> build() async => null;

  Future<SupplierRecord> createSupplier(
    SupplierUpsertRequestModel request,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(suppliersRepositoryProvider).createSupplier(request),
    );

    ref.invalidate(suppliersProvider);
    return state.requireValue!;
  }

  Future<SupplierRecord> updateSupplier(
    int id,
    SupplierUpsertRequestModel request,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(suppliersRepositoryProvider).updateSupplier(id, request),
    );

    ref.invalidate(suppliersProvider);
    return state.requireValue!;
  }

  Future<void> deleteSupplier(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(suppliersRepositoryProvider).deleteSupplier(id);
      return null;
    });

    ref.invalidate(suppliersProvider);
  }
}
