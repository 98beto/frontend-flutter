import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';
import 'package:pos_desktop/features/products/presentation/providers/products_provider.dart';

class InventoryFiltersBar extends ConsumerWidget {
  const InventoryFiltersBar({
    super.key,
    required this.selectedProductId,
    required this.selectedType,
    required this.selectedSource,
    required this.onProductChanged,
    required this.onTypeChanged,
    required this.onSourceChanged,
    required this.onClearFilters,
  });

  final int? selectedProductId;
  final String? selectedType;
  final String? selectedSource;
  final ValueChanged<int?> onProductChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onSourceChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsProvider);
    final selectedProduct = selectedProductId == null
        ? null
        : productsState.items.where((product) => product.id == selectedProductId).firstOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filtros de movimientos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _ProductFilterField(
                    selectedProduct: selectedProduct,
                    onTap: () async {
                      final selected = await showDialog<ProductRecord?>(
                        context: context,
                        builder: (_) => _ProductFilterDialog(
                          products: productsState.items,
                          selectedProductId: selectedProductId,
                        ),
                      );

                      if (selected == null) {
                        return;
                      }

                      onProductChanged(selected.id);
                    },
                    onClear: selectedProductId == null ? null : () => onProductChanged(null),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String?>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: const [
                      DropdownMenuItem<String?>(value: null, child: Text('Todos')),
                      DropdownMenuItem<String?>(value: 'in', child: Text('Entrada')),
                      DropdownMenuItem<String?>(value: 'out', child: Text('Salida')),
                      DropdownMenuItem<String?>(value: 'adjustment', child: Text('Ajuste')),
                    ],
                    onChanged: onTypeChanged,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String?>(
                    initialValue: selectedSource,
                    decoration: const InputDecoration(labelText: 'Origen'),
                    items: const [
                      DropdownMenuItem<String?>(value: null, child: Text('Todos')),
                      DropdownMenuItem<String?>(value: 'manual', child: Text('Manual')),
                      DropdownMenuItem<String?>(value: 'sale', child: Text('Venta')),
                    ],
                    onChanged: onSourceChanged,
                  ),
                ),
                const SizedBox(width: 14),
                OutlinedButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Limpiar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductFilterField extends StatefulWidget {
  const _ProductFilterField({
    required this.selectedProduct,
    required this.onTap,
    this.onClear,
  });

  final ProductRecord? selectedProduct;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  State<_ProductFilterField> createState() => _ProductFilterFieldState();
}

class _ProductFilterFieldState extends State<_ProductFilterField> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = _isHovered
        ? (isDark ? AppTheme.bg2 : AppTheme.lightBg2)
        : (isDark ? AppTheme.bg1 : AppTheme.lightBg1);
    final borderColor = _isHovered
        ? (isDark ? AppTheme.accent : AppTheme.lightAccent)
        : (isDark ? AppTheme.border : AppTheme.lightBg4);
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.12)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);
    final mutedColor = textTheme.bodyMedium?.color ?? AppTheme.muted;
    final selectedColor = isDark ? AppTheme.brand : AppTheme.lightBrand;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: mutedColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.selectedProduct == null
                      ? 'Buscar producto para filtrar...'
                      : widget.selectedProduct!.name,
                  style: TextStyle(
                    color: widget.selectedProduct == null
                        ? mutedColor
                        : selectedColor,
                    fontWeight: widget.selectedProduct == null
                        ? FontWeight.w500
                        : FontWeight.w600,
                  ),
                ),
              ),
              if (widget.onClear != null)
                IconButton(
                  onPressed: widget.onClear,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  splashRadius: 18,
                  color: mutedColor,
                )
              else
                Icon(Icons.expand_more_rounded, color: mutedColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductFilterDialog extends StatefulWidget {
  const _ProductFilterDialog({required this.products, required this.selectedProductId});

  final List<ProductRecord> products;
  final int? selectedProductId;

  @override
  State<_ProductFilterDialog> createState() => _ProductFilterDialogState();
}

class _ProductFilterDialogState extends State<_ProductFilterDialog> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _search.trim().toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogSurface = isDark ? AppTheme.panel : AppTheme.lightBg0;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
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
                            'Busca por nombre o SKU para aplicar el filtro.',
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

                            return _ProductFilterOption(
                              product: product,
                              selected: selected,
                              onTap: () => Navigator.of(context).pop(product),
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

class _ProductFilterOption extends StatefulWidget {
  const _ProductFilterOption({
    required this.product,
    required this.selected,
    required this.onTap,
  });

  final ProductRecord product;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ProductFilterOption> createState() => _ProductFilterOptionState();
}

class _ProductFilterOptionState extends State<_ProductFilterOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedBackground = isDark ? AppTheme.bgBlue : AppTheme.lightBgBlue;
    final hoverBackground = isDark ? AppTheme.bg2 : AppTheme.lightBg2;
    final defaultBackground = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final selectedBorder = isDark ? AppTheme.accent : AppTheme.lightAccent;
    final hoverBorder = isDark
        ? AppTheme.accent.withValues(alpha: 0.45)
        : AppTheme.lightAccent.withValues(alpha: 0.35);
    final defaultBorder = isDark ? AppTheme.border : AppTheme.lightBg4;
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.12)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);
    final successColor = isDark ? AppTheme.success : AppTheme.lightSuccess;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.selected
                ? selectedBackground
                : _isHovered
                    ? hoverBackground
                    : defaultBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.selected
                  ? selectedBorder
                  : _isHovered
                      ? hoverBorder
                      : defaultBorder,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.product.sku?.isNotEmpty == true
                          ? widget.product.sku!
                          : 'Sin SKU',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (widget.selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: successColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
