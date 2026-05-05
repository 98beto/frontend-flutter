import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/suppliers/data/models/supplier_upsert_request_model.dart';
import 'package:pos_desktop/features/suppliers/domain/entities/supplier_record.dart';

class SupplierFormDialog extends StatefulWidget {
  const SupplierFormDialog({super.key, this.initialSupplier});

  final SupplierRecord? initialSupplier;

  bool get isEditing => initialSupplier != null;

  @override
  State<SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends State<SupplierFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactPersonController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _creditDaysController;
  late final TextEditingController _addressController;
  late final TextEditingController _bankInfoController;

  @override
  void initState() {
    super.initState();
    final supplier = widget.initialSupplier;
    _nameController = TextEditingController(text: supplier?.name ?? '');
    _contactPersonController = TextEditingController(text: supplier?.contactPerson ?? '');
    _emailController = TextEditingController(text: supplier?.email ?? '');
    _phoneController = TextEditingController(text: supplier?.phone ?? '');
    _creditDaysController = TextEditingController(
      text: (supplier?.creditDays ?? 0).toString(),
    );
    _addressController = TextEditingController(text: supplier?.address ?? '');
    _bankInfoController = TextEditingController(text: supplier?.bankInfo ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _creditDaysController.dispose();
    _addressController.dispose();
    _bankInfoController.dispose();
    super.dispose();
  }

  void _submit() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    Navigator.of(context).pop(
      SupplierUpsertRequestModel(
        name: _nameController.text.trim(),
        contactPerson: _contactPersonController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        creditDays: _parseCreditDays(),
        bankInfo: _bankInfoController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogSurface = isDark ? AppTheme.panel : AppTheme.lightBg0;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final iconBackground = isDark ? AppTheme.bgYellow : AppTheme.lightBgYellow;
    final iconColor = isDark ? AppTheme.orange : AppTheme.lightOrange;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 72, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 720),
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
                      child: Icon(
                        Icons.local_shipping_rounded,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEditing ? 'Editar proveedor' : 'Nuevo proveedor',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Centraliza datos operativos, credito y contacto del proveedor.',
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
                                controller: _contactPersonController,
                                label: 'Persona de contacto',
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildTextField(
                                controller: _creditDaysController,
                                label: 'Dias de credito',
                                keyboardType: TextInputType.number,
                                validator: _validateCreditDays,
                              ),
                            ),
                          ],
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
                          controller: _addressController,
                          label: 'Direccion',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _bankInfoController,
                          label: 'Informacion bancaria',
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
                          widget.isEditing ? 'Guardar cambios' : 'Crear proveedor',
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
      validator: validator ??
          (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return 'Este campo es obligatorio.';
            }
            return null;
          },
      decoration: InputDecoration(labelText: label),
    );
  }

  int _parseCreditDays() {
    return int.tryParse(_creditDaysController.text.trim()) ?? 0;
  }

  String? _validateCreditDays(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }

    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return 'Ingresa un numero valido igual o mayor a cero.';
    }

    return null;
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
