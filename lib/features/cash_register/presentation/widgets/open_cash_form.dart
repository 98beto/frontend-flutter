import 'package:flutter/material.dart';

import 'package:pos_desktop/core/theme/app_theme.dart';

class OpenCashForm extends StatefulWidget {
  const OpenCashForm({super.key, required this.onSubmit, this.isSubmitting = false});

  final Future<void> Function(double openingBalance, String? notes) onSubmit;
  final bool isSubmitting;

  @override
  State<OpenCashForm> createState() => _OpenCashFormState();
}

class _OpenCashFormState extends State<OpenCashForm> {
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
    final accentBackground = isDark ? AppTheme.bgGreen : AppTheme.lightBgGreen;
    final accentColor = isDark ? AppTheme.success : AppTheme.lightSuccess;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.lock_open_rounded,
                  color: accentColor,
                  size: 26,
                ),
              ),
              const SizedBox(height: 18),
              Text('Abrir caja', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text(
                'Registra el monto inicial para comenzar un nuevo turno de caja.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monto de apertura'),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Ingresa un monto valido mayor a cero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notas (opcional)'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.isSubmitting ? null : _handleSubmit,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: Text(
                    widget.isSubmitting ? 'Abriendo caja...' : 'Abrir caja',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Al abrir la caja, el POS quedara habilitado automaticamente para registrar ventas.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
