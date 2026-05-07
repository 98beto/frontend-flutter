import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/notifications/app_notification.dart';
import 'package:pos_desktop/core/notifications/app_notification_provider.dart';
import 'package:pos_desktop/core/notifications/widgets/app_notification_card.dart';

class AppNotificationOverlay extends ConsumerStatefulWidget {
  const AppNotificationOverlay({super.key});

  @override
  ConsumerState<AppNotificationOverlay> createState() =>
      _AppNotificationOverlayState();
}

class _AppNotificationOverlayState
    extends ConsumerState<AppNotificationOverlay> {
  static const _animationDuration = Duration(milliseconds: 260);

  final _listKey = GlobalKey<AnimatedListState>();
  late final List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List<AppNotification>.of(
      ref.read(appNotificationProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(appNotificationProvider);

    ref.listen<List<AppNotification>>(appNotificationProvider, (
      previous,
      next,
    ) {
      _syncNotifications(next);
    });

    if (_notifications.isEmpty && notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 20, right: 24),
          child: SizedBox(
            width: 360,
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _notifications.length,
              shrinkWrap: true,
              primary: false,
              itemBuilder: (context, index, animation) {
                final notification = _notifications[index];
                return _buildAnimatedItem(notification, animation);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _syncNotifications(List<AppNotification> next) {
    final nextIds = next.map((notification) => notification.id).toSet();

    for (var index = _notifications.length - 1; index >= 0; index--) {
      final notification = _notifications[index];
      if (nextIds.contains(notification.id)) {
        continue;
      }

      final removed = _notifications.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildAnimatedItem(removed, animation),
        duration: _animationDuration,
      );
    }

    for (var targetIndex = 0; targetIndex < next.length; targetIndex++) {
      final notification = next[targetIndex];
      final currentIndex = _notifications.indexWhere(
        (item) => item.id == notification.id,
      );

      if (currentIndex == -1) {
        _notifications.insert(targetIndex, notification);
        _listKey.currentState?.insertItem(
          targetIndex,
          duration: _animationDuration,
        );
        continue;
      }

      _notifications[currentIndex] = notification;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildAnimatedItem(
    AppNotification notification,
    Animation<double> animation,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.14, -0.12),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: SizeTransition(
          sizeFactor: curvedAnimation,
          axisAlignment: -1,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppNotificationCard(
              key: ValueKey(notification.id),
              notification: notification,
              onDismiss: () => ref
                  .read(appNotificationProvider.notifier)
                  .dismiss(notification.id),
            ),
          ),
        ),
      ),
    );
  }
}
