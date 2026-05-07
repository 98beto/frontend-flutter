import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/products/data/models/product_branch_update_request_model.dart';
import 'package:pos_desktop/features/products/data/models/product_upsert_request_model.dart';
import 'package:pos_desktop/features/products/domain/entities/product_category.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';
import 'package:pos_desktop/features/products/presentation/providers/product_categories_provider.dart';

typedef ProductFormResult = ({
  ProductUpsertRequestModel product,
  ProductBranchUpdateRequestModel branch,
});

class ProductFormDialog extends ConsumerStatefulWidget {
  const ProductFormDialog({super.key, this.initialProduct});

  final ProductRecord? initialProduct;

  bool get isEditing => initialProduct != null;

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  late final TextEditingController _unitMeasureController;
  late final TextEditingController _skuController;

  int? _categoryId;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    final product = widget.initialProduct;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _costPriceController = TextEditingController(
      text: product?.costPrice?.toStringAsFixed(2) ?? '',
    );
    _priceController = TextEditingController(
      text: product?.price.toStringAsFixed(2) ?? '',
    );
    _stockController = TextEditingController(
      text: product?.stockQuantity.toString() ?? '0',
    );
    _minStockController = TextEditingController(
      text: product?.minStock.toString() ?? '5',
    );
    _unitMeasureController = TextEditingController(
      text: product?.unitMeasure ?? 'PZA',
    );
    _skuController = TextEditingController(text: product?.sku ?? '');
    _categoryId = product?.categoryId;
    _isAvailable = product?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _costPriceController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _unitMeasureController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  void _submit() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final request = ProductUpsertRequestModel(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      costPrice: _parseOptionalDouble(_costPriceController.text),
      unitMeasure: _unitMeasureController.text.trim(),
      sku: _skuController.text.trim(),
      categoryId: _categoryId,
    );

    final branchRequest = ProductBranchUpdateRequestModel(
      price: _parseDouble(_priceController.text),
      stockQuantity: _parseInt(_stockController.text),
      minStock: _parseInt(_minStockController.text),
      isAvailable: _isAvailable,
    );

    Navigator.of(context).pop((product: request, branch: branchRequest));
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(productCategoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogSurface = isDark ? AppTheme.panel : AppTheme.lightBg0;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final iconBackground = isDark ? AppTheme.bgBlue : AppTheme.lightBgBlue;
    final iconColor = isDark ? AppTheme.filledBlue : AppTheme.lightBrand;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 72, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
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
                      child: Icon(Icons.inventory_2_rounded, color: iconColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEditing
                                ? 'Editar producto'
                                : 'Nuevo producto',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Completa la informacion comercial, inventario e identificacion del producto.',
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _FormSection(
                                title: 'General',
                                subtitle:
                                    'Informacion base y visibilidad del producto.',
                                child: Column(
                                  children: [
                                    _buildTextField(
                                      controller: _nameController,
                                      label: 'Nombre',
                                      required: true,
                                    ),
                                    const SizedBox(height: 14),
                                    categoriesAsync.when(
                                      loading: () =>
                                          const LinearProgressIndicator(
                                            minHeight: 2,
                                          ),
                                      error: (_, _) => const SizedBox.shrink(),
                                      data: (categories) {
                                        return DropdownButtonFormField<int?>(
                                          initialValue: _categoryId,
                                          decoration: const InputDecoration(
                                            labelText: 'Categoria',
                                          ),
                                          items: [
                                            const DropdownMenuItem<int?>(
                                              value: null,
                                              child: Text('Sin categoria'),
                                            ),
                                            ...categories.map(
                                              _buildCategoryOption,
                                            ),
                                          ],
                                          onChanged: (value) => setState(
                                            () => _categoryId = value,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    _buildTextField(
                                      controller: _descriptionController,
                                      label: 'Descripcion',
                                      maxLines: 4,
                                    ),
                                    const SizedBox(height: 14),
                                    SwitchListTile.adaptive(
                                      value: _isAvailable,
                                      contentPadding: EdgeInsets.zero,
                                      title: const Text(
                                        'Disponible en esta sucursal',
                                      ),
                                      subtitle: const Text(
                                        'Controla si el producto puede venderse en la sucursal autenticada.',
                                      ),
                                      onChanged: (value) =>
                                          setState(() => _isAvailable = value),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                children: [
                                  _FormSection(
                                    title: 'Precio',
                                    subtitle: 'Costo y precio de venta.',
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildTextField(
                                            controller: _costPriceController,
                                            label: 'Costo',
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            validator: _validateOptionalDouble,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: _buildTextField(
                                            controller: _priceController,
                                            label: 'Precio',
                                            required: true,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            validator: _validateRequiredDouble,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _FormSection(
                                    title: 'Inventario',
                                    subtitle:
                                        'Existencia actual, minimo y unidad.',
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildTextField(
                                                controller: _stockController,
                                                label: 'Stock actual',
                                                required: true,
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: _validateRequiredInt,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: _buildTextField(
                                                controller: _minStockController,
                                                label: 'Stock minimo',
                                                required: true,
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: _validateRequiredInt,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        _buildTextField(
                                          controller: _unitMeasureController,
                                          label: 'Unidad de medida',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _FormSection(
                                    title: 'Identificacion',
                                    subtitle:
                                        'SKU global del producto dentro del catalogo.',
                                    child: Column(
                                      children: [
                                        _buildTextField(
                                          controller: _skuController,
                                          label: 'SKU',
                                          required: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 1, color: borderColor.withValues(alpha: 0.8)),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: Icon(
                        widget.isEditing
                            ? Icons.save_rounded
                            : Icons.add_rounded,
                      ),
                      label: Text(
                        widget.isEditing
                            ? 'Guardar cambios'
                            : 'Guardar producto',
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

  DropdownMenuItem<int?> _buildCategoryOption(ProductCategory category) {
    return DropdownMenuItem<int?>(
      value: category.id,
      child: Text(category.name),
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
      validator: validator ?? (required ? _validateRequiredText : null),
      decoration: InputDecoration(labelText: label),
    );
  }

  String? _validateRequiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }
    return null;
  }

  String? _validateRequiredDouble(String? value) {
    final parsed = _parseOptionalDouble(value);
    if (parsed == null) {
      return 'Ingresa un numero valido.';
    }
    if (parsed < 0) {
      return 'No puede ser menor a 0.';
    }
    return null;
  }

  String? _validateOptionalDouble(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return _validateRequiredDouble(value);
  }

  String? _validateRequiredInt(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) {
      return 'Ingresa un numero entero valido.';
    }
    if (parsed < 0) {
      return 'No puede ser menor a 0.';
    }
    return null;
  }

  double _parseDouble(String value) => double.parse(value.trim());

  double? _parseOptionalDouble(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    return double.tryParse(trimmed);
  }

  int _parseInt(String value) => int.parse(value.trim());
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionColor = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: sectionColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
