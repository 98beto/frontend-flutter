import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/notifications/app_notification_provider.dart';
import 'package:pos_desktop/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:pos_desktop/features/inventory/data/models/inventory_movement_request_model.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/inventory_movement_actions_provider.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/inventory_movements_provider.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/low_stock_products_provider.dart';
import 'package:pos_desktop/features/inventory/presentation/widgets/inventory_filters_bar.dart';
import 'package:pos_desktop/features/inventory/presentation/widgets/inventory_movement_detail_dialog.dart';
import 'package:pos_desktop/features/inventory/presentation/widgets/inventory_movement_dialog.dart';
import 'package:pos_desktop/features/inventory/presentation/widgets/inventory_movements_list.dart';
import 'package:pos_desktop/features/inventory/presentation/widgets/inventory_summary_cards.dart';
import 'package:pos_desktop/features/inventory/presentation/widgets/low_stock_panel.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
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
      ref.read(inventoryMovementsProvider.notifier).loadNextPage();
    }
  }

  Future<void> _openMovementDialog({int? productId, String? type}) async {
    final request = await showDialog<InventoryMovementRequestModel>(
      context: context,
      builder: (_) => InventoryMovementDialog(
        initialProductId: productId,
        initialType: type,
      ),
    );

    if (!mounted || request == null) {
      return;
    }

    try {
      final movement = await ref
          .read(inventoryMovementActionsProvider.notifier)
          .createMovement(request);

      if (!mounted) {
        return;
      }

      ref.read(appNotificationProvider.notifier).showSuccess(
        title: 'Movimiento registrado',
        message:
            '${_typeLabel(movement.type)} aplicada a ${movement.productName} por ${movement.quantity}.',
      );
    } on ApiException catch (error) {
      ref.read(appNotificationProvider.notifier).showError(
        title: 'No fue posible registrar el movimiento',
        message: _resolveApiErrorMessage(error),
      );
    } catch (_) {
      ref.read(appNotificationProvider.notifier).showError(
        title: 'No fue posible registrar el movimiento',
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

  String _typeLabel(String type) {
    switch (type) {
      case 'in':
        return 'Entrada';
      case 'out':
        return 'Salida';
      case 'adjustment':
        return 'Ajuste';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final movementsState = ref.watch(inventoryMovementsProvider);
    final lowStockAsync = ref.watch(lowStockProductsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dashboardAsync.when(
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (summary) => InventorySummaryCards(
              summary: summary,
              onCreateMovement: _openMovementDialog,
            ),
          ),
          const SizedBox(height: 20),
          InventoryFiltersBar(
            selectedProductId: movementsState.productId,
            selectedType: movementsState.type,
            selectedSource: movementsState.source,
            onProductChanged: (value) {
              ref.read(inventoryMovementsProvider.notifier).setProductId(value);
            },
            onTypeChanged: (value) {
              ref.read(inventoryMovementsProvider.notifier).setType(value);
            },
            onSourceChanged: (value) {
              ref.read(inventoryMovementsProvider.notifier).setSource(value);
            },
            onClearFilters: () {
              ref.read(inventoryMovementsProvider.notifier).clearFilters();
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Historial de movimientos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            '${movementsState.total} movimientos registrados',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 520,
            child: InventoryMovementsList(
              items: movementsState.items,
              scrollController: _scrollController,
              isLoadingInitial: movementsState.isLoadingInitial,
              isLoadingMore: movementsState.isLoadingMore,
              errorMessage: movementsState.errorMessage,
              onRetry: ref.read(inventoryMovementsProvider.notifier).loadInitial,
              onOpenDetail: (movement) {
                showDialog<void>(
                  context: context,
                  builder: (_) => InventoryMovementDetailDialog(movementId: movement.id),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          lowStockAsync.when(
            loading: () => const LowStockPanel(
              items: [],
              isLoading: true,
              errorMessage: null,
              onRetry: _emptyCallback,
              onQuickAdjustment: _emptyProductCallback,
            ),
            error: (error, _) => LowStockPanel(
              items: const [],
              isLoading: false,
              errorMessage: error.toString(),
              onRetry: () => ref.invalidate(lowStockProductsProvider),
              onQuickAdjustment: _emptyProductCallback,
            ),
            data: (items) => LowStockPanel(
              items: items,
              isLoading: false,
              errorMessage: null,
              onRetry: () => ref.invalidate(lowStockProductsProvider),
              onQuickAdjustment: (product) =>
                  _openMovementDialog(productId: product.id, type: 'adjustment'),
            ),
          ),
        ],
      ),
    );
  }
}

void _emptyCallback() {}

void _emptyProductCallback(ProductRecord _) {}
