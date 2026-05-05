import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class QuantityPickerDialog extends StatefulWidget {
  const QuantityPickerDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.maxQuantity,
    this.subtitle,
    this.initialQuantity = 1,
  });

  final String title;
  final String? subtitle;
  final String confirmLabel;
  final int initialQuantity;
  final int maxQuantity;

  @override
  State<QuantityPickerDialog> createState() => _QuantityPickerDialogState();
}

class _QuantityPickerDialogState extends State<QuantityPickerDialog> {
  late final TextEditingController _controller;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity.clamp(1, widget.maxQuantity);
    _controller = TextEditingController(text: '$_quantity');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateQuantity(int quantity) {
    setState(() {
      _quantity = quantity.clamp(1, widget.maxQuantity);
      _controller.text = '$_quantity';
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
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
            border: Border.all(color: isDark ? AppTheme.border : AppTheme.lightBg4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  _StepButton(
                    icon: Icons.remove_rounded,
                    onPressed: _quantity > 1 ? () => _updateQuantity(_quantity - 1) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null) {
                          return;
                        }
                        _updateQuantity(parsed);
                      },
                      decoration: const InputDecoration(labelText: 'Cantidad'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StepButton(
                    icon: Icons.add_rounded,
                    onPressed: _quantity < widget.maxQuantity
                        ? () => _updateQuantity(_quantity + 1)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Disponible: ${widget.maxQuantity}',
                style: Theme.of(context).textTheme.bodySmall,
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
                      onPressed: () => Navigator.of(context).pop(_quantity),
                      child: Text(widget.confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 42,
      height: 42,
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: onPressed == null
              ? (isDark ? AppTheme.bg2 : AppTheme.lightBg2)
              : (isDark ? AppTheme.bg1 : AppTheme.lightBg1),
          foregroundColor: onPressed == null
              ? (isDark ? AppTheme.muted : AppTheme.lightGrey)
              : (isDark ? AppTheme.fg : AppTheme.lightTextStrong),
          side: BorderSide(color: isDark ? AppTheme.border : AppTheme.lightBg4),
        ),
        icon: Icon(icon),
      ),
    );
  }
}
