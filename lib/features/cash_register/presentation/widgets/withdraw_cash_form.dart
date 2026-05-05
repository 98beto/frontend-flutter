import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class WithdrawCashForm extends StatefulWidget {
  const WithdrawCashForm({super.key, required this.onSubmit, this.isSubmitting = false});

  final Future<void> Function(double amount, String? notes) onSubmit;
  final bool isSubmitting;

  @override
  State<WithdrawCashForm> createState() => _WithdrawCashFormState();
}

class _WithdrawCashFormState extends State<WithdrawCashForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    await widget.onSubmit(
      amount,
      _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentBackground = isDark ? AppTheme.bgYellow : AppTheme.lightBgYellow;
    final accentColor = isDark ? AppTheme.orange : AppTheme.lightOrange;
    final buttonForeground = isDark ? AppTheme.black : AppTheme.lightBase00;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accentBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.outbox_rounded,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Retiro rapido',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Salida manual de efectivo',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: accentBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monto a retirar',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Monto',
                        prefixText: '\$',
                      ),
                      style: Theme.of(context).textTheme.headlineMedium,
                      validator: (value) {
                        final amount = double.tryParse(value?.trim() ?? '');
                        if (amount == null || amount <= 0) {
                          return 'Ingresa un monto valido mayor a cero.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Motivo o notas',
                  hintText: 'Ej. gastos operativos, caja chica, traslado',
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: buttonForeground,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: widget.isSubmitting ? null : _handleSubmit,
                  icon: const Icon(Icons.outbox_rounded),
                  label: Text(
                    widget.isSubmitting ? 'Registrando retiro...' : 'Registrar retiro',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ideal para retiros operativos durante el turno sin cerrar la sesion.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
