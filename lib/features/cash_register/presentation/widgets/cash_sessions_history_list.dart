import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/cash_register/domain/entities/cash_session_history_item.dart';

class CashSessionsHistoryList extends StatelessWidget {
  const CashSessionsHistoryList({
    super.key,
    required this.items,
    required this.selectedSessionId,
    required this.isLoadingInitial,
    required this.isLoadingMore,
    required this.errorMessage,
    required this.hasMore,
    required this.onSelectSession,
    required this.onRetry,
    required this.onLoadMore,
  });

  final List<CashSessionHistoryItem> items;
  final int? selectedSessionId;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool hasMore;
  final ValueChanged<int> onSelectSession;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sesiones', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Mas recientes primero.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (isLoadingInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (errorMessage != null && items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: onRetry,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'Aun no hay sesiones registradas.',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _SessionTile(
                              item: item,
                              isSelected: item.id == selectedSessionId,
                              onTap: () => onSelectSession(item.id),
                            );
                          },
                        ),
                      ),
                      if (isLoadingMore) ...[
                        const SizedBox(height: 16),
                        const Center(child: CircularProgressIndicator()),
                      ],
                      if (hasMore && !isLoadingMore) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: onLoadMore,
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
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final CashSessionHistoryItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBackground = item.isOpen
        ? (isDark ? AppTheme.bgGreen : AppTheme.lightBgGreen)
        : (isDark ? AppTheme.bgBlue : AppTheme.lightBgBlue);
    final statusForeground = item.isOpen
        ? (isDark ? AppTheme.success : AppTheme.lightSuccess)
        : (isDark ? AppTheme.accent : AppTheme.lightAccent);
    final selectedBackground = isDark
        ? AppTheme.bgPurple
        : AppTheme.lightBgPurple.withValues(alpha: 0.55);
    final selectedBorder = isDark ? AppTheme.purple : AppTheme.lightBrand;
    final defaultBackground = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final defaultBorder = isDark ? AppTheme.border : AppTheme.lightBg4;

    return Material(
      color: AppTheme.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? selectedBackground : defaultBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? selectedBorder : defaultBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sesion #${item.id}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.isOpen ? 'Abierta' : 'Cerrada',
                      style: TextStyle(
                        color: statusForeground,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _InfoLine(
                label: 'Apertura',
                value: _formatDateTime(item.openedAt),
              ),
              _InfoLine(
                label: 'Cierre',
                value: item.closedAt == null
                    ? 'Pendiente'
                    : _formatDateTime(item.closedAt!),
              ),
              _InfoLine(
                label: 'Monto apertura',
                value: _currency(item.openingBalance),
              ),
              if (item.closingBalance != null)
                _InfoLine(
                  label: 'Monto cierre',
                  value: _currency(item.closingBalance!),
                ),
              if ((item.deviceIdentifier ?? '').trim().isNotEmpty)
                _InfoLine(
                  label: 'Dispositivo',
                  value: item.deviceIdentifier!.trim(),
                ),
            ],
          ),
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

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
