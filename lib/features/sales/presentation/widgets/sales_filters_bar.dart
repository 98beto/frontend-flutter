import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class SalesFiltersBar extends StatelessWidget {
  const SalesFiltersBar({
    super.key,
    required this.searchController,
    required this.selectedPaymentMethod,
    required this.dateFrom,
    required this.dateTo,
    required this.onSearchSubmitted,
    required this.onPaymentMethodChanged,
    required this.onPickDateFrom,
    required this.onPickDateTo,
    required this.onClearFilters,
  });

  final TextEditingController searchController;
  final String? selectedPaymentMethod;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ValueChanged<String> onSearchSubmitted;
  final ValueChanged<String?> onPaymentMethodChanged;
  final VoidCallback onPickDateFrom;
  final VoidCallback onPickDateTo;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useCompactLayout = constraints.maxWidth < 1120;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
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
                            hintText: 'Buscar por folio o cliente...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String?>(
                          initialValue: selectedPaymentMethod,
                          decoration: const InputDecoration(
                            labelText: 'Metodo de pago',
                          ),
                          items: const [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Todos'),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'cash',
                              child: Text('Efectivo'),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'card',
                              child: Text('Tarjeta'),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'transfer',
                              child: Text('Transferencia'),
                            ),
                          ],
                          onChanged: onPaymentMethodChanged,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: _DateField(
                          label: 'Desde',
                          value: dateFrom,
                          onTap: onPickDateFrom,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: _DateField(
                          label: 'Hasta',
                          value: dateTo,
                          onTap: onPickDateTo,
                        ),
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
                      hintText: 'Buscar por folio o cliente...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String?>(
                          initialValue: selectedPaymentMethod,
                          decoration: const InputDecoration(
                            labelText: 'Metodo de pago',
                          ),
                          items: const [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Todos'),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'cash',
                              child: Text('Efectivo'),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'card',
                              child: Text('Tarjeta'),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'transfer',
                              child: Text('Transferencia'),
                            ),
                          ],
                          onChanged: onPaymentMethodChanged,
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: _DateField(
                          label: 'Desde',
                          value: dateFrom,
                          onTap: onPickDateFrom,
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: _DateField(
                          label: 'Hasta',
                          value: dateTo,
                          onTap: onPickDateTo,
                        ),
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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final mutedColor = textTheme.bodyMedium?.color ?? AppTheme.muted;
    final activeColor = isDark ? AppTheme.brand : AppTheme.lightBrand;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: mutedColor, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value == null
                    ? label
                    : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}',
                style: TextStyle(
                  color: value == null ? mutedColor : activeColor,
                  fontWeight: value == null ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
