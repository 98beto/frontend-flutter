import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/auth/presentation/providers/auth_session_provider.dart';

enum AppSection {
  dashboard,
  pos,
  sales,
  cashRegister,
  products,
  inventory,
  suppliers,
  clients,
  settings,
}

class AppSidebar extends ConsumerWidget {
  const AppSidebar({
    super.key,
    required this.currentSection,
    required this.onSectionSelected,
    required this.isCollapsed,
    required this.onToggleCollapsed,
  });

  final AppSection currentSection;
  final ValueChanged<AppSection> onSectionSelected;
  final bool isCollapsed;
  final VoidCallback onToggleCollapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(authSessionProvider);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final sidebarColor = isDark ? AppTheme.bg0 : AppTheme.lightBg0;
    final panelColor = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final buttonBgColor = isDark ? AppTheme.bg2 : AppTheme.lightBg2;
    final userAvatarBgColor = isDark ? AppTheme.bg3 : AppTheme.lightBg3;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final titleColor = colorScheme.onSurface;
    final subtitleColor = textTheme.bodyMedium?.color ?? AppTheme.grey;
    final menuLabelColor = textTheme.bodySmall?.color ?? AppTheme.grey;
    final selectedBackgroundColor = isDark
        ? AppTheme.bgPurple
        : AppTheme.lightBgPurple;
    final selectedBorderColor = isDark ? AppTheme.purple : AppTheme.lightBrand;
    final selectedIconColor = isDark
        ? AppTheme.filledBlue
        : AppTheme.lightBrand;
    final selectedTextColor = colorScheme.onSurface;
    final unselectedIconColor = subtitleColor;
    final unselectedTextColor = subtitleColor;
    final brandAvatarColor = isDark ? AppTheme.accent : AppTheme.lightAccent;
    final brandAvatarIconColor = isDark ? AppTheme.black : AppTheme.lightBase00;
    final sidebarPrimaryLabel = session?.deviceName.trim().isNotEmpty == true
        ? session!.deviceName.trim()
        : 'Sin sesion';
    final sidebarSecondaryLabel = session?.branchName.trim().isNotEmpty == true
        ? session!.branchName.trim()
        : 'Sin sesion autenticada';

    final sidebarWidth = isCollapsed ? 96.0 : 292.0;
    final items = [
      _SidebarItem(AppSection.dashboard, Icons.dashboard_rounded, 'Dashboard'),
      _SidebarItem(AppSection.pos, Icons.point_of_sale_rounded, 'POS'),
      _SidebarItem(AppSection.sales, Icons.receipt_long_rounded, 'Ventas'),
      _SidebarItem(
        AppSection.cashRegister,
        Icons.account_balance_wallet_rounded,
        'Caja',
      ),
      _SidebarItem(AppSection.products, Icons.inventory_2_rounded, 'Productos'),
      _SidebarItem(AppSection.inventory, Icons.warehouse_rounded, 'Inventario'),
      _SidebarItem(
        AppSection.suppliers,
        Icons.local_shipping_rounded,
        'Proveedores',
      ),
      _SidebarItem(AppSection.clients, Icons.groups_rounded, 'Clientes'),
      _SidebarItem(
        AppSection.settings,
        Icons.settings_rounded,
        'Configuracion',
      ),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: sidebarWidth,
      color: sidebarColor,
      padding: EdgeInsets.fromLTRB(
        isCollapsed ? 12 : 20,
        24,
        isCollapsed ? 12 : 20,
        20,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showExpandedContent = constraints.maxWidth >= 220;
          final brandAvatarRadius = showExpandedContent ? 24.0 : 20.0;
          final userAvatarRadius = showExpandedContent ? 20.0 : 18.0;

          return Column(
            crossAxisAlignment: showExpandedContent
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(showExpandedContent ? 18 : 12),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: showExpandedContent
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: brandAvatarRadius,
                          backgroundColor: brandAvatarColor,
                          child: Icon(
                            Icons.store_mall_directory_rounded,
                            color: brandAvatarIconColor,
                            size: showExpandedContent ? 24 : 20,
                          ),
                        ),
                        if (showExpandedContent) ...[
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SISTEMA DE INVENTARIO',
                                  style: TextStyle(
                                    color: titleColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Inventario y ventas',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: showExpandedContent
                    ? Alignment.centerRight
                    : Alignment.center,
                child: IconButton(
                  onPressed: onToggleCollapsed,
                  style: IconButton.styleFrom(
                    backgroundColor: buttonBgColor,
                    foregroundColor: titleColor,
                    side: BorderSide(color: borderColor),
                  ),
                  icon: Icon(
                    isCollapsed
                        ? Icons.keyboard_double_arrow_right_rounded
                        : Icons.keyboard_double_arrow_left_rounded,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              if (showExpandedContent)
                Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 10),
                  child: Text(
                    'MENU PRINCIPAL',
                    style: TextStyle(
                      color: menuLabelColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selected = item.section == currentSection;

                    return Material(
                      color: AppTheme.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => onSectionSelected(item.section),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(
                            horizontal: showExpandedContent ? 16 : 0,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? selectedBackgroundColor
                                : AppTheme.transparent,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? selectedBorderColor
                                  : AppTheme.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: showExpandedContent
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                            children: [
                              Icon(
                                item.icon,
                                color: selected
                                    ? selectedIconColor
                                    : unselectedIconColor,
                                size: 20,
                              ),
                              if (showExpandedContent) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.label,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: selected
                                          ? selectedTextColor
                                          : unselectedTextColor,
                                      fontSize: 14,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(showExpandedContent ? 16 : 12),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: showExpandedContent
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: userAvatarRadius,
                      backgroundColor: userAvatarBgColor,
                      child: Icon(
                        Icons.person_rounded,
                        color: titleColor,
                        size: showExpandedContent ? 24 : 20,
                      ),
                    ),
                    if (showExpandedContent) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sidebarPrimaryLabel,
                              style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sidebarSecondaryLabel,
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SidebarItem {
  const _SidebarItem(this.section, this.icon, this.label);

  final AppSection section;
  final IconData icon;
  final String label;
}
