import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/dashboard/domain/entities/dashboard_summary.dart';

class InventorySummaryCards extends StatelessWidget {
  const InventorySummaryCards({
    super.key,
    required this.summary,
    required this.onCreateMovement,
  });

  final DashboardSummary summary;
  final VoidCallback onCreateMovement;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
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
                        'Resumen de inventario',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Supervisa el estado del stock y registra movimientos manuales.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onCreateMovement,
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('Registrar movimiento'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _SummaryTile(
                  label: 'Total productos',
                  value: '${summary.totalProducts}',
                  icon: Icons.inventory_2_rounded,
                ),
                _SummaryTile(
                  label: 'Productos activos',
                  value: '${summary.activeProducts}',
                  icon: Icons.check_circle_outline_rounded,
                  accentColor: isDark
                      ? AppTheme.success
                      : AppTheme.lightSuccess,
                ),
                _SummaryTile(
                  label: 'Bajo stock',
                  value: '${summary.lowStockCount}',
                  icon: Icons.warning_amber_rounded,
                  accentColor: summary.lowStockCount > 0
                      ? (isDark ? AppTheme.danger : AppTheme.lightDanger)
                      : (isDark ? AppTheme.success : AppTheme.lightSuccess),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatefulWidget {
  const _SummaryTile({
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
  State<_SummaryTile> createState() => _SummaryTileState();
}

class _SummaryTileState extends State<_SummaryTile> {
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
        width: 250,
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: backgroundColor,
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(widget.icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.value,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
