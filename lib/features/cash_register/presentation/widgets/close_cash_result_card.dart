import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/cash_register/domain/entities/cash_close_result.dart';

class CloseCashResultCard extends StatelessWidget {
  const CloseCashResultCard({
    super.key,
    required this.result,
    required this.onAcknowledge,
  });

  final CashCloseResult result;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBackground = isDark ? AppTheme.bgBlue : AppTheme.lightBgBlue;
    final headerBorderColor = isDark
        ? AppTheme.accent.withValues(alpha: 0.28)
        : AppTheme.lightAccent.withValues(alpha: 0.16);
    final headerIconColor = isDark ? AppTheme.filledBlue : AppTheme.lightBrand;
    final differenceShadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.08)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);
    final differenceInnerColor = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final differenceColor = result.difference > 0
        ? AppTheme.success
        : result.difference < 0
            ? AppTheme.danger
            : AppTheme.brand;
    final differenceLabel = result.difference > 0
        ? 'Sobrante'
        : result.difference < 0
            ? 'Faltante'
            : 'Sin diferencia';
    final differenceIcon = result.difference > 0
        ? Icons.trending_up_rounded
        : result.difference < 0
            ? Icons.trending_down_rounded
            : Icons.check_circle_outline_rounded;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: headerBackground,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: headerBorderColor),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 40,
                color: headerIconColor,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Caja cerrada correctamente',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Revisa el balance esperado, el monto contado y la diferencia final del turno.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: differenceColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: differenceColor.withValues(alpha: 0.24)),
                boxShadow: [
                  BoxShadow(
                    color: differenceShadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: differenceInnerColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(differenceIcon, color: differenceColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          differenceLabel,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: differenceColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${result.difference.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: differenceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _ResultRow(
              label: 'Balance esperado',
              value: '\$${result.expectedBalance.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 14),
            _ResultRow(
              label: 'Balance real',
              value: '\$${result.actualBalance.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAcknowledge,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowBackground = isDark ? AppTheme.bg2 : AppTheme.lightBg1;
    final rowBorderColor = isDark ? AppTheme.border : AppTheme.lightBg4;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: rowBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: rowBorderColor),
        ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
