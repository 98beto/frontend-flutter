import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/cash_register/domain/entities/cash_session_history_item.dart';
import 'package:pos_desktop/features/cash_register/presentation/widgets/cash_session_movements_panel.dart';

class CashSessionHistoryDetail extends StatelessWidget {
  const CashSessionHistoryDetail({super.key, required this.session});

  final CashSessionHistoryItem? session;

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Selecciona una sesion para ver sus movimientos.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SessionSummaryCard(session: session!),
        const SizedBox(height: 20),
        Expanded(
          child: CashSessionMovementsPanel(
            sessionId: session!.id,
            showHeader: false,
            showSummary: false,
          ),
        ),
      ],
    );
  }
}

class _SessionSummaryCard extends StatelessWidget {
  const _SessionSummaryCard({required this.session});

  final CashSessionHistoryItem session;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBackground = session.isOpen
        ? (isDark ? AppTheme.bgGreen : AppTheme.lightBgGreen)
        : (isDark ? AppTheme.bgBlue : AppTheme.lightBgBlue);
    final statusForeground = session.isOpen
        ? (isDark ? AppTheme.success : AppTheme.lightSuccess)
        : (isDark ? AppTheme.accent : AppTheme.lightAccent);
    final notesBackground = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final notesBorder = isDark ? AppTheme.border : AppTheme.lightBg4;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sesion #${session.id}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        session.isOpen
                            ? 'La sesion sigue abierta y sus movimientos pueden cambiar.'
                            : 'Revision historica de una sesion cerrada.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    session.isOpen ? 'Abierta' : 'Cerrada',
                    style: TextStyle(
                      color: statusForeground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 14,
              children: [
                _SummaryTile(
                  label: 'Apertura',
                  value: _currency(session.openingBalance),
                ),
                _SummaryTile(
                  label: 'Monto cierre',
                  value: session.closingBalance == null
                      ? 'Pendiente'
                      : _currency(session.closingBalance!),
                ),
                _SummaryTile(
                  label: 'Abierta',
                  value: _formatDateTime(session.openedAt),
                ),
                _SummaryTile(
                  label: 'Cerrada',
                  value: session.closedAt == null
                      ? 'Pendiente'
                      : _formatDateTime(session.closedAt!),
                ),
                if ((session.deviceIdentifier ?? '').trim().isNotEmpty)
                  _SummaryTile(
                    label: 'Dispositivo',
                    value: session.deviceIdentifier!.trim(),
                  ),
              ],
            ),
            if ((session.notes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: notesBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: notesBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      session.notes!.trim(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _currency(double value) => '\$${value.toStringAsFixed(2)}';

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }
}

class _SummaryTile extends StatefulWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  State<_SummaryTile> createState() => _SummaryTileState();
}

class _SummaryTileState extends State<_SummaryTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBackground = _isHovered
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
        width: 180,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tileBackground,
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
            Text(widget.label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              widget.value,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
