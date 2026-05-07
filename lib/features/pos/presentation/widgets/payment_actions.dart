import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class PaymentActions extends StatelessWidget {
  const PaymentActions({
    super.key,
    required this.onChargeSale,
    required this.onRecoverCart,
    required this.onSaveCart,
    required this.total,
    required this.isCartEmpty,
    required this.savedCartsCount,
    required this.cashSessionLabel,
    required this.canChargeSale,
    required this.hasOpenCashSession,
    required this.selectedCustomerName,
    required this.onAssignCustomer,
    required this.onClearCustomer,
    this.isSubmittingSale = false,
  });

  final VoidCallback onChargeSale;
  final VoidCallback onRecoverCart;
  final VoidCallback onSaveCart;
  final double total;
  final bool isCartEmpty;
  final int savedCartsCount;
  final String cashSessionLabel;
  final bool canChargeSale;
  final bool hasOpenCashSession;
  final String? selectedCustomerName;
  final VoidCallback onAssignCustomer;
  final VoidCallback onClearCustomer;
  final bool isSubmittingSale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final chargeLabel = isSubmittingSale
        ? 'Procesando venta...'
        : 'Cobrar ${_currency(total)}';
    final hasAssignedCustomer = selectedCustomerName?.trim().isNotEmpty == true;
    final mutedColor = textTheme.bodyMedium?.color ?? AppTheme.muted;
    final pendingBackground = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final pendingHoverBackground = isDark ? AppTheme.bg2 : AppTheme.lightBg2;
    final pendingBorder = isDark ? AppTheme.border : AppTheme.lightBg4;
    final pendingHoverBorder = isDark ? AppTheme.accent : AppTheme.lightAccent;
    final customerPanelColor = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final customerIconBackground = isDark
        ? AppTheme.bgPurple
        : AppTheme.lightBgPurple.withValues(alpha: 0.55);
    final customerIconColor = isDark ? AppTheme.purple : AppTheme.lightBrand;
    final statusPanelColor = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final statusBorderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final statusIconColor = hasOpenCashSession
        ? mutedColor
        : (isDark ? AppTheme.danger : AppTheme.lightDanger);

    final pendingButtonStyle = ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return mutedColor.withValues(alpha: 0.65);
        }
        if (states.contains(WidgetState.hovered)) {
          return colorScheme.onSurface;
        }
        return mutedColor;
      }),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return pendingBackground;
        }
        if (states.contains(WidgetState.hovered)) {
          return pendingHoverBackground;
        }
        return pendingBackground;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return (isDark ? AppTheme.accent : AppTheme.lightAccent).withValues(
            alpha: 0.08,
          );
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: pendingBorder.withValues(alpha: 0.65));
        }
        if (states.contains(WidgetState.hovered)) {
          return BorderSide(color: pendingHoverBorder);
        }
        return BorderSide(color: pendingBorder);
      }),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Acciones', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppTheme.success
                      : AppTheme.lightSuccess,
                  foregroundColor: isDark
                      ? AppTheme.black
                      : AppTheme.lightBase00,
                  minimumSize: const Size.fromHeight(60),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: canChargeSale && !isSubmittingSale
                    ? onChargeSale
                    : null,
                icon: const Icon(Icons.payments_rounded, size: 22),
                label: Text(chargeLabel),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: pendingButtonStyle,
                onPressed: isCartEmpty && savedCartsCount > 0
                    ? onRecoverCart
                    : null,
                icon: const Icon(Icons.history_rounded, size: 18),
                label: Text(
                  savedCartsCount > 0
                      ? 'Recuperar carrito ($savedCartsCount)'
                      : 'Recuperar carrito',
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: pendingButtonStyle,
                onPressed: isCartEmpty ? null : onSaveCart,
                icon: const Icon(Icons.receipt_long_rounded, size: 18),
                label: const Text('Guardar carrito'),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: customerPanelColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: pendingBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: customerIconBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 20,
                          color: customerIconColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasAssignedCustomer
                                  ? 'Cliente asignado'
                                  : 'Publico general',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasAssignedCustomer
                                  ? selectedCustomerName!
                                  : 'La venta actual no tiene cliente asociado.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: pendingButtonStyle,
                          onPressed: onAssignCustomer,
                          icon: const Icon(Icons.search_rounded, size: 18),
                          label: Text(
                            hasAssignedCustomer
                                ? 'Cambiar cliente'
                                : 'Asignar cliente',
                          ),
                        ),
                      ),
                      if (hasAssignedCustomer) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: pendingButtonStyle,
                            onPressed: onClearCustomer,
                            icon: const Icon(
                              Icons.person_off_rounded,
                              size: 18,
                            ),
                            label: const Text('Quitar'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: statusPanelColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: statusBorderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    hasOpenCashSession
                        ? Icons.lock_clock_rounded
                        : Icons.warning_amber_rounded,
                    color: statusIconColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hasOpenCashSession
                          ? 'Sesion de caja disponible'
                          : 'No hay sesion de caja abierta',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cashSessionLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _currency(double value) => '\$${value.toStringAsFixed(2)}';
}
