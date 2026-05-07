import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class SaleSuccessDialog extends StatelessWidget {
  const SaleSuccessDialog({
    super.key,
    required this.saleId,
    required this.totalAmount,
    required this.paymentMethodLabel,
    this.receivedAmount,
    this.changeAmount,
  });

  final int saleId;
  final double totalAmount;
  final String paymentMethodLabel;
  final double? receivedAmount;
  final double? changeAmount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogSurface = isDark ? AppTheme.panel : AppTheme.lightBg0;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final successBackground = isDark
        ? AppTheme.success.withValues(alpha: 0.14)
        : AppTheme.lightBgGreen;
    final successColor = isDark ? AppTheme.success : AppTheme.lightSuccess;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: dialogSurface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: successBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: successColor,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Venta registrada',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'La venta fue registrada correctamente y el inventario se actualizo en el sistema.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _InfoRow(label: 'Folio', value: '#$saleId'),
              const SizedBox(height: 12),
              _InfoRow(label: 'Metodo de pago', value: paymentMethodLabel),
              const SizedBox(height: 12),
              _InfoRow(label: 'Total', value: _currency(totalAmount)),
              if (receivedAmount != null) ...[
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Monto recibido',
                  value: _currency(receivedAmount!),
                ),
              ],
              if (changeAmount != null) ...[
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Cambio',
                  value: _currency(changeAmount!),
                  valueColor: successColor,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _currency(double value) => '\$${value.toStringAsFixed(2)}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

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
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
