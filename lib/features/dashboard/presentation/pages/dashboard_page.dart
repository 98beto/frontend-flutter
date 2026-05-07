import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/widgets/app_section_provider.dart';
import 'package:pos_desktop/core/widgets/app_sidebar.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:pos_desktop/features/dashboard/presentation/widgets/dashboard_cash_panel.dart';
import 'package:pos_desktop/features/dashboard/presentation/widgets/dashboard_inventory_panel.dart';
import 'package:pos_desktop/features/dashboard/presentation/widgets/dashboard_metric_card.dart';
import 'package:pos_desktop/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final errorColor = isDark ? AppTheme.danger : AppTheme.lightDanger;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 40,
                      color: errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No fue posible cargar el dashboard.',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Verifica la conexion con la API e intenta nuevamente.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => ref.invalidate(dashboardProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      data: (summary) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final revenueAccent = isDark ? AppTheme.success : AppTheme.lightSuccess;
        final alertAccent = summary.lowStockCount > 0
            ? (isDark ? AppTheme.danger : AppTheme.lightDanger)
            : (isDark ? AppTheme.success : AppTheme.lightSuccess);

        return SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final metricsCrossAxisCount = maxWidth >= 1200
                  ? 4
                  : maxWidth >= 760
                  ? 2
                  : 1;
              final metricsAspectRatio = maxWidth >= 1200
                  ? 1.4
                  : maxWidth >= 760
                  ? 1.7
                  : 2.8;
              final useStackedPanels = maxWidth < 1120;

              final metrics = GridView.count(
                crossAxisCount: metricsCrossAxisCount,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: metricsAspectRatio,
                children: [
                  DashboardMetricCard(
                    title: 'Ventas de hoy',
                    value: '${summary.todaySalesCount}',
                    caption: 'Operaciones completadas hoy',
                    icon: Icons.receipt_long_rounded,
                    valueFontSize: 60,
                  ),
                  DashboardMetricCard(
                    title: 'Ingresos de hoy',
                    value: '\$${summary.todayRevenue.toStringAsFixed(2)}',
                    caption: 'Ingresos acumulados del dia',
                    icon: Icons.payments_rounded,
                    accentColor: revenueAccent,
                    valueFontSize: 50,
                  ),
                  DashboardMetricCard(
                    title: 'Articulos vendidos',
                    value: '${summary.todayItemsSold}',
                    caption: 'Unidades desplazadas hoy',
                    icon: Icons.inventory_2_rounded,
                    valueFontSize: 60,
                  ),
                  DashboardMetricCard(
                    title: 'Alertas de inventario',
                    value: '${summary.lowStockCount}',
                    caption: summary.lowStockCount > 0
                        ? 'Productos por debajo del minimo'
                        : 'Sin alertas activas en inventario',
                    icon: Icons.warning_amber_rounded,
                    accentColor: alertAccent,
                    valueFontSize: 60,
                  ),
                ],
              );

              final panelsColumn = Column(
                children: [
                  DashboardCashPanel(
                    summary: summary,
                    onOpenCashRegister: () {
                      ref.read(appSectionProvider.notifier).state =
                          AppSection.cashRegister;
                    },
                  ),
                  const SizedBox(height: 20),
                  DashboardInventoryPanel(summary: summary),
                ],
              );

              final quickActions = DashboardQuickActions(
                hasOpenCashSession: summary.hasOpenCashSession,
                lowStockCount: summary.lowStockCount,
                onOpenPos: () {
                  ref.read(appSectionProvider.notifier).state = AppSection.pos;
                },
                onOpenCashRegister: () {
                  ref.read(appSectionProvider.notifier).state =
                      AppSection.cashRegister;
                },
                onOpenSales: () {
                  ref.read(appSectionProvider.notifier).state =
                      AppSection.sales;
                },
                onOpenInventory: () {
                  ref.read(appSectionProvider.notifier).state =
                      AppSection.inventory;
                },
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  metrics,
                  const SizedBox(height: 20),
                  if (!useStackedPanels)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: panelsColumn),
                        const SizedBox(width: 20),
                        Expanded(flex: 4, child: quickActions),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        panelsColumn,
                        const SizedBox(height: 20),
                        quickActions,
                      ],
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
