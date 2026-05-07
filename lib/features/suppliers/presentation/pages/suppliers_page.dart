import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/notifications/app_notification_provider.dart';
import 'package:pos_desktop/features/suppliers/data/models/supplier_upsert_request_model.dart';
import 'package:pos_desktop/features/suppliers/domain/entities/supplier_record.dart';
import 'package:pos_desktop/features/suppliers/presentation/providers/supplier_actions_provider.dart';
import 'package:pos_desktop/features/suppliers/presentation/providers/suppliers_provider.dart';
import 'package:pos_desktop/features/suppliers/presentation/widgets/supplier_form_dialog.dart';
import 'package:pos_desktop/features/suppliers/presentation/widgets/suppliers_cards_grid.dart';
import 'package:pos_desktop/features/suppliers/presentation/widgets/suppliers_filters_bar.dart';

class SuppliersPage extends ConsumerStatefulWidget {
  const SuppliersPage({super.key});

  @override
  ConsumerState<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<SuppliersPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(suppliersProvider.notifier).loadNextPage();
    }
  }

  Future<void> _openSupplierForm([SupplierRecord? supplier]) async {
    final request = await showDialog<SupplierUpsertRequestModel>(
      context: context,
      builder: (_) => SupplierFormDialog(initialSupplier: supplier),
    );

    if (!mounted || request == null) {
      return;
    }

    try {
      final notifier = ref.read(supplierActionsProvider.notifier);
      final savedSupplier = supplier == null
          ? await notifier.createSupplier(request)
          : await notifier.updateSupplier(supplier.id, request);

      if (!mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showSuccess(
            title: supplier == null
                ? 'Proveedor creado'
                : 'Proveedor actualizado',
            message:
                '${savedSupplier.name} ya esta disponible en tu directorio.',
          );
    } on ApiException catch (error) {
      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: supplier == null
                ? 'No fue posible crear el proveedor'
                : 'No fue posible actualizar el proveedor',
            message: _resolveApiErrorMessage(error),
          );
    } catch (_) {
      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: supplier == null
                ? 'No fue posible crear el proveedor'
                : 'No fue posible actualizar el proveedor',
            message: 'Verifica la conexion o intenta nuevamente.',
          );
    }
  }

  Future<void> _confirmDelete(SupplierRecord supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar proveedor'),
          content: Text(
            'Se eliminara ${supplier.name}. Esta accion no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    try {
      await ref
          .read(supplierActionsProvider.notifier)
          .deleteSupplier(supplier.id);

      if (!mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showSuccess(
            title: 'Proveedor eliminado',
            message: '${supplier.name} fue eliminado del directorio.',
          );
    } on ApiException catch (error) {
      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible eliminar el proveedor',
            message: _resolveApiErrorMessage(error),
          );
    } catch (_) {
      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible eliminar el proveedor',
            message: 'Verifica la conexion o intenta nuevamente.',
          );
    }
  }

  String _resolveApiErrorMessage(ApiException error) {
    if (error.errors == null || error.errors!.isEmpty) {
      return error.message;
    }

    final firstEntry = error.errors!.entries.first;
    final firstValue = firstEntry.value;
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first.toString();
    }
    return error.message;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(suppliersProvider);

    _searchController.value = _searchController.value.copyWith(
      text: state.search,
      selection: TextSelection.collapsed(offset: state.search.length),
      composing: TextRange.empty,
    );

    return Column(
      children: [
        SuppliersFiltersBar(
          searchController: _searchController,
          total: state.total,
          onSearchSubmitted: (value) {
            ref.read(suppliersProvider.notifier).setSearch(value);
          },
          onClearFilters: () {
            _searchController.clear();
            ref.read(suppliersProvider.notifier).clearFilters();
          },
          onCreateSupplier: _openSupplierForm,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: SuppliersCardsGrid(
              items: state.items,
              total: state.total,
              isLoadingInitial: state.isLoadingInitial,
              isLoadingMore: state.isLoadingMore,
              errorMessage: state.errorMessage,
              hasMore: state.hasMore,
              onRetry: ref.read(suppliersProvider.notifier).loadInitial,
              onEdit: _openSupplierForm,
              onDelete: _confirmDelete,
            ),
          ),
        ),
      ],
    );
  }
}
