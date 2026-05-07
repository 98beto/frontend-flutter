import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/notifications/app_notification_provider.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/core/widgets/app_section_provider.dart';
import 'package:pos_desktop/core/widgets/app_sidebar.dart';
import 'package:pos_desktop/features/pos/domain/entities/cart_item.dart';
import 'package:pos_desktop/features/pos/presentation/models/payment_submission.dart';
import 'package:pos_desktop/features/pos/presentation/providers/cash_session_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/pos_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/products_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/saved_cart_actions_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/saved_carts_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/sale_submission_provider.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/cart_items_list.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/cart_summary.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/cash_session_blocker.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/discount_dialog.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/payment_actions.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/payment_method_dialog.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/product_picker_dialog.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/product_search_field.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/sale_success_dialog.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/save_cart_dialog.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/select_client_dialog.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/saved_carts_dialog.dart';
import 'package:pos_desktop/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:pos_desktop/features/sales/presentation/providers/sales_provider.dart';

class PosPage extends ConsumerWidget {
  const PosPage({super.key});

  static const _blockerBorderRadius = BorderRadius.all(Radius.circular(28));

  Future<void> _submitSale(
    BuildContext context,
    WidgetRef ref,
    PaymentSubmission submission,
  ) async {
    final state = ref.read(posProvider);

    if (state.cartItems.isEmpty) {
      ref
          .read(appNotificationProvider.notifier)
          .showWarning(
            title: 'Carrito vacio',
            message: 'Agrega productos antes de cobrar la venta.',
          );
      return;
    }

    try {
      final recoveredSavedCartId = state.activeSavedCartId;
      final result = await ref
          .read(saleSubmissionProvider.notifier)
          .submitSale(
            paymentMethod: submission.method,
            items: state.cartItems,
            discountAmount: state.discount,
            taxRate: state.taxRate,
          );

      if (recoveredSavedCartId != null) {
        await ref
            .read(savedCartActionsProvider.notifier)
            .deleteCart(recoveredSavedCartId);
        ref.invalidate(savedCartsProvider);
      }

      ref.read(posProvider.notifier)
        ..clearCart()
        ..clearDiscount();
      ref.invalidate(productsProvider);
      ref.invalidate(salesProvider);
      ref.invalidate(dashboardProvider);

      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showSuccess(
            title: 'Venta registrada',
            message:
                'Venta #${result.id} registrada por \$${result.totalAmount.toStringAsFixed(2)}.',
          );

      await showDialog<void>(
        context: context,
        builder: (_) => SaleSuccessDialog(
          saleId: result.id,
          totalAmount: result.totalAmount,
          paymentMethodLabel: _paymentMethodLabel(submission.method),
          receivedAmount: submission.receivedAmount,
          changeAmount: submission.changeAmount,
        ),
      );
    } on ApiException catch (error) {
      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible completar la venta',
            message: _resolveSaleErrorMessage(error),
          );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible completar la venta',
            message: 'Verifica la conexion o intenta nuevamente.',
          );
    }
  }

  Future<void> _saveCurrentCart(BuildContext context, WidgetRef ref) async {
    final state = ref.read(posProvider);

    if (state.cartItems.isEmpty) {
      ref
          .read(appNotificationProvider.notifier)
          .showWarning(
            title: 'Carrito vacio',
            message: 'Agrega productos antes de guardar un carrito.',
          );
      return;
    }

    final notesResult = await showDialog<String?>(
      context: context,
      builder: (_) => const SaveCartDialog(),
    );

    if (!context.mounted || notesResult == null) {
      return;
    }

    final notes = notesResult == '__empty_notes__' ? null : notesResult;
    final existingSavedCartId = state.activeSavedCartId;

    try {
      final savedCart = await ref
          .read(savedCartActionsProvider.notifier)
          .saveCart(
            items: state.cartItems,
            discountAmount: state.discount,
            notes: notes,
            existingSavedCartId: existingSavedCartId,
          );

      ref.read(posProvider.notifier)
        ..clearCart()
        ..clearDiscount();
      ref.invalidate(savedCartsProvider);

      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showSuccess(
            title: existingSavedCartId == null
                ? 'Carrito guardado'
                : 'Carrito actualizado',
            message:
                '${savedCart.name} quedo disponible para recuperarlo despues.',
          );
    } on ApiException catch (error) {
      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible guardar el carrito',
            message: error.message,
          );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ref
          .read(appNotificationProvider.notifier)
          .showError(
            title: 'No fue posible guardar el carrito',
            message: 'Verifica la conexion o intenta nuevamente.',
          );
    }
  }

  bool _shouldBlockPos(
    AsyncValue<dynamic> cashSessionAsync,
    Object? currentCashSession,
  ) {
    return !cashSessionAsync.isLoading && currentCashSession == null;
  }

  String _resolveSaleErrorMessage(ApiException error) {
    final itemErrors = error.errors?['items'];
    if (itemErrors is List && itemErrors.isNotEmpty) {
      return itemErrors.first.toString();
    }

    return error.message;
  }

  void _showQuantityLimitNotification(WidgetRef ref, CartItem item) {
    ref
        .read(appNotificationProvider.notifier)
        .showWarning(
          title: 'Cantidad no disponible',
          message:
              'Solo hay ${item.product.stock} unidades disponibles de ${item.product.name}.',
        );
  }

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Efectivo';
      case 'card':
        return 'Tarjeta';
      case 'transfer':
        return 'Transferencia';
      default:
        return method;
    }
  }

  Future<void> _showDiscountDialog(
    BuildContext context,
    WidgetRef ref,
    double subtotal,
    double currentDiscount,
  ) async {
    if (subtotal <= 0) {
      ref
          .read(appNotificationProvider.notifier)
          .showInfo(
            title: 'Sin productos en el carrito',
            message: 'Agrega productos antes de aplicar un descuento.',
          );
      return;
    }

    final discount = await showDialog<double>(
      context: context,
      builder: (_) =>
          DiscountDialog(subtotal: subtotal, initialDiscount: currentDiscount),
    );

    if (discount == null) {
      return;
    }

    ref.read(posProvider.notifier).setDiscount(discount);

    ref
        .read(appNotificationProvider.notifier)
        .showSuccess(
          title: discount > 0 ? 'Descuento aplicado' : 'Descuento eliminado',
          message: discount > 0
              ? 'Se aplico un descuento de \$${discount.toStringAsFixed(2)}.'
              : 'La venta ya no tiene descuento aplicado.',
        );
  }

  Future<void> _showClientDialog(BuildContext context, WidgetRef ref) async {
    final selection = await showDialog<ClientSelectionResult>(
      context: context,
      builder: (_) => const SelectClientDialog(),
    );

    if (!context.mounted || selection == null) {
      return;
    }

    if (selection.shouldClear) {
      ref.read(posProvider.notifier).clearCustomer();
      ref
          .read(appNotificationProvider.notifier)
          .showInfo(
            title: 'Cliente removido',
            message: 'La venta actual quedo como publico general.',
          );
      return;
    }

    if (selection.id != null && selection.name != null) {
      ref
          .read(posProvider.notifier)
          .assignCustomer(id: selection.id!, name: selection.name!);
      ref
          .read(appNotificationProvider.notifier)
          .showSuccess(
            title: 'Cliente asignado',
            message: '${selection.name} fue asociado a la venta actual.',
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posProvider);
    final notifier = ref.read(posProvider.notifier);
    final cashSessionAsync = ref.watch(cashSessionProvider);
    final savedCartsAsync = ref.watch(savedCartsProvider);
    final saleSubmissionState = ref.watch(saleSubmissionProvider);

    final currentCashSession = cashSessionAsync.valueOrNull;
    final savedCartsCount = savedCartsAsync.valueOrNull?.length ?? 0;
    final cashSessionLabel = cashSessionAsync.when(
      data: (session) {
        if (session == null) {
          return 'No hay una sesion de caja abierta. Cobrar venta permanecera bloqueado.';
        }

        return 'Sesion abierta #${session.id} desde ${session.openedAt.hour.toString().padLeft(2, '0')}:${session.openedAt.minute.toString().padLeft(2, '0')}.';
      },
      loading: () => 'Consultando sesion activa...',
      error: (error, stackTrace) =>
          'No se pudo consultar la sesion de caja actual.',
    );

    final canChargeSale =
        !state.isCartEmpty &&
        currentCashSession != null &&
        !saleSubmissionState.isLoading;
    final shouldBlockPos = _shouldBlockPos(
      cashSessionAsync,
      currentCashSession,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scanButtonBackground = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final scanButtonBorder = isDark ? AppTheme.border : AppTheme.lightBg4;
    final scanButtonForeground = isDark ? AppTheme.brand : AppTheme.lightBrand;

    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ProductSearchField(
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (_) => const ProductPickerDialog(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: scanButtonBackground,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: scanButtonBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.qr_code_scanner_rounded,
                              color: scanButtonForeground,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Escanear',
                              style: TextStyle(
                                color: scanButtonForeground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Carrito actual',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.soft.withValues(alpha: 0.35)
                                        : AppTheme.lightBgBlue,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${state.totalItems} articulos',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppTheme.brand
                                          : AppTheme.lightBrand,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Expanded(
                              child: CartItemsList(
                                items: state.cartItems,
                                onIncrement: (productId) {
                                  final wasUpdated = notifier.incrementItem(
                                    productId,
                                  );
                                  if (!wasUpdated) {
                                    final item = state.cartItems.firstWhere(
                                      (cartItem) =>
                                          cartItem.product.id == productId,
                                    );
                                    _showQuantityLimitNotification(ref, item);
                                  }
                                },
                                onDecrement: notifier.decrementItem,
                                onRemove: notifier.removeItem,
                                onSetQuantity: (productId, quantity) {
                                  final wasUpdated = notifier.setItemQuantity(
                                    productId,
                                    quantity,
                                  );
                                  if (!wasUpdated) {
                                    final item = state.cartItems.firstWhere(
                                      (cartItem) =>
                                          cartItem.product.id == productId,
                                    );
                                    _showQuantityLimitNotification(ref, item);
                                  }
                                },
                                onQuantityLimitReached: (item) =>
                                    _showQuantityLimitNotification(ref, item),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: ListView(
                children: [
                  CartSummary(
                    itemCount: state.totalItems,
                    subtotal: state.subtotal,
                    discount: state.discount,
                    taxRate: state.taxRate,
                    taxes: state.taxes,
                    total: state.total,
                    onEditDiscount: () => _showDiscountDialog(
                      context,
                      ref,
                      state.subtotal,
                      state.discount,
                    ),
                    onClearDiscount: () {
                      notifier.clearDiscount();
                      ref
                          .read(appNotificationProvider.notifier)
                          .showInfo(
                            title: 'Descuento eliminado',
                            message: 'La venta ya no tiene descuento aplicado.',
                          );
                    },
                  ),
                  const SizedBox(height: 18),
                  PaymentActions(
                    onSaveCart: () => _saveCurrentCart(context, ref),
                    total: state.total,
                    isCartEmpty: state.isCartEmpty,
                    savedCartsCount: savedCartsCount,
                    cashSessionLabel: cashSessionLabel,
                    canChargeSale: canChargeSale,
                    hasOpenCashSession: currentCashSession != null,
                    selectedCustomerName: state.selectedCustomerName,
                    onAssignCustomer: () => _showClientDialog(context, ref),
                    onClearCustomer: () {
                      notifier.clearCustomer();
                      ref
                          .read(appNotificationProvider.notifier)
                          .showInfo(
                            title: 'Cliente removido',
                            message:
                                'La venta actual quedo como publico general.',
                          );
                    },
                    isSubmittingSale: saleSubmissionState.isLoading,
                    onChargeSale: () => showDialog<void>(
                      context: context,
                      builder: (_) => PaymentMethodDialog(
                        total: state.total,
                        onSelect: (submission) =>
                            _submitSale(context, ref, submission),
                      ),
                    ),
                    onRecoverCart: () => showDialog<void>(
                      context: context,
                      builder: (_) => const SavedCartsDialog(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (shouldBlockPos) ...[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: _blockerBorderRadius,
              child: Container(color: AppTheme.overlay),
            ),
          ),
          Positioned.fill(
            child: CashSessionBlocker(
              onGoToCash: () {
                ref.read(appSectionProvider.notifier).state =
                    AppSection.cashRegister;
              },
              onDismiss: () {
                ref.read(appSectionProvider.notifier).state =
                    AppSection.dashboard;
              },
            ),
          ),
        ],
      ],
    );
  }
}
