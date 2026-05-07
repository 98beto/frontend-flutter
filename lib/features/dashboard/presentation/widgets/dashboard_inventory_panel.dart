import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/dashboard/domain/entities/dashboard_summary.dart';

class DashboardInventoryPanel extends StatelessWidget {
  const DashboardInventoryPanel({super.key, required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alertBackground = isDark
        ? AppTheme.danger.withValues(alpha: 0.12)
        : AppTheme.lightDanger.withValues(alpha: 0.10);
    final alertColor = isDark ? AppTheme.danger : AppTheme.lightDanger;
    final lowStockAccent = summary.lowStockCount > 0
        ? (isDark ? AppTheme.danger : AppTheme.lightDanger)
        : (isDark ? AppTheme.success : AppTheme.lightSuccess);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Resumen de inventario',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (summary.lowStockCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: alertBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${summary.lowStockCount} alertas',
                      style: TextStyle(
                        color: alertColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _InventoryTile(
                  label: 'Total productos',
                  value: '${summary.totalProducts}',
                  icon: Icons.inventory_2_rounded,
                ),
                _InventoryTile(
                  label: 'Productos activos',
                  value: '${summary.activeProducts}',
                  icon: Icons.check_circle_outline_rounded,
                ),
                _InventoryTile(
                  label: 'Bajo stock',
                  value: '${summary.lowStockCount}',
                  icon: Icons.warning_amber_rounded,
                  accentColor: lowStockAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryTile extends StatefulWidget {
  const _InventoryTile({
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;

  @override
  State<_InventoryTile> createState() => _InventoryTileState();
}

class _InventoryTileState extends State<_InventoryTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        widget.accentColor ?? (isDark ? AppTheme.brand : AppTheme.lightBrand);
    final backgroundColor = _isHovered
        ? (isDark ? AppTheme.bg2 : AppTheme.lightBg2)
        : (isDark ? AppTheme.bg1 : AppTheme.lightBg1);
    final borderColor = _isHovered
        ? color
        : (isDark ? AppTheme.border : AppTheme.lightBg4);
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.14)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        width: 220,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, color: color, size: 22),
            const SizedBox(height: 14),
            Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(widget.value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
