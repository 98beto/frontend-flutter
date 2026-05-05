import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/products/presentation/providers/product_categories_provider.dart';

class ProductsFiltersBar extends ConsumerWidget {
  const ProductsFiltersBar({
    super.key,
    required this.searchController,
    required this.selectedCategoryId,
    required this.selectedIsActive,
    required this.lowStockOnly,
    required this.onSearchSubmitted,
    required this.onCategoryChanged,
    required this.onIsActiveChanged,
    required this.onLowStockChanged,
    required this.onClearFilters,
    required this.onCreateProduct,
  });

  final TextEditingController searchController;
  final int? selectedCategoryId;
  final bool? selectedIsActive;
  final bool lowStockOnly;
  final ValueChanged<String> onSearchSubmitted;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<bool?> onIsActiveChanged;
  final ValueChanged<bool> onLowStockChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onCreateProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(productCategoriesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useCompactLayout = constraints.maxWidth < 1120;

            final categoryField = categoriesAsync.when(
              loading: () => const _DisabledInput(label: 'Categoria'),
              error: (_, _) => const _DisabledInput(label: 'Categoria'),
              data: (categories) {
                return DropdownButtonFormField<int?>(
                  isExpanded: true,
                  initialValue: selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Todas', overflow: TextOverflow.ellipsis),
                    ),
                    ...categories.map(
                      (category) => DropdownMenuItem<int?>(
                        value: category.id,
                        child: Text(category.name, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: onCategoryChanged,
                );
              },
            );

            final statusField = DropdownButtonFormField<bool?>(
              isExpanded: true,
              initialValue: selectedIsActive,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: const [
                DropdownMenuItem<bool?>(
                  value: null,
                  child: Text('Todos', overflow: TextOverflow.ellipsis),
                ),
                DropdownMenuItem<bool?>(
                  value: true,
                  child: Text('Activos', overflow: TextOverflow.ellipsis),
                ),
                DropdownMenuItem<bool?>(
                  value: false,
                  child: Text('Inactivos', overflow: TextOverflow.ellipsis),
                ),
              ],
              onChanged: onIsActiveChanged,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!useCompactLayout)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Filtros y acciones',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: onCreateProduct,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Nuevo producto'),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtros y acciones',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onCreateProduct,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Nuevo producto'),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 18),
                if (!useCompactLayout)
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: searchController,
                          onSubmitted: onSearchSubmitted,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded),
                            hintText: 'Buscar por nombre, SKU o codigo de barras...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(flex: 2, child: categoryField),
                      const SizedBox(width: 14),
                      Expanded(flex: 2, child: statusField),
                      const SizedBox(width: 14),
                      _LowStockToggle(
                        value: lowStockOnly,
                        onChanged: onLowStockChanged,
                      ),
                      const SizedBox(width: 14),
                      OutlinedButton.icon(
                        onPressed: onClearFilters,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Limpiar'),
                      ),
                    ],
                  )
                else ...[
                  TextField(
                    controller: searchController,
                    onSubmitted: onSearchSubmitted,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Buscar por nombre, SKU o codigo de barras...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(width: 240, child: categoryField),
                      SizedBox(width: 220, child: statusField),
                      _LowStockToggle(
                        value: lowStockOnly,
                        onChanged: onLowStockChanged,
                      ),
                      OutlinedButton.icon(
                        onPressed: onClearFilters,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Limpiar'),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LowStockToggle extends StatelessWidget {
  const _LowStockToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBackground = isDark ? AppTheme.bgRed : AppTheme.lightBgRed;
    final inactiveBackground = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final activeColor = isDark ? AppTheme.danger : AppTheme.lightDanger;
    final inactiveBorder = isDark ? AppTheme.border : AppTheme.lightBg4;
    final inactiveIconColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.muted;
    final inactiveTextColor = isDark ? AppTheme.brand : AppTheme.lightBrand;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => onChanged(!value),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: value ? activeBackground : inactiveBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: value ? activeColor : inactiveBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
              size: 18,
              color: value ? activeColor : inactiveIconColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Bajo stock',
              style: TextStyle(
                color: value ? activeColor : inactiveTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisabledInput extends StatelessWidget {
  const _DisabledInput({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: const Text('Cargando...'),
    );
  }
}
