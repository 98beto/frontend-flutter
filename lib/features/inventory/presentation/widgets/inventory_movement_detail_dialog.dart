import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/inventory_movement_detail_provider.dart';

class InventoryMovementDetailDialog extends ConsumerWidget {
  const InventoryMovementDetailDialog({super.key, required this.movementId});

  final int movementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementAsync = ref.watch(inventoryMovementDetailProvider(movementId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogSurface = isDark ? AppTheme.panel : AppTheme.lightBg0;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final errorColor = isDark ? AppTheme.danger : AppTheme.lightDanger;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, minHeight: 420),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: dialogSurface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor),
          ),
          child: movementAsync.when(
            loading: () => const SizedBox(
              height: 360,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => SizedBox(
              height: 360,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded, color: errorColor, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      'No fue posible cargar el movimiento.',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
            data: (movement) {
              return SizedBox(
                height: 360,
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
                                'Movimiento #${movement.id}',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatDateTime(movement.createdAt),
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
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _InfoRow(label: 'Producto', value: movement.productName),
                            const SizedBox(height: 12),
                            _InfoRow(label: 'Tipo', value: _typeLabel(movement.type)),
                            const SizedBox(height: 12),
                            _InfoRow(label: 'Origen', value: _sourceLabel(movement)),
                            if (movement.referenceId != null) ...[
                              const SizedBox(height: 12),
                              _InfoRow(label: 'Referencia', value: '#${movement.referenceId}'),
                            ],
                            const SizedBox(height: 12),
                            _InfoRow(
                              label: 'Cantidad',
                              value:
                                  '${movement.quantity} ${movement.productUnitMeasure ?? 'PZA'}',
                            ),
                            if (movement.productStockQuantity != null) ...[
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: 'Stock actual',
                                value: '${movement.productStockQuantity}',
                              ),
                            ],
                            const SizedBox(height: 12),
                            _InfoRow(
                              label: 'Notas',
                              value:
                                  movement.notes?.isNotEmpty == true ? movement.notes! : 'Sin notas',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }

  String _sourceLabel(dynamic movement) {
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
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bg1 : AppTheme.lightBg1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppTheme.border : AppTheme.lightBg4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
