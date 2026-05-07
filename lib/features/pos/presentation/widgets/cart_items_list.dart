import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';
import 'package:pos_desktop/features/pos/domain/entities/cart_item.dart';
import 'package:pos_desktop/features/pos/presentation/widgets/quantity_picker_dialog.dart';

class CartItemsList extends StatelessWidget {
  const CartItemsList({
    super.key,
    required this.items,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onSetQuantity,
    required this.onQuantityLimitReached,
  });

  final List<CartItem> items;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;
  final ValueChanged<String> onRemove;
  final void Function(String productId, int quantity) onSetQuantity;
  final ValueChanged<CartItem> onQuantityLimitReached;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emptyIconBackground = isDark
        ? AppTheme.soft.withValues(alpha: 0.35)
        : AppTheme.lightBgBlue.withValues(alpha: 0.62);
    final emptyIconColor = isDark ? AppTheme.brand : AppTheme.lightBrand;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: emptyIconBackground,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.remove_shopping_cart_rounded,
                color: emptyIconColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay productos en el carrito',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Usa el buscador para abrir la modal y agregar productos.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = items[index];

        return _CartItemRow(
          item: item,
          currencyLabel: _currency(item.lineTotal),
          onIncrement: () {
            if (item.quantity >= item.product.stock) {
              onQuantityLimitReached(item);
              return;
            }

            onIncrement(item.product.id);
          },
          onDecrement: () => onDecrement(item.product.id),
          onRemove: () => onRemove(item.product.id),
          onEditQuantity: () async {
            final quantity = await showDialog<int>(
              context: context,
              builder: (_) => QuantityPickerDialog(
                title: 'Editar cantidad',
                subtitle: item.product.name,
                confirmLabel: 'Actualizar',
                initialQuantity: item.quantity,
                maxQuantity: item.product.stock,
              ),
            );

            if (quantity == null) {
              return;
            }

            if (quantity > item.product.stock) {
              onQuantityLimitReached(item);
              return;
            }

            onSetQuantity(item.product.id, quantity);
          },
        );
      },
    );
  }

  String _currency(double value) => '\$${value.toStringAsFixed(2)}';
}

class _CartItemRow extends StatefulWidget {
  const _CartItemRow({
    required this.item,
    required this.currencyLabel,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onEditQuantity,
  });

  final CartItem item;
  final String currencyLabel;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final Future<void> Function() onEditQuantity;

  @override
  State<_CartItemRow> createState() => _CartItemRowState();
}

class _CartItemRowState extends State<_CartItemRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandColor = isDark ? AppTheme.brand : AppTheme.lightBrand;
    final accentColor = isDark ? AppTheme.accent : AppTheme.lightAccent;
    final dangerColor = isDark ? AppTheme.danger : AppTheme.lightDanger;
    final rowBackground = _isHovered
        ? (isDark ? AppTheme.bg2 : AppTheme.lightBg2)
        : (isDark ? AppTheme.bg1 : AppTheme.lightBg1);
    final rowBorder = _isHovered
        ? accentColor
        : (isDark ? AppTheme.border : AppTheme.lightBg4);
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.14)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);
    final iconBackground = isDark
        ? AppTheme.soft.withValues(alpha: 0.35)
        : AppTheme.lightBgBlue.withValues(alpha: 0.62);
    final qtyPanelBackground = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final qtyValueBackground = isDark
        ? AppTheme.soft.withValues(alpha: 0.2)
        : AppTheme.lightBgBlue.withValues(alpha: 0.48);
    final qtyValueTextColor = isDark ? AppTheme.fg : AppTheme.lightTextStrong;

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
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: rowBorder),
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.inventory_2_rounded, color: brandColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.product.category}  |  ${item.product.sku}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Disponible: ${item.product.stock}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.currencyLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: qtyPanelBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _isHovered
                          ? accentColor.withValues(alpha: 0.35)
                          : (isDark ? AppTheme.border : AppTheme.lightBg4),
                    ),
                  ),
                  child: Row(
                    children: [
                      _QtyButton(
                        icon: Icons.remove_rounded,
                        onTap: widget.onDecrement,
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: widget.onEditQuantity,
                        child: Ink(
                          width: 58,
                          height: 38,
                          decoration: BoxDecoration(
                            color: qtyValueBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.border
                                  : AppTheme.lightBg4,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                color: qtyValueTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _QtyButton(
                        icon: Icons.add_rounded,
                        onTap: widget.onIncrement,
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: widget.onRemove,
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: dangerColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatefulWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_QtyButton> createState() => _QtyButtonState();
}

class _QtyButtonState extends State<_QtyButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppTheme.accent : AppTheme.lightAccent;
    final iconColor = isDark ? AppTheme.fg : AppTheme.lightTextStrong;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _isHovered
                ? (isDark ? AppTheme.bg3 : AppTheme.lightBg3)
                : (isDark ? AppTheme.bg2 : AppTheme.lightBg2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? accentColor.withValues(alpha: 0.4)
                  : (isDark ? AppTheme.border : AppTheme.lightBg4),
            ),
          ),
          child: Icon(widget.icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}
