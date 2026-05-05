import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/notifications/app_notification_provider.dart';
import 'package:pos_desktop/core/network/api_exception.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/pos/presentation/providers/pos_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/saved_cart_actions_provider.dart';
import 'package:pos_desktop/features/pos/presentation/providers/saved_carts_provider.dart';

class SavedCartsDialog extends ConsumerWidget {
  const SavedCartsDialog({super.key});

  Future<void> _deleteSavedCart(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final dangerColor = isDark ? AppTheme.danger : AppTheme.lightDanger;

        return AlertDialog(
          title: const Text('Eliminar carrito'),
          content: Text('Se eliminara $name. Esta accion no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: dangerColor),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmDelete != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(savedCartActionsProvider.notifier).deleteCart(id);
      ref.invalidate(savedCartsProvider);

      if (!context.mounted) {
        return;
      }

      ref.read(appNotificationProvider.notifier).showSuccess(
        title: 'Carrito eliminado',
        message: '$name se elimino correctamente.',
      );
    } on ApiException catch (error) {
      if (!context.mounted) {
        return;
      }

      ref.read(appNotificationProvider.notifier).showError(
        title: 'No fue posible eliminar el carrito',
        message: error.message,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ref.read(appNotificationProvider.notifier).showError(
        title: 'No fue posible eliminar el carrito',
        message: 'Verifica la conexion o intenta nuevamente.',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedCartsAsync = ref.watch(savedCartsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.panel : AppTheme.lightBg0,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: isDark ? AppTheme.border : AppTheme.lightBg4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Carritos guardados',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Recupera una venta pausada cuando el carrito actual este vacio.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Expanded(
                child: savedCartsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No fue posible cargar los carritos guardados.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => ref.invalidate(savedCartsProvider),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                  data: (savedCarts) {
                    if (savedCarts.isEmpty) {
                      return Center(
                        child: Text(
                          'No hay carritos guardados disponibles.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: savedCarts.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final savedCart = savedCarts[index];

                        return _SavedCartTile(
                          savedCart: savedCart,
                          onDelete: () => _deleteSavedCart(
                            context,
                            ref,
                            savedCart.id,
                            savedCart.name,
                          ),
                          onRecover: () async {
                            final recoveredCart = await ref
                                .read(savedCartActionsProvider.notifier)
                                .recoverCart(savedCart.id);

                            ref.read(posProvider.notifier).loadSavedCart(
                              savedCartId: recoveredCart.id,
                              items: recoveredCart.items,
                              discount: recoveredCart.discountAmount,
                              customerId: recoveredCart.customerId,
                              customerName: recoveredCart.customerName,
                            );
                            ref.invalidate(savedCartsProvider);

                            if (context.mounted) {
                              ref.read(appNotificationProvider.notifier).showSuccess(
                                title: 'Carrito recuperado',
                                message: '${recoveredCart.name} se cargo en el POS.',
                              );
                              Navigator.of(context).pop();
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedCartTile extends StatefulWidget {
  const _SavedCartTile({
    required this.savedCart,
    required this.onDelete,
    required this.onRecover,
  });

  final dynamic savedCart;
  final VoidCallback onDelete;
  final Future<void> Function() onRecover;

  @override
  State<_SavedCartTile> createState() => _SavedCartTileState();
}

class _SavedCartTileState extends State<_SavedCartTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final savedCart = widget.savedCart;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = _isHovered
        ? (isDark ? AppTheme.bg2 : AppTheme.lightBg2)
        : (isDark ? AppTheme.bg1 : AppTheme.lightBg1);
    final borderColor = _isHovered
        ? (isDark ? AppTheme.accent : AppTheme.lightAccent)
        : (isDark ? AppTheme.border : AppTheme.lightBg4);
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.16)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);
    final badgeBackground = isDark ? AppTheme.bgBlue : AppTheme.lightBgBlue;
    final badgeColor = isDark ? AppTheme.filledBlue : AppTheme.lightBrand;
    final dangerColor = isDark ? AppTheme.danger : AppTheme.lightDanger;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    savedCart.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${savedCart.totalItems} articulos',
                    style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Cliente: ${savedCart.customerName ?? 'Publico general'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 6),
            Text(
              savedCart.notes?.trim().isNotEmpty == true ? savedCart.notes! : 'Sin notas',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Total: \$${savedCart.totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onDelete,
                  color: dangerColor,
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Eliminar carrito',
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: widget.onRecover,
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Recuperar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
