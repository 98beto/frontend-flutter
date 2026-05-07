import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/inventory/domain/entities/inventory_movement.dart';

class InventoryMovementsList extends StatelessWidget {
  const InventoryMovementsList({
    super.key,
    required this.items,
    required this.scrollController,
    required this.isLoadingInitial,
    required this.isLoadingMore,
    required this.errorMessage,
    required this.onRetry,
    required this.onOpenDetail,
  });

  final List<InventoryMovement> items;
  final ScrollController scrollController;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;
  final Future<void> Function() onRetry;
  final ValueChanged<InventoryMovement> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowBackground = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final rowBorder = isDark ? AppTheme.border : AppTheme.lightBg4;
    final trailingColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.muted;

    if (isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron movimientos con los filtros actuales.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final movement = items[index];
                  final color = _typeColor(movement.type, isDark);
                  final sourceColor = _sourceColor(movement.source, isDark);

                  return Material(
                    color: AppTheme.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      hoverColor: AppTheme.transparent,
                      overlayColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.hovered)
                            ? color.withValues(alpha: 0.05)
                            : null,
                      ),
                      onTap: () => onOpenDetail(movement),
                      child: Ink(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: rowBackground,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: rowBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                _typeIcon(movement.type),
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movement.productName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    movement.productSku?.isNotEmpty == true
                                        ? movement.productSku!
                                        : 'Sin SKU',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _typeLabel(movement.type),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sourceColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _sourceLabel(movement),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: sourceColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                _quantityLabel(movement),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _formatDateTime(movement.createdAt),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                movement.notes?.isNotEmpty == true
                                    ? movement.notes!
                                    : 'Sin notas',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: trailingColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isLoadingMore) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (errorMessage != null && items.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
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

  IconData _typeIcon(String type) {
    switch (type) {
      case 'in':
        return Icons.south_west_rounded;
      case 'out':
        return Icons.north_east_rounded;
      case 'adjustment':
        return Icons.tune_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  Color _typeColor(String type, bool isDark) {
    switch (type) {
      case 'in':
        return isDark ? AppTheme.success : AppTheme.lightSuccess;
      case 'out':
        return isDark ? AppTheme.danger : AppTheme.lightDanger;
      case 'adjustment':
        return isDark ? AppTheme.brand : AppTheme.lightBrand;
      default:
        return AppTheme.muted;
    }
  }

  String _quantityLabel(InventoryMovement movement) {
    final unit = movement.productUnitMeasure ?? 'PZA';
    return '${movement.quantity} $unit';
  }

  String _sourceLabel(InventoryMovement movement) {
    switch (movement.source) {
      case 'sale':
        final reference = movement.referenceId;
        return reference == null ? 'Venta' : 'Venta #$reference';
      case 'manual':
        return 'Manual';
      default:
        return movement.source;
    }
  }

  Color _sourceColor(String source, bool isDark) {
    switch (source) {
      case 'sale':
        return isDark ? AppTheme.success : AppTheme.lightSuccess;
      case 'manual':
        return isDark ? AppTheme.brand : AppTheme.lightBrand;
      default:
        return AppTheme.muted;
    }
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }
}
