import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class SuppliersFiltersBar extends StatelessWidget {
  const SuppliersFiltersBar({
    super.key,
    required this.searchController,
    required this.total,
    required this.onSearchSubmitted,
    required this.onClearFilters,
    required this.onCreateSupplier,
  });

  final TextEditingController searchController;
  final int total;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onClearFilters;
  final VoidCallback onCreateSupplier;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBackground = isDark ? AppTheme.bgYellow : AppTheme.lightBgYellow;
    final iconColor = isDark ? AppTheme.orange : AppTheme.lightOrange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.local_shipping_rounded, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proveedores',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$total registros cargados. Controla contactos, credito y relacion comercial.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 360,
                  child: TextField(
                    controller: searchController,
                    onSubmitted: onSearchSubmitted,
                    decoration: const InputDecoration(
                      labelText: 'Buscar proveedor',
                      hintText: 'Nombre, email o telefono',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => onSearchSubmitted(searchController.text),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Buscar'),
                ),
                OutlinedButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Limpiar'),
                ),
                ElevatedButton.icon(
                  onPressed: onCreateSupplier,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nuevo proveedor'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
