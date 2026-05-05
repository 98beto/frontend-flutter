import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/sales/domain/entities/sale_list_item.dart';

class SalesList extends StatelessWidget {
  const SalesList({
    super.key,
    required this.items,
    required this.scrollController,
    required this.isLoadingInitial,
    required this.isLoadingMore,
    required this.errorMessage,
    required this.onRetry,
    required this.onOpenDetail,
  });

  final List<SaleListItem> items;
  final ScrollController scrollController;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final String? errorMessage;
  final Future<void> Function() onRetry;
  final ValueChanged<SaleListItem> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final itemBackground = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final itemBorderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final hoverOverlayColor = isDark
        ? AppTheme.accent.withValues(alpha: 0.05)
        : AppTheme.lightAccent.withValues(alpha: 0.04);
    final iconBackground = isDark
        ? AppTheme.soft.withValues(alpha: 0.3)
        : AppTheme.lightBgBlue.withValues(alpha: 0.62);
    final iconColor = isDark ? AppTheme.brand : AppTheme.lightBrand;
    final successBackground = isDark
        ? AppTheme.success.withValues(alpha: 0.12)
        : AppTheme.lightBgGreen;
    final successColor = isDark ? AppTheme.success : AppTheme.lightSuccess;
    final trailingColor = textTheme.bodyMedium?.color ?? AppTheme.muted;

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
          'No se encontraron ventas con los filtros actuales.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = items[index];

               return TweenAnimationBuilder<double>(
                 tween: Tween(begin: 0, end: 0),
                 duration: const Duration(milliseconds: 160),
                 builder: (context, _, child) {
                   return Material(
                      color: AppTheme.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        hoverColor: AppTheme.transparent,
                        overlayColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.hovered)
                              ? hoverOverlayColor
                              : null,
                        ),
                        onTap: () => onOpenDetail(item),
                        child: Ink(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: itemBackground,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: itemBorderColor),
                          ),
                   child: Row(
                     children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: iconBackground,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Venta #${item.id}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.customerName ?? 'Publico general',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _formatDateTime(item.saleDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _paymentMethodLabel(item.paymentMethod),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: successBackground,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Completed',
                              style: TextStyle(
                                color: successColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _currency(item.totalAmount),
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 12),
                       Icon(Icons.chevron_right_rounded, color: trailingColor),
                     ],
                        ),
                      ),
                    ),
                  );
                },
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

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Efectivo';
      case 'card':
        return 'Tarjeta';
      case 'transfer':
        return 'Transferencia';
      default:
        return method;
    }
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }

  String _currency(double value) => '\$${value.toStringAsFixed(2)}';
}
