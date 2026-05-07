import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/cash_register/domain/entities/cash_movement.dart';
import 'package:pos_desktop/features/cash_register/presentation/providers/cash_session_movements_provider.dart';

class CashSessionMovementsPanel extends ConsumerWidget {
  const CashSessionMovementsPanel({
    super.key,
    required this.sessionId,
    this.title = 'Movimientos de caja',
    this.subtitle = 'Historial de entradas y salidas de la sesion actual.',
    this.showHeader = true,
    this.showSummary = true,
  });

  final int sessionId;
  final String title;
  final String subtitle;
  final bool showHeader;
  final bool showSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cashSessionMovementsProvider(sessionId));
    final notifier = ref.read(cashSessionMovementsProvider(sessionId).notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalIn = state.items
        .where((movement) => movement.type == 'in')
        .fold<double>(0, (sum, movement) => sum + movement.amount);
    final totalOut = state.items
        .where((movement) => movement.type == 'out')
        .fold<double>(0, (sum, movement) => sum + movement.amount);
    final expectedBalance = totalIn - totalOut;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 18),
            ],
            if (showSummary) ...[
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _SummaryChip(
                    label: 'Entradas',
                    value: _currency(totalIn),
                    background: isDark
                        ? AppTheme.bgGreen
                        : AppTheme.lightBgGreen,
                    foreground: isDark
                        ? AppTheme.success
                        : AppTheme.lightSuccess,
                  ),
                  _SummaryChip(
                    label: 'Salidas',
                    value: _currency(totalOut),
                    background: isDark ? AppTheme.bgRed : AppTheme.lightBgRed,
                    foreground: isDark ? AppTheme.danger : AppTheme.lightDanger,
                  ),
                  _SummaryChip(
                    label: 'Balance esperado',
                    value: _currency(expectedBalance),
                    background: isDark ? AppTheme.bgBlue : AppTheme.lightBgBlue,
                    foreground: isDark ? AppTheme.accent : AppTheme.lightAccent,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            Wrap(
              spacing: 14,
              runSpacing: 14,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String?>(
                    initialValue: state.type,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todos'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'in',
                        child: Text('Entradas'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'out',
                        child: Text('Salidas'),
                      ),
                    ],
                    onChanged: (value) {
                      notifier.setType(value);
                    },
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String?>(
                    initialValue: state.category,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'sale',
                        child: Text('Venta'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'withdrawal',
                        child: Text('Retiro'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'expense',
                        child: Text('Gasto'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'change',
                        child: Text('Cambio'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'refund',
                        child: Text('Reembolso'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'adjustment',
                        child: Text('Ajuste'),
                      ),
                    ],
                    onChanged: (value) {
                      notifier.setCategory(value);
                    },
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String?>(
                    initialValue: state.source,
                    decoration: const InputDecoration(labelText: 'Origen'),
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todos'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'manual',
                        child: Text('Manual'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'sale',
                        child: Text('Venta'),
                      ),
                    ],
                    onChanged: (value) {
                      notifier.setSource(value);
                    },
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: notifier.clearFilters,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Limpiar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoadingInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.errorMessage != null && state.items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.errorMessage!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: notifier.loadInitial,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          state.type != null ||
                                  state.category != null ||
                                  state.source != null
                              ? 'No hay movimientos que coincidan con los filtros actuales.'
                              : 'Aun no hay movimientos registrados en esta sesion.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: state.items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              _MovementRow(item: state.items[index]),
                        ),
                      ),
                      if (state.isLoadingMore) ...[
                        const SizedBox(height: 16),
                        const Center(child: CircularProgressIndicator()),
                      ],
                      if (state.hasMore && !state.isLoadingMore) ...[
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: notifier.loadNextPage,
                            icon: const Icon(Icons.expand_more_rounded),
                            label: const Text('Cargar mas'),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _currency(double value) => '\$${value.toStringAsFixed(2)}';
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
  });

  final String label;
  final String value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: foreground),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class _MovementRow extends StatefulWidget {
  const _MovementRow({required this.item});

  final CashMovement item;

  @override
  State<_MovementRow> createState() => _MovementRowState();
}

class _MovementRowState extends State<_MovementRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.item.type == 'in'
        ? (isDark ? AppTheme.success : AppTheme.lightSuccess)
        : (isDark ? AppTheme.danger : AppTheme.lightDanger);
    final accentBackground = widget.item.type == 'in'
        ? (isDark ? AppTheme.bgGreen : AppTheme.lightBgGreen)
        : (isDark ? AppTheme.bgRed : AppTheme.lightBgRed);
    final rowBackground = _isHovered
        ? (isDark ? AppTheme.bg2 : AppTheme.lightBg2)
        : (isDark ? AppTheme.bg1 : AppTheme.lightBg1);
    final borderColor = _isHovered
        ? accent
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
        padding: const EdgeInsets.all(18),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: accentBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                widget.item.type == 'in' ? 'Entrada' : 'Salida',
                style: TextStyle(color: accent, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _categoryLabel(widget.item.category),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.notes?.trim().isNotEmpty == true
                        ? widget.item.notes!
                        : 'Sin notas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatDateTime(widget.item.createdAt)}  |  ${_sourceLabel(widget.item)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _currency(widget.item.amount),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: accent),
                ),
                if (widget.item.referenceId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '#${widget.item.referenceId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _currency(double value) => '\$${value.toStringAsFixed(2)}';

  String _categoryLabel(String category) {
    switch (category) {
      case 'sale':
        return 'Venta';
      case 'withdrawal':
        return 'Retiro';
      case 'expense':
        return 'Gasto';
      case 'change':
        return 'Cambio';
      case 'refund':
        return 'Reembolso';
      case 'adjustment':
        return 'Ajuste';
      default:
        return category;
    }
  }

  String _sourceLabel(CashMovement movement) {
    if (movement.source == 'sale' && movement.referenceId != null) {
      return 'Venta #${movement.referenceId}';
    }
    return movement.source == 'sale' ? 'Venta' : 'Manual';
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }
}
