import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class CashSessionBlocker extends StatelessWidget {
  const CashSessionBlocker({
    super.key,
    required this.onGoToCash,
    required this.onDismiss,
  });

  final VoidCallback onGoToCash;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.soft.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Icon(
                    Icons.point_of_sale_rounded,
                    size: 38,
                    color: AppTheme.brand,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'No hay una caja abierta',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Para comenzar a vender necesitas abrir o gestionar una sesion de caja. Mientras no exista una sesion activa, el punto de venta permanecerá bloqueado.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onGoToCash,
                    icon: const Icon(Icons.account_balance_wallet_rounded),
                    label: const Text('Ir a caja'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cerrar aviso'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
