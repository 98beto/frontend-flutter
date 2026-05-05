import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({
    super.key,
    required this.items,
    required this.scrollController,
    required this.isLoadingInitial,
    required this.isLoadingMore,
    required this.errorMessage,
    required this.total,
    required this.onRetry,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ProductRecord> items;
  final ScrollController scrollController;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;
  final int total;
  final Future<void> Function() onRetry;
  final ValueChanged<ProductRecord> onEdit;
  final ValueChanged<ProductRecord> onDelete;

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
        child: Text(
          'No se encontraron productos con los filtros actuales.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(
                '$total productos encontrados',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = items[index];

              return _ProductRow(
                item: item,
                stockLabel: _stockLabel(item),
                currencyLabel: _currency(item.price),
                onEdit: () => onEdit(item),
                onDelete: () => onDelete(item),
              );
            },
          ),
        ),
        if (isLoadingMore) ...[
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
        if (errorMessage != null && items.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(errorMessage!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }

  String _currency(double value) => '\$${value.toStringAsFixed(2)}';

  String _stockLabel(ProductRecord item) {
    return '${item.stockQuantity} ${item.unitMeasure} • Min ${item.minStock}';
  }
}

class _ProductRow extends StatefulWidget {
  const _ProductRow({
    required this.item,
    required this.stockLabel,
    required this.currencyLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductRecord item;
  final String stockLabel;
  final String currencyLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<_ProductRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandColor = isDark ? AppTheme.brand : AppTheme.lightBrand;
    final accentColor = isDark ? AppTheme.accent : AppTheme.lightAccent;
    final dangerColor = isDark ? AppTheme.danger : AppTheme.lightDanger;
    final rowBackground = _isHovered
        ? (isDark ? AppTheme.bg2 : AppTheme.lightBg2)
        : (isDark ? AppTheme.bg1 : AppTheme.lightBg1);
    final borderColor = _isHovered
        ? (item.isLowStock ? dangerColor : accentColor)
        : (isDark ? AppTheme.border : AppTheme.lightBg4);
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.14)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);
    final iconBackground = item.isLowStock
        ? (isDark ? AppTheme.danger.withValues(alpha: 0.12) : AppTheme.lightBgRed)
        : (isDark ? AppTheme.soft.withValues(alpha: 0.28) : AppTheme.lightBgBlue.withValues(alpha: 0.62));
    final inactiveColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.muted;
    final inactiveBackground = isDark ? AppTheme.muted.withValues(alpha: 0.12) : AppTheme.lightBg2;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: rowBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                item.isLowStock
                    ? Icons.warning_amber_rounded
                    : Icons.inventory_2_rounded,
                color: item.isLowStock ? dangerColor : brandColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    item.sku?.isNotEmpty == true ? item.sku! : 'Sin SKU registrado',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                item.categoryName ?? 'Sin categoria',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.stockLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: item.isLowStock ? dangerColor : brandColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.currencyLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(
              width: 120,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: item.isActive
                        ? (isDark ? AppTheme.success.withValues(alpha: 0.12) : AppTheme.lightBgGreen)
                        : inactiveBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    item.isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: item.isActive
                          ? (isDark ? AppTheme.success : AppTheme.lightSuccess)
                          : inactiveColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Editar producto',
              child: IconButton(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_outlined),
                color: brandColor,
              ),
            ),
            Tooltip(
              message: 'Eliminar producto',
              child: IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: dangerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
