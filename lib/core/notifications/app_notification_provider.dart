import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_desktop/core/notifications/app_notification.dart';

final appNotificationProvider =
    NotifierProvider<AppNotificationNotifier, List<AppNotification>>(
      AppNotificationNotifier.new,
    );

class AppNotificationNotifier extends Notifier<List<AppNotification>> {
  static const _maxNotifications = 3;

  @override
  List<AppNotification> build() => const [];

  void showInfo({required String title, String? message, Duration? duration}) {
    _show(
      title: title,
      message: message,
      type: AppNotificationType.info,
      duration: duration,
    );
  }

  void showSuccess({
    required String title,
    String? message,
    Duration? duration,
  }) {
    _show(
      title: title,
      message: message,
      type: AppNotificationType.success,
      duration: duration,
    );
  }

  void showWarning({
    required String title,
    String? message,
    Duration? duration,
  }) {
    _show(
      title: title,
      message: message,
      type: AppNotificationType.warning,
      duration: duration,
    );
  }

  void showError({required String title, String? message, Duration? duration}) {
    _show(
      title: title,
      message: message,
      type: AppNotificationType.error,
      duration: duration,
    );
  }

  void dismiss(String id) {
    state = state.where((notification) => notification.id != id).toList();
  }

  void clear() {
    state = const [];
  }

  void _show({
    required String title,
    String? message,
    required AppNotificationType type,
    Duration? duration,
  }) {
    final notification = AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      duration: duration ?? _defaultDurationFor(type),
    );

    final next = [notification, ...state];
    state = next.length > _maxNotifications
        ? next.take(_maxNotifications).toList()
        : next;
  }

  Duration _defaultDurationFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.info:
      case AppNotificationType.success:
        return const Duration(seconds: 3);
      case AppNotificationType.warning:
      case AppNotificationType.error:
        return const Duration(seconds: 4);
    }
  }
}
