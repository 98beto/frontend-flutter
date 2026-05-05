import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/dashboard/domain/entities/dashboard_summary.dart';

class DashboardCashPanel extends StatelessWidget {
  const DashboardCashPanel({
    super.key,
    required this.summary,
    required this.onOpenCashRegister,
  });

  final DashboardSummary summary;
  final VoidCallback onOpenCashRegister;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBackground = summary.hasOpenCashSession
        ? (isDark ? AppTheme.bgGreen : AppTheme.lightBgGreen)
        : (isDark ? AppTheme.bgRed : AppTheme.lightBgRed);
    final statusColor = summary.hasOpenCashSession
        ? (isDark ? AppTheme.success : AppTheme.lightSuccess)
        : (isDark ? AppTheme.danger : AppTheme.lightDanger);

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
                    'Estado de caja',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusBackground,
                       borderRadius: BorderRadius.circular(16),
                     ),
                     child: Text(
                       summary.hasOpenCashSession ? 'Caja abierta' : 'Caja cerrada',
                       style: TextStyle(
                         color: statusColor,
                       fontWeight: FontWeight.w700,
                     ),
                   ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (summary.hasOpenCashSession) ...[
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _DataTile(label: 'Sesion', value: '#${summary.cashSessionId}'),
                  _DataTile(
                    label: 'Apertura',
                    value: '\$${(summary.cashSessionOpeningBalance ?? 0).toStringAsFixed(2)}',
                  ),
                  _DataTile(
                    label: 'Hora',
                    value: _formatTime(summary.cashSessionOpenedAt),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'No hay una sesion de caja abierta. Abre una nueva caja para habilitar el cobro en POS.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onOpenCashRegister,
              icon: const Icon(Icons.account_balance_wallet_rounded),
              label: Text(summary.hasOpenCashSession ? 'Ir a Caja' : 'Abrir caja'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? value) {
    if (value == null) {
      return '--:--';
    }

    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _DataTile extends StatefulWidget {
  const _DataTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  State<_DataTile> createState() => _DataTileState();
}

class _DataTileState extends State<_DataTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = _isHovered
        ? (isDark ? AppTheme.bg2 : AppTheme.lightBg2)
        : (isDark ? AppTheme.bg1 : AppTheme.lightBg1);
    final borderColor = _isHovered
        ? (isDark ? AppTheme.accent : AppTheme.lightAccent)
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
        width: 170,
        padding: const EdgeInsets.all(16),
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
            Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(widget.value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
