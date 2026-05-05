import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/suppliers/domain/entities/supplier_record.dart';

class SuppliersCardsGrid extends StatelessWidget {
  const SuppliersCardsGrid({
    super.key,
    required this.items,
    required this.total,
    required this.isLoadingInitial,
    required this.isLoadingMore,
    required this.errorMessage,
    required this.hasMore,
    required this.onRetry,
    required this.onEdit,
    required this.onDelete,
  });

  final List<SupplierRecord> items;
  final int total;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool hasMore;
  final VoidCallback onRetry;
  final ValueChanged<SupplierRecord> onEdit;
  final ValueChanged<SupplierRecord> onDelete;

  @override
  Widget build(BuildContext context) {
    if (isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Text(
            'No hay proveedores para mostrar.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1240
            ? 3
            : constraints.maxWidth >= 820
            ? 2
            : 1;
        final spacing = 20.0;
        final cardWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$total proveedores en resultados',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: items
                  .map(
                    (item) => SizedBox(
                      width: cardWidth,
                      child: _SupplierCard(
                        item: item,
                        onEdit: () => onEdit(item),
                        onDelete: () => onDelete(item),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (isLoadingMore) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
            if (hasMore && !isLoadingMore) ...[
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Desplazate para cargar mas proveedores.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SupplierCard extends StatefulWidget {
  const _SupplierCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final SupplierRecord item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_SupplierCard> createState() => _SupplierCardState();
}

class _SupplierCardState extends State<_SupplierCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = _isHovered ? (isDark ? AppTheme.bg1 : AppTheme.lightBg1) : (isDark ? AppTheme.panel : AppTheme.lightBg0);
    final borderColor = _isHovered ? (isDark ? AppTheme.orange : AppTheme.lightOrange) : (isDark ? AppTheme.border : AppTheme.lightBg4);
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.18)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);
    final iconBackground = isDark ? AppTheme.bgYellow : AppTheme.lightBgYellow;
    final iconColor = isDark ? AppTheme.orange : AppTheme.lightOrange;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.storefront_rounded, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _InfoBlock(label: 'Contacto', value: widget.item.contactPerson ?? 'Sin contacto'),
              _InfoBlock(label: 'Correo', value: widget.item.email ?? 'Sin correo'),
              _InfoBlock(label: 'Telefono', value: widget.item.phone ?? 'Sin telefono'),
              _InfoBlock(
                label: 'Credito',
                value: '${widget.item.creditDays ?? 0} dias',
              ),
              _InfoBlock(label: 'Direccion', value: widget.item.address ?? 'Sin direccion'),
              _InfoBlock(label: 'Banco', value: widget.item.bankInfo ?? 'Sin datos bancarios'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Eliminar'),
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

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
