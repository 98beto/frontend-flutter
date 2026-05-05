import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.taxRate,
    required this.taxes,
    required this.total,
    required this.onEditDiscount,
    required this.onClearDiscount,
  });

  final int itemCount;
  final double subtotal;
  final double discount;
  final double taxRate;
  final double taxes;
  final double total;
  final VoidCallback onEditDiscount;
  final VoidCallback onClearDiscount;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = discount > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final successColor = isDark ? AppTheme.success : AppTheme.lightSuccess;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                        'Resumen de venta',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$itemCount articulos en carrito',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onEditDiscount,
                  icon: Icon(hasDiscount ? Icons.edit_rounded : Icons.sell_rounded),
                  label: Text(hasDiscount ? 'Editar descuento' : 'Aplicar descuento'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SummaryRow(label: 'Subtotal', value: _currency(subtotal)),
            const SizedBox(height: 14),
            _SummaryRow(
              label: 'Descuento',
              value: discount > 0 ? '- ${_currency(discount)}' : _currency(0),
              valueColor: discount > 0 ? successColor : null,
              action: hasDiscount
                  ? TextButton(
                      onPressed: onClearDiscount,
                      child: const Text('Quitar'),
                    )
                  : null,
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              label: 'Impuestos (IVA ${(taxRate * 100).toStringAsFixed(0)}%)',
              value: _currency(taxes),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Divider(height: 1),
            ),
            _SummaryRow(
              label: 'Total',
              value: _currency(total),
              emphasize: true,
            ),
          ],
        ),
      ),
    );
  }

  String _currency(double value) => '\$${value.toStringAsFixed(2)}';
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
    this.action,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final baseStyle = emphasize
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(child: Text(label, style: baseStyle)),
              if (action != null) ...[
                const SizedBox(width: 8),
                action!,
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: baseStyle?.copyWith(
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
