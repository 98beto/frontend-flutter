import 'package:flutter/material.dart';
import 'package:pos_desktop/core/notifications/app_notification.dart';
import 'package:pos_desktop/core/theme/app_theme.dart';

class AppNotificationCard extends StatefulWidget {
  const AppNotificationCard({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onDismiss;

  @override
  State<AppNotificationCard> createState() => _AppNotificationCardState();
}

class _AppNotificationCardState extends State<AppNotificationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  bool _didRequestDismiss = false;

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(
            vsync: this,
            duration: widget.notification.duration,
            value: 1,
          )
          ..addStatusListener(_handleAnimationStatus)
          ..reverse();
  }

  @override
  void dispose() {
    _progressController.removeStatusListener(_handleAnimationStatus);
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColorFor(widget.notification.type);
    final icon = _iconFor(widget.notification.type);
    final iconBackground = _iconBackgroundFor(widget.notification.type);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.bg1 : AppTheme.lightBg0;
    final borderColor = isDark ? AppTheme.border : AppTheme.lightBg4;
    final shadowColor = isDark
        ? AppTheme.black.withValues(alpha: 0.35)
        : AppTheme.lightTextStrong.withValues(alpha: 0.12);

    return Material(
      color: AppTheme.transparent,
      child: MouseRegion(
        onEnter: (_) => _progressController.stop(canceled: false),
        onExit: (_) {
          if (_didRequestDismiss || _progressController.isDismissed) {
            return;
          }

          _progressController.reverse();
        },
        child: Container(
          width: 360,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: accentColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.notification.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (widget.notification.message != null &&
                                widget.notification.message!
                                    .trim()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.notification.message!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.textTheme.bodyMedium?.color,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: IconButton(
                          onPressed: _requestDismiss,
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            foregroundColor: theme.textTheme.bodyMedium?.color,
                            backgroundColor: AppTheme.transparent,
                          ),
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      minHeight: 3,
                      value: _progressController.value,
                      backgroundColor: accentColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        accentColor.withValues(alpha: 0.7),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _requestDismiss();
    }
  }

  void _requestDismiss() {
    if (_didRequestDismiss) {
      return;
    }

    _didRequestDismiss = true;
    widget.onDismiss();
  }

  IconData _iconFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.info:
        return Icons.info_outline_rounded;
      case AppNotificationType.success:
        return Icons.check_circle_outline_rounded;
      case AppNotificationType.warning:
        return Icons.warning_amber_rounded;
      case AppNotificationType.error:
        return Icons.error_outline_rounded;
    }
  }

  Color _accentColorFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.info:
        return AppTheme.brand;
      case AppNotificationType.success:
        return AppTheme.success;
      case AppNotificationType.warning:
        return AppTheme.warning;
      case AppNotificationType.error:
        return AppTheme.danger;
    }
  }

  Color _iconBackgroundFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.info:
        return AppTheme.bgBlue;
      case AppNotificationType.success:
        return AppTheme.bgGreen;
      case AppNotificationType.warning:
        return AppTheme.bgYellow;
      case AppNotificationType.error:
        return AppTheme.bgRed;
    }
  }
}
