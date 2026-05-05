import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/products/domain/entities/product_record.dart';

class LowStockPanel extends StatelessWidget {
  const LowStockPanel({
    super.key,
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onQuickAdjustment,
  });

  final List<ProductRecord> items;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<ProductRecord> onQuickAdjustment;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dangerColor = isDark ? AppTheme.danger : AppTheme.lightDanger;

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
                    'Alertas de bajo stock',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.danger.withValues(alpha: 0.12) : AppTheme.lightBgRed),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${items.length} alertas',
                      style: TextStyle(
                        color: dangerColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Productos cuyo stock actual ya alcanzo o bajo del minimo esperado.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(errorMessage!, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
                  ],
                ),
              )
            else if (items.isEmpty)
              Center(
                child: Text(
                  'No hay productos con bajo stock por ahora.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              )
            else
              Column(
                children: items
                    .map(
                      (item) => _LowStockRow(
                        item: item,
                        onQuickAdjustment: () => onQuickAdjustment(item),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _LowStockRow extends StatefulWidget {
  const _LowStockRow({
    required this.item,
    required this.onQuickAdjustment,
  });

  final ProductRecord item;
  final VoidCallback onQuickAdjustment;

  @override
  State<_LowStockRow> createState() => _LowStockRowState();
}

class _LowStockRowState extends State<_LowStockRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dangerColor = isDark ? AppTheme.danger : AppTheme.lightDanger;
    final rowBackground = _isHovered
        ? (isDark ? AppTheme.bg2 : AppTheme.lightBg2)
        : (isDark ? AppTheme.bg1 : AppTheme.lightBg1);
    final borderColor = _isHovered ? dangerColor : (isDark ? AppTheme.border : AppTheme.lightBg4);
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.14)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: rowBackground,
          borderRadius: BorderRadius.circular(20),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.danger.withValues(alpha: 0.12) : AppTheme.lightBgRed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.warning_amber_rounded, color: dangerColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.sku?.isNotEmpty == true ? widget.item.sku! : 'Sin SKU',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Actual ${widget.item.stockQuantity}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dangerColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Min ${widget.item.minStock}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            OutlinedButton.icon(
              onPressed: widget.onQuickAdjustment,
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Ajustar stock'),
            ),
          ],
        ),
      ),
    );
  }
}
