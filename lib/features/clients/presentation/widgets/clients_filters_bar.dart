import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class ClientsFiltersBar extends StatelessWidget {
  const ClientsFiltersBar({
    super.key,
    required this.searchController,
    required this.total,
    required this.onSearchSubmitted,
    required this.onClearFilters,
    required this.onCreateClient,
  });

  final TextEditingController searchController;
  final int total;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onClearFilters;
  final VoidCallback onCreateClient;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBackground = isDark ? AppTheme.bgBlue : AppTheme.lightBgBlue;
    final iconColor = isDark ? AppTheme.filledBlue : AppTheme.lightBrand;

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
                  child: Icon(Icons.groups_rounded, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clientes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$total registros cargados. Busca y administra tu cartera comercial.',
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
                  width: 340,
                  child: TextField(
                    controller: searchController,
                    onSubmitted: onSearchSubmitted,
                    decoration: const InputDecoration(
                      labelText: 'Buscar cliente',
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
                  onPressed: onCreateClient,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nuevo cliente'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
