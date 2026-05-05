import 'package:flutter/material.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class DashboardMetricCard extends StatefulWidget {
  const DashboardMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    this.accentColor,
    this.valueFontSize = 60,
  });

  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color? accentColor;
  final double valueFontSize;

  @override
  State<DashboardMetricCard> createState() => _DashboardMetricCardState();
}

class _DashboardMetricCardState extends State<DashboardMetricCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final color = widget.accentColor ?? (isDark ? AppTheme.brand : AppTheme.lightBrand);
    final backgroundColor = _isHovered
        ? (isDark ? AppTheme.bg1 : AppTheme.lightBg1)
        : (isDark ? AppTheme.panel : AppTheme.lightBg0);
    final borderColor = _isHovered ? color : (isDark ? AppTheme.border : AppTheme.lightBg4);
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.18)
        : AppTheme.lightTextStrong.withValues(alpha: 0.08);
    final captionColor = textTheme.bodySmall?.color ?? AppTheme.grey;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 210 || constraints.maxHeight < 120;
            final padding = isCompact ? 12.0 : 16.0;
            final titleFontSize = isCompact ? 14.0 : 15.0;
            final iconBoxSize = isCompact ? 38.0 : 42.0;
            final iconSize = isCompact ? 20.0 : 22.0;
            final valueFontSize = isCompact
                ? widget.valueFontSize.clamp(34.0, 46.0)
                : widget.valueFontSize;
            final titleLines = isCompact ? 1 : 2;
            final captionLines = isCompact ? 1 : 2;
            final topSpacing = isCompact ? 6.0 : 8.0;
            final bottomSpacing = isCompact ? 4.0 : 6.0;
            final captionFontSize = isCompact ? 12.0 : 13.0;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: titleLines,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: isCompact ? 10 : 12),
                      Container(
                        width: iconBoxSize,
                        height: iconBoxSize,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: _isHovered ? 0.18 : 0.12),
                          borderRadius: BorderRadius.circular(isCompact ? 14 : 16),
                        ),
                        child: Icon(widget.icon, color: color, size: iconSize),
                      ),
                    ],
                  ),
                  SizedBox(height: topSpacing),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.value,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineLarge?.copyWith(
                              fontSize: valueFontSize,
                              fontWeight: FontWeight.w800,
                              height: 1,
                              letterSpacing: -1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: bottomSpacing),
                  Text(
                    widget.caption,
                    maxLines: captionLines,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: captionFontSize,
                      color: captionColor,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
