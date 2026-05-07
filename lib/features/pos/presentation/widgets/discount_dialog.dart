import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class DiscountDialog extends StatefulWidget {
  const DiscountDialog({
    super.key,
    required this.subtotal,
    this.initialDiscount = 0,
  });

  final double subtotal;
  final double initialDiscount;

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialDiscount > 0
          ? widget.initialDiscount.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.panel : AppTheme.lightBg0,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? AppTheme.border : AppTheme.lightBg4,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aplicar descuento',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingresa un monto fijo. No puede ser mayor al subtotal actual de \$${widget.subtotal.toStringAsFixed(2)}.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Descuento'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un monto o usa 0 para quitar el descuento.';
                    }

                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed < 0) {
                      return 'Ingresa un monto valido igual o mayor a cero.';
                    }

                    if (parsed > widget.subtotal) {
                      return 'El descuento no puede superar el subtotal actual.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final discount =
                              double.tryParse(_controller.text.trim()) ?? 0;
                          Navigator.of(context).pop(discount);
                        },
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
