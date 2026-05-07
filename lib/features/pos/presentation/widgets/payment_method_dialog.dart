import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/pos/presentation/models/payment_submission.dart';

class PaymentMethodDialog extends StatefulWidget {
  const PaymentMethodDialog({
    super.key,
    required this.total,
    required this.onSelect,
  });

  final double total;
  final ValueChanged<PaymentSubmission> onSelect;

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  String? _selectedMethod;
  final _cashFormKey = GlobalKey<FormState>();
  final _receivedAmountController = TextEditingController();

  @override
  void dispose() {
    _receivedAmountController.dispose();
    super.dispose();
  }

  double get _receivedAmount =>
      double.tryParse(_receivedAmountController.text.trim()) ?? 0;

  double get _changeAmount => _receivedAmount - widget.total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final dialogSurface = isDark ? AppTheme.panel : AppTheme.lightBg0;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final summaryBackground = isDark ? AppTheme.bgBlue : AppTheme.lightBgBlue;
    final summaryBorderColor = isDark
        ? AppTheme.accent.withValues(alpha: 0.28)
        : AppTheme.lightAccent.withValues(alpha: 0.16);
    final summaryShadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.08)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);
    final summaryLabelColor = textTheme.bodyMedium?.color ?? AppTheme.muted;
    final changePanelColor = isDark ? AppTheme.bg2 : AppTheme.lightBg1;
    final changeShadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.08)
        : AppTheme.lightTextStrong.withValues(alpha: 0.06);
    final successColor = isDark ? AppTheme.success : AppTheme.lightSuccess;
    final mutedValueColor = textTheme.bodyMedium?.color ?? AppTheme.muted;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: dialogSurface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Metodo de pago',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selecciona como deseas cobrar esta venta. En efectivo puedes capturar el monto recibido y el cambio.',
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
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: summaryBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: summaryBorderColor),
                  boxShadow: [
                    BoxShadow(
                      color: summaryShadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total a cobrar',
                      style: TextStyle(
                        color: summaryLabelColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${widget.total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _PaymentTile(
                icon: Icons.payments_rounded,
                title: 'Efectivo',
                subtitle:
                    'Cobro inmediato en caja con monto recibido y cambio.',
                selected: _selectedMethod == 'cash',
                onTap: () {
                  setState(() {
                    _selectedMethod = 'cash';
                  });
                },
              ),
              const SizedBox(height: 12),
              _PaymentTile(
                icon: Icons.credit_card_rounded,
                title: 'Tarjeta',
                subtitle: 'Cobro con terminal o integracion bancaria despues.',
                selected: _selectedMethod == 'card',
                onTap: () {
                  widget.onSelect(const PaymentSubmission(method: 'card'));
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
              _PaymentTile(
                icon: Icons.sync_alt_rounded,
                title: 'Transferencia',
                subtitle: 'Cobro por transferencia bancaria o SPEI.',
                selected: _selectedMethod == 'transfer',
                onTap: () {
                  widget.onSelect(const PaymentSubmission(method: 'transfer'));
                  Navigator.of(context).pop();
                },
              ),
              if (_selectedMethod == 'cash') ...[
                const SizedBox(height: 20),
                Form(
                  key: _cashFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _receivedAmountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Monto recibido',
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          final amount = double.tryParse(value?.trim() ?? '');
                          if (amount == null || amount < widget.total) {
                            return 'El monto recibido debe ser mayor o igual al total.';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: changePanelColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: changeShadowColor,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Cambio',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              _changeAmount >= 0
                                  ? '\$${_changeAmount.toStringAsFixed(2)}'
                                  : '--',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: _changeAmount >= 0
                                        ? successColor
                                        : mutedValueColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (!_cashFormKey.currentState!.validate()) {
                              return;
                            }

                            widget.onSelect(
                              PaymentSubmission(
                                method: 'cash',
                                receivedAmount: _receivedAmount,
                                changeAmount: _changeAmount,
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.payments_rounded),
                          label: const Text('Confirmar efectivo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatefulWidget {
  const _PaymentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;

  @override
  State<_PaymentTile> createState() => _PaymentTileState();
}

class _PaymentTileState extends State<_PaymentTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.selected || _isHovered;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hoverOverlayColor = isDark
        ? AppTheme.accent.withValues(alpha: 0.05)
        : AppTheme.lightAccent.withValues(alpha: 0.04);
    final defaultBackground = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final hoverBackground = isDark ? AppTheme.bg2 : AppTheme.lightBg2;
    final selectedBackground = isDark
        ? AppTheme.bgPurple
        : AppTheme.lightBgPurple.withValues(alpha: 0.55);
    final defaultBorder = isDark ? AppTheme.border : AppTheme.lightBg4;
    final hoverBorder = isDark ? AppTheme.accent : AppTheme.lightAccent;
    final selectedBorder = isDark ? AppTheme.purple : AppTheme.lightBrand;
    final activeShadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.14)
        : AppTheme.lightTextStrong.withValues(alpha: 0.10);
    final iconDefaultBackground = isDark ? AppTheme.bg2 : AppTheme.lightBg2;
    final iconHoverBackground = isDark ? AppTheme.bg3 : AppTheme.lightBg3;
    final iconSelectedBackground = isDark
        ? AppTheme.bgBlue
        : AppTheme.lightBgBlue;
    final iconDefaultColor = textTheme.bodyMedium?.color ?? AppTheme.grey;
    final iconHoverColor = colorScheme.onSurface;
    final iconSelectedColor = isDark
        ? AppTheme.filledBlue
        : AppTheme.lightBrand;
    final trailingColor = widget.selected
        ? selectedBorder
        : _isHovered
        ? hoverBorder
        : textTheme.bodyMedium?.color ?? AppTheme.muted;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        hoverColor: AppTheme.transparent,
        overlayColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.hovered) ? hoverOverlayColor : null,
        ),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, isActive ? -2 : 0, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.selected
                ? selectedBackground
                : _isHovered
                ? hoverBackground
                : defaultBackground,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.selected
                  ? selectedBorder
                  : _isHovered
                  ? hoverBorder
                  : defaultBorder,
              width: widget.selected ? 1.5 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeShadowColor,
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? iconSelectedBackground
                      : _isHovered
                      ? iconHoverBackground
                      : iconDefaultBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.selected
                      ? iconSelectedColor
                      : _isHovered
                      ? iconHoverColor
                      : iconDefaultColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                widget.selected
                    ? Icons.radio_button_checked
                    : Icons.chevron_right_rounded,
                color: trailingColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
