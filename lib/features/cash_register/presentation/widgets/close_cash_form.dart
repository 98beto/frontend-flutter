import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class CloseCashForm extends StatefulWidget {
  const CloseCashForm({super.key, required this.onSubmit, this.isSubmitting = false});

  final Future<void> Function(double closingBalance, String? notes) onSubmit;
  final bool isSubmitting;

  @override
  State<CloseCashForm> createState() => _CloseCashFormState();
}

class _CloseCashFormState extends State<CloseCashForm> {
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
    final accentBackground = isDark ? AppTheme.bgRed : AppTheme.lightBgRed;
    final accentColor = isDark ? AppTheme.red : AppTheme.lightDanger;
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accentBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cerrar caja',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confirma el monto final contado para terminar el turno actual y bloquear el POS hasta una nueva apertura.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final fieldsInRow = constraints.maxWidth >= 620;

                  final amountField = TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monto final contado',
                      helperText: 'Monto real presente al finalizar el turno.',
                    ),
                    validator: (value) {
                      final amount = double.tryParse(value?.trim() ?? '');
                      if (amount == null || amount < 0) {
                        return 'Ingresa un monto valido igual o mayor a cero.';
                      }
                      return null;
                    },
                  );

                  final notesField = TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notas de cierre (opcional)',
                      hintText: 'Ej. diferencia detectada, observaciones, responsable',
                    ),
                  );

                  if (fieldsInRow) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: amountField),
                        const SizedBox(width: 16),
                        Expanded(flex: 3, child: notesField),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      amountField,
                      const SizedBox(height: 16),
                      notesField,
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: buttonForeground,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: widget.isSubmitting ? null : _handleSubmit,
                  icon: const Icon(Icons.lock_rounded),
                  label: Text(
                    widget.isSubmitting ? 'Cerrando caja...' : 'Confirmar cierre de caja',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Al cerrar la caja, el sistema conservara el resultado del corte y el POS quedara bloqueado.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
