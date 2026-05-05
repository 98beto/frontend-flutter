import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class SaveCartDialog extends StatefulWidget {
  const SaveCartDialog({super.key});

  @override
  State<SaveCartDialog> createState() => _SaveCartDialogState();
}

class _SaveCartDialogState extends State<SaveCartDialog> {
  static const _emptyNotesSentinel = '__empty_notes__';

  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
              Text(
                'Guardar carrito',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Se guardara con un nombre automatico. Puedes agregar una nota opcional para identificarlo despues.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notas (opcional)'),
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
                      onPressed: () => Navigator.of(context).pop(
                        _notesController.text.trim().isEmpty
                            ? _emptyNotesSentinel
                            : _notesController.text.trim(),
                      ),
                      child: const Text('Guardar'),
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
