import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/notifications/widgets/app_notification_overlay.dart';
import 'package:pos_desktop/core/widgets/app_section_provider.dart';
import 'package:pos_desktop/core/widgets/app_sidebar.dart';
import 'package:pos_desktop/features/cash_register/presentation/pages/cash_register_page.dart';
import 'package:pos_desktop/features/clients/presentation/pages/clients_page.dart';
import 'package:pos_desktop/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:pos_desktop/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/inventory_movements_provider.dart';
import 'package:pos_desktop/features/inventory/presentation/providers/low_stock_products_provider.dart';
import 'package:pos_desktop/features/inventory/presentation/pages/inventory_page.dart';
import 'package:pos_desktop/features/pos/presentation/pages/pos_page.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/cash_session_status_badge.dart';
import 'package:pos_desktop/features/products/presentation/pages/products_page.dart';
import 'package:pos_desktop/features/sales/presentation/pages/sales_page.dart';
import 'package:pos_desktop/features/settings/presentation/pages/settings_page.dart';
import 'package:pos_desktop/features/suppliers/presentation/pages/suppliers_page.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final currentSection = ref.watch(appSectionProvider);
    final view = _resolveView(currentSection);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              AppSidebar(
                currentSection: currentSection,
                isCollapsed: _isSidebarCollapsed,
                onToggleCollapsed: () {
                  setState(() {
                    _isSidebarCollapsed = !_isSidebarCollapsed;
                  });
                },
                onSectionSelected: (section) {
                  if (section == AppSection.dashboard) {
                    ref.invalidate(dashboardProvider);
                  }
                  if (section == AppSection.inventory) {
                    ref.invalidate(inventoryMovementsProvider);
                    ref.invalidate(lowStockProductsProvider);
                  }
                  ref.read(appSectionProvider.notifier).state = section;
                },
              ),
              Expanded(
                child: Container(
                  color: colorScheme.surface,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 22, 28, 0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 760) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    view.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    view.subtitle,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  const CashSessionStatusBadge(),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        view.title,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        view.subtitle,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const CashSessionStatusBadge(),
                              ],
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: view.child,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const AppNotificationOverlay(),
        ],
      ),
    );
  }

  _ShellView _resolveView(AppSection section) {
    switch (section) {
      case AppSection.dashboard:
        return const _ShellView(
          title: 'Dashboard',
          subtitle: 'Vista general de la operacion y accesos rapidos.',
          child: DashboardPage(),
        );
      case AppSection.pos:
        return const _ShellView(
          title: 'Punto de Venta',
          subtitle: 'Gestiona el carrito, productos y el resumen de venta.',
          child: PosPage(),
        );
      case AppSection.sales:
        return const _ShellView(
          title: 'Ventas',
          subtitle:
              'Consulta el historial de ventas y revisa el detalle de cada operacion.',
          child: SalesPage(),
        );
      case AppSection.cashRegister:
        return const _ShellView(
          title: 'Caja',
          subtitle: 'Abre, consulta y cierra la sesion actual de caja.',
          child: CashRegisterPage(),
        );
      case AppSection.products:
        return const _ShellView(
          title: 'Productos',
          subtitle: 'Administra el catalogo y la informacion de los articulos.',
          child: ProductsPage(),
        );
      case AppSection.inventory:
        return const _ShellView(
          title: 'Inventario',
          subtitle: 'Controla existencias, movimientos y alertas.',
          child: InventoryPage(),
        );
      case AppSection.suppliers:
        return const _ShellView(
          title: 'Proveedores',
          subtitle: 'Centraliza contactos y relacion comercial.',
          child: SuppliersPage(),
        );
      case AppSection.clients:
        return const _ShellView(
          title: 'Clientes',
          subtitle: 'Consulta historiales y datos comerciales.',
          child: ClientsPage(),
        );
      case AppSection.settings:
        return const _ShellView(
          title: 'Configuracion',
          subtitle: 'Ajusta parametros generales del sistema.',
          child: SettingsPage(),
        );
    }
  }
}

class _ShellView {
  const _ShellView({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;
}
