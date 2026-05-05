import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class ProductSearchField extends StatelessWidget {
  const ProductSearchField({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppTheme.bg1 : AppTheme.lightBg1;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final mutedColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppTheme.muted;
    final accentColor = isDark ? AppTheme.brand : AppTheme.lightBrand;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: mutedColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Buscar producto por nombre, SKU o categoria',
                style: TextStyle(color: mutedColor, fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.add_circle_outline_rounded, color: accentColor),
          ],
        ),
      ),
    );
  }
}
