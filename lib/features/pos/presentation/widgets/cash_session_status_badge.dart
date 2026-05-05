import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/pos/presentation/providers/cash_session_provider.dart';

class CashSessionStatusBadge extends ConsumerWidget {
  const CashSessionStatusBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashSessionAsync = ref.watch(cashSessionProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;

    final icon = cashSessionAsync.when<IconData>(
      data: (session) => session == null
          ? Icons.lock_outline_rounded
          : Icons.point_of_sale_rounded,
      loading: () => Icons.sync_rounded,
      error: (error, stackTrace) => Icons.error_outline_rounded,
    );

    final label = cashSessionAsync.when(
      data: (session) {
        if (session == null) {
          return 'Caja cerrada';
        }

        return 'Caja abierta #${session.id}';
      },
      loading: () => 'Consultando caja...',
      error: (error, stackTrace) => 'Estado de caja no disponible',
    );

    final badgeColor = cashSessionAsync.when<Color>(
      data: (session) => session == null
          ? (isDark ? AppTheme.danger : AppTheme.lightDanger)
          : (isDark ? AppTheme.success : AppTheme.lightSuccess),
      loading: () => isDark ? AppTheme.brand : AppTheme.lightBrand,
      error: (error, stackTrace) => isDark ? AppTheme.danger : AppTheme.lightDanger,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: badgeColor),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
