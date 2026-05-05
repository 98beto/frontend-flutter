import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/config/operation_context_provider.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/inventory/data/models/inventory_movement_request_model.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';
import 'package:pos_desktop/features/products/presentation/providers/products_provider.dart';

class InventoryMovementDialog extends ConsumerStatefulWidget {
  const InventoryMovementDialog({super.key, this.initialProductId, this.initialType});

  final int? initialProductId;
  final String? initialType;

  @override
  ConsumerState<InventoryMovementDialog> createState() => _InventoryMovementDialogState();
}

class _InventoryMovementDialogState extends ConsumerState<InventoryMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  int? _productId;
  String _type = 'in';

  @override
  void initState() {
    super.initState();
    _productId = widget.initialProductId;
    _type = widget.initialType ?? 'in';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    Navigator.of(context).pop(
      InventoryMovementRequestModel(
        productId: _productId!,
        branchId: ref.read(operationContextProvider).branchId,
        type: _type,
        quantity: int.parse(_quantityController.text.trim()),
        notes: _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedProduct = _productId == null
        ? null
        : productsState.items.where((product) => product.id == _productId).firstOrNull;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.panel : AppTheme.lightBg0,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isDark ? AppTheme.border : AppTheme.lightBg4),
          ),
          child: Form(
            key: _formKey,
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
                            'Registrar movimiento',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Actualiza el stock mediante una entrada, salida o ajuste.',
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
                const SizedBox(height: 22),
                _MovementProductField(
                  selectedProduct: selectedProduct,
                  onTap: () async {
                    final selected = await showDialog<ProductRecord?>(
                      context: context,
                      builder: (_) => _MovementProductDialog(
                        products: productsState.items,
                        selectedProductId: _productId,
                      ),
                    );

                    if (!mounted || selected == null) {
                      return;
                    }

                    setState(() => _productId = selected.id);
                  },
                  errorText: _productId == null ? 'Selecciona un producto.' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Tipo de movimiento'),
                  items: const [
                    DropdownMenuItem<String>(value: 'in', child: Text('Entrada')),
                    DropdownMenuItem<String>(value: 'out', child: Text('Salida')),
                    DropdownMenuItem<String>(value: 'adjustment', child: Text('Ajuste')),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _type = value);
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _type == 'adjustment' ? 'Nuevo stock' : 'Cantidad',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value?.trim() ?? '');
                    if (parsed == null) {
                      return 'Ingresa una cantidad valida.';
                    }
                    if (parsed < 0) {
                      return 'La cantidad no puede ser negativa.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notas'),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.bg1 : AppTheme.lightBg1,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isDark ? AppTheme.border : AppTheme.lightBg4),
                  ),
                  child: Text(
                    _helperText(_type),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Registrar movimiento'),
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

  String _helperText(String type) {
    switch (type) {
      case 'in':
        return 'Entrada: la cantidad se sumara al stock actual del producto.';
      case 'out':
        return 'Salida: la cantidad se descontara del stock actual si hay existencias suficientes.';
      case 'adjustment':
        return 'Ajuste: el valor ingresado reemplazara el stock actual del producto.';
      default:
        return '';
    }
  }
}

class _MovementProductField extends StatelessWidget {
  const _MovementProductField({
    required this.selectedProduct,
    required this.onTap,
    this.errorText,
  });

  final ProductRecord? selectedProduct;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.muted;
    final selectedColor = isDark ? AppTheme.brand : AppTheme.lightBrand;
    final errorColor = isDark ? AppTheme.danger : AppTheme.lightDanger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.bg1 : AppTheme.lightBg1,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: errorText == null
                    ? (isDark ? AppTheme.border : AppTheme.lightBg4)
                    : errorColor,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: mutedColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedProduct == null
                        ? 'Buscar producto para el movimiento...'
                        : selectedProduct!.name,
                    style: TextStyle(
                      color: selectedProduct == null ? mutedColor : selectedColor,
                      fontWeight: selectedProduct == null ? FontWeight.w500 : FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.expand_more_rounded, color: mutedColor),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: TextStyle(color: errorColor, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _MovementProductDialog extends StatefulWidget {
  const _MovementProductDialog({required this.products, required this.selectedProductId});

  final List<ProductRecord> products;
  final int? selectedProductId;

  @override
  State<_MovementProductDialog> createState() => _MovementProductDialogState();
}

class _MovementProductDialogState extends State<_MovementProductDialog> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogSurface = isDark ? AppTheme.panel : AppTheme.lightBg0;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final selectedBackground = isDark ? AppTheme.bgBlue : AppTheme.lightBgBlue;
    final defaultBackground = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final selectedBorder = isDark ? AppTheme.accent : AppTheme.lightAccent;
    final selectedIconColor = isDark ? AppTheme.success : AppTheme.lightSuccess;

    final normalizedQuery = _search.trim().toLowerCase();
    final filteredProducts = widget.products.where((product) {
      if (normalizedQuery.isEmpty) {
        return true;
      }

      final name = product.name.toLowerCase();
      final sku = product.sku?.toLowerCase() ?? '';
      return name.contains(normalizedQuery) || sku.contains(normalizedQuery);
    }).toList();

    return Dialog(
      backgroundColor: AppTheme.transparent,
      insetPadding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 640),
          child: Container(
            decoration: BoxDecoration(
              color: dialogSurface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: borderColor),
            ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seleccionar producto',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Busca por nombre o SKU para registrar el movimiento.',
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
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _search = value),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Buscar producto...',
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron productos con esa busqueda.',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredProducts.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final selected = product.id == widget.selectedProductId;

                            return InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => Navigator.of(context).pop(product),
                              child: Ink(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: selected ? selectedBackground : defaultBackground,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: selected ? selectedBorder : borderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            product.sku?.isNotEmpty == true
                                                ? product.sku!
                                                : 'Sin SKU',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (selected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: selectedIconColor,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
