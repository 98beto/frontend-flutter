import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/clients/data/models/client_upsert_request_model.dart';
import 'package:pos_desktop/features/clients/domain/entities/client_record.dart';

class ClientFormDialog extends StatefulWidget {
  const ClientFormDialog({super.key, this.initialClient});

  final ClientRecord? initialClient;

  bool get isEditing => initialClient != null;

  @override
  State<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends State<ClientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _taxIdController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final client = widget.initialClient;
    _nameController = TextEditingController(text: client?.name ?? '');
    _emailController = TextEditingController(text: client?.email ?? '');
    _phoneController = TextEditingController(text: client?.phone ?? '');
    _taxIdController = TextEditingController(text: client?.taxId ?? '');
    _addressController = TextEditingController(text: client?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _taxIdController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    Navigator.of(context).pop(
      ClientUpsertRequestModel(
        name: _nameController.text.trim(),
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        taxId: _taxIdController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogSurface = isDark ? AppTheme.panel : AppTheme.lightBg0;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final iconBackground = isDark ? AppTheme.bgBlue : AppTheme.lightBgBlue;
    final iconColor = isDark ? AppTheme.filledBlue : AppTheme.lightBrand;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 72, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
        child: Container(
          decoration: BoxDecoration(
            color: dialogSurface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 20, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: iconBackground,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.groups_rounded, color: iconColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEditing
                                ? 'Editar cliente'
                                : 'Nuevo cliente',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Registra los datos comerciales y de contacto del cliente.',
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
              ),
              Divider(height: 1, color: borderColor.withValues(alpha: 0.8)),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nombre',
                          required: true,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _emailController,
                                label: 'Correo',
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildTextField(
                                controller: _phoneController,
                                label: 'Telefono',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _taxIdController,
                          label: 'RFC / Tax ID',
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _addressController,
                          label: 'Direccion',
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(
                          widget.isEditing
                              ? 'Guardar cambios'
                              : 'Crear cliente',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator:
          validator ??
          (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return 'Este campo es obligatorio.';
            }
            return null;
          },
      decoration: InputDecoration(labelText: label),
    );
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Ingresa un correo valido.';
    }

    return null;
  }
}
