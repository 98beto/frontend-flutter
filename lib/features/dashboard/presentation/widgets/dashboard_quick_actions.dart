import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({
    super.key,
    required this.hasOpenCashSession,
    required this.lowStockCount,
    required this.onOpenPos,
    required this.onOpenCashRegister,
    required this.onOpenSales,
    required this.onOpenInventory,
  });

  final bool hasOpenCashSession;
  final int lowStockCount;
  final VoidCallback onOpenPos;
  final VoidCallback onOpenCashRegister;
  final VoidCallback onOpenSales;
  final VoidCallback onOpenInventory;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actions = <_QuickActionData>[
      _QuickActionData(
        id: 'pos',
        icon: Icons.point_of_sale_rounded,
        title: 'POS',
        subtitle: 'Cobrar y gestionar carrito',
        onTap: onOpenPos,
      ),
      _QuickActionData(
        id: 'cash',
        icon: Icons.account_balance_wallet_rounded,
        title: 'Caja',
        subtitle: 'Abrir o cerrar sesion',
        onTap: onOpenCashRegister,
      ),
      _QuickActionData(
        id: 'sales',
        icon: Icons.receipt_long_rounded,
        title: 'Ventas',
        subtitle: 'Consultar operaciones registradas',
        onTap: onOpenSales,
      ),
      _QuickActionData(
        id: 'inventory',
        icon: Icons.warehouse_rounded,
        title: 'Inventario',
        subtitle: 'Revisar existencias y alertas',
        onTap: onOpenInventory,
      ),
    ];

    final primaryAction = !hasOpenCashSession
        ? _QuickActionData(
            id: 'cash',
            icon: Icons.account_balance_wallet_rounded,
            title: 'Abrir caja',
            subtitle: 'Necesaria para habilitar el cobro en POS y comenzar a operar.',
            onTap: onOpenCashRegister,
            badge: 'Accion prioritaria',
            accentColor: isDark ? AppTheme.danger : AppTheme.lightDanger,
          )
        : lowStockCount > 0
        ? _QuickActionData(
            id: 'inventory',
            icon: Icons.warning_amber_rounded,
            title: 'Revisar inventario',
            subtitle: 'Hay $lowStockCount productos con alerta de stock por atender.',
            onTap: onOpenInventory,
            badge: 'Atencion requerida',
            accentColor: isDark ? AppTheme.danger : AppTheme.lightDanger,
          )
        : _QuickActionData(
            id: 'pos',
            icon: Icons.point_of_sale_rounded,
            title: 'Ir a POS',
            subtitle: 'Continua cobrando y gestionando el carrito activo del mostrador.',
            onTap: onOpenPos,
            badge: 'Siguiente paso',
          );

    final secondaryActions = actions
        .where((action) => action.id != primaryAction.id)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones operativas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'El dashboard destaca la siguiente accion segun el estado actual del negocio.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            _PrimaryQuickActionCard(action: primaryAction),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: secondaryActions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final action = secondaryActions[index];
                return _QuickActionRow(
                  icon: action.icon,
                  title: action.title,
                  subtitle: action.subtitle,
                  onTap: action.onTap,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryQuickActionCard extends StatefulWidget {
  const _PrimaryQuickActionCard({required this.action});

  final _QuickActionData action;

  @override
  State<_PrimaryQuickActionCard> createState() => _PrimaryQuickActionCardState();
}

class _PrimaryQuickActionCardState extends State<_PrimaryQuickActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final color = widget.action.accentColor ?? (isDark ? AppTheme.brand : AppTheme.lightBrand);
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.18)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);
    final iconCardColor = _isHovered
        ? (isDark ? AppTheme.bg2 : AppTheme.lightBg2)
        : (isDark ? AppTheme.bg1 : AppTheme.lightBg1);
    final subtitleColor = textTheme.bodySmall?.color ?? AppTheme.grey;

    return Material(
      color: AppTheme.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: widget.action.onTap,
        onHover: (value) => setState(() => _isHovered = value),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: _isHovered ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: _isHovered ? 0.45 : 0.2)),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: _isHovered ? 0.2 : 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  widget.action.badge ?? 'Accion destacada',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: iconCardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: color.withValues(alpha: _isHovered ? 0.36 : 0.18)),
                    ),
                    child: Icon(widget.action.icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.action.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.action.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.accentColor,
  });

  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;
  final Color? accentColor;
}

class _QuickActionRow extends StatefulWidget {
  const _QuickActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_QuickActionRow> createState() => _QuickActionRowState();
}

class _QuickActionRowState extends State<_QuickActionRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = _isHovered
        ? (isDark ? AppTheme.bg2 : AppTheme.lightBg2)
        : (isDark ? AppTheme.bg1 : AppTheme.lightBg1);
    final borderColor = _isHovered
        ? (isDark ? AppTheme.accent : AppTheme.lightAccent)
        : (isDark ? AppTheme.border : AppTheme.lightBg4);
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.14)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);
    final iconBackground = isDark
        ? AppTheme.soft.withValues(alpha: _isHovered ? 0.36 : 0.25)
        : AppTheme.lightBgBlue.withValues(alpha: _isHovered ? 0.78 : 0.62);
    final iconColor = isDark ? AppTheme.filledBlue : AppTheme.lightBrand;
    final trailingColor = textTheme.bodyMedium?.color ?? AppTheme.muted;

    return Material(
      color: AppTheme.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: widget.onTap,
        onHover: (value) => setState(() => _isHovered = value),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(widget.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: trailingColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
