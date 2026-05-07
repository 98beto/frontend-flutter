import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/notifications/app_notification_provider.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';
import 'package:pos_desktop/features/products/presentation/providers/product_actions_provider.dart';
import 'package:pos_desktop/features/products/presentation/providers/products_provider.dart';
import 'package:pos_desktop/features/products/presentation/widgets/product_form_dialog.dart';
import 'package:pos_desktop/features/products/presentation/widgets/products_filters_bar.dart';
import 'package:pos_desktop/features/products/presentation/widgets/products_list.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
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
      ref.read(productsProvider.notifier).loadNextPage();
    }
  }

  Future<void> _openProductForm([ProductRecord? product]) async {
    final request = await showDialog<ProductFormResult>(
      context: context,
      builder: (_) => ProductFormDialog(initialProduct: product),
    );

    if (!mounted || request == null) {
      return;
    }

    try {
      final notifier = ref.read(productActionsProvider.notifier);
      final savedProduct = product == null
          ? await notifier.createProduct(request.product)
          : await notifier.updateProduct(
              product.id,
              request.product,
              request.branch,
            );

      if (!mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showSuccess(
            title: product == null ? 'Producto creado' : 'Producto actualizado',
            message: '${savedProduct.name} ya esta disponible en el catalogo.',
          );
    } on ApiException catch (error) {
      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: product == null
                ? 'No fue posible crear el producto'
                : 'No fue posible actualizar el producto',
            message: _resolveApiErrorMessage(error),
          );
    } catch (_) {
      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: product == null
                ? 'No fue posible crear el producto'
                : 'No fue posible actualizar el producto',
            message: 'Verifica la conexion o intenta nuevamente.',
          );
    }
  }

  Future<void> _confirmDelete(ProductRecord product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: Text(
            'Se eliminara ${product.name}. Esta accion no se puede deshacer.',
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
      await ref.read(productActionsProvider.notifier).deleteProduct(product.id);

      if (!mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showSuccess(
            title: 'Producto eliminado',
            message: '${product.name} fue eliminado del catalogo.',
          );
    } on ApiException catch (error) {
      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible eliminar el producto',
            message: _resolveApiErrorMessage(error),
          );
    } catch (_) {
      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible eliminar el producto',
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
    final state = ref.watch(productsProvider);

    _searchController.value = _searchController.value.copyWith(
      text: state.search,
      selection: TextSelection.collapsed(offset: state.search.length),
      composing: TextRange.empty,
    );

    return Column(
      children: [
        ProductsFiltersBar(
          searchController: _searchController,
          selectedCategoryId: state.categoryId,
          selectedIsActive: state.isAvailable,
          lowStockOnly: state.lowStockOnly,
          onSearchSubmitted: (value) {
            ref.read(productsProvider.notifier).setSearch(value);
          },
          onCategoryChanged: (value) {
            ref.read(productsProvider.notifier).setCategoryId(value);
          },
          onIsActiveChanged: (value) {
            ref.read(productsProvider.notifier).setIsAvailable(value);
          },
          onLowStockChanged: (value) {
            ref.read(productsProvider.notifier).setLowStockOnly(value);
          },
          onClearFilters: () {
            _searchController.clear();
            ref.read(productsProvider.notifier).clearFilters();
          },
          onCreateProduct: _openProductForm,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ProductsList(
            items: state.items,
            scrollController: _scrollController,
            isLoadingInitial: state.isLoadingInitial,
            isLoadingMore: state.isLoadingMore,
            errorMessage: state.errorMessage,
            total: state.total,
            onRetry: ref.read(productsProvider.notifier).loadInitial,
            onEdit: _openProductForm,
            onDelete: _confirmDelete,
          ),
        ),
      ],
    );
  }
}
