import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/sales/presentation/providers/sale_detail_provider.dart';

class SaleDetailDialog extends ConsumerWidget {
  const SaleDetailDialog({super.key, required this.saleId});

  final int saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleDetailAsync = ref.watch(saleDetailProvider(saleId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogSurface = isDark ? AppTheme.panel : AppTheme.lightBg0;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final panelColor = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final dangerColor = isDark ? AppTheme.danger : AppTheme.lightDanger;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 760),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: dialogSurface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor),
          ),
          child: saleDetailAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: dangerColor,
                    size: 38,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No fue posible cargar el detalle de la venta.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            data: (sale) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Venta #${sale.id}',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_formatDateTime(sale.saleDate)}  |  ${_paymentMethodLabel(sale.paymentMethod)}',
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              _InfoCard(
                                title: 'Resumen',
                                child: Column(
                                  children: [
                                    _SummaryRow(
                                      label: 'Subtotal',
                                      value: _currency(sale.subtotal),
                                    ),
                                    const SizedBox(height: 12),
                                    _SummaryRow(
                                      label: 'Descuento',
                                      value: _currency(sale.discountAmount),
                                    ),
                                    const SizedBox(height: 12),
                                    _SummaryRow(
                                      label: 'Impuestos',
                                      value: _currency(sale.taxAmount),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Divider(height: 1),
                                    ),
                                    _SummaryRow(
                                      label: 'Total',
                                      value: _currency(sale.totalAmount),
                                      emphasize: true,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _InfoCard(
                                title: 'Datos de la operacion',
                                child: Column(
                                  children: [
                                    _SummaryRow(
                                      label: 'Cliente',
                                      value:
                                          sale.customerName ??
                                          'Publico general',
                                    ),
                                    const SizedBox(height: 12),
                                    _SummaryRow(
                                      label: 'Sesion de caja',
                                      value: sale.cashSessionId != null
                                          ? '#${sale.cashSessionId}'
                                          : 'Sin sesion',
                                    ),
                                    const SizedBox(height: 12),
                                    const _SummaryRow(
                                      label: 'Estado',
                                      value: 'Completed',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 5,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: panelColor,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Productos vendidos',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: sale.items.length,
                                    separatorBuilder: (_, index) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = sale.items[index];

                                      return _DetailItemRow(
                                        name: item.productName,
                                        sku: item.sku,
                                        quantity: item.quantity,
                                        total: item.total,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
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

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }

  String _currency(double value) => '\$${value.toStringAsFixed(2)}';
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelColor = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _DetailItemRow extends StatelessWidget {
  const _DetailItemRow({
    required this.name,
    required this.sku,
    required this.quantity,
    required this.total,
  });

  final String name;
  final String? sku;
  final int quantity;
  final double total;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowColor = isDark ? AppTheme.bg1 : AppTheme.lightBg1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rowColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  sku == null || sku!.isEmpty ? 'Sin SKU' : sku!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text('x$quantity', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 20),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
