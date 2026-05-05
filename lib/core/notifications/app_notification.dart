enum AppNotificationType { info, success, warning, error }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.type,
    required this.duration,
    this.message,
  });

  final String id;
  final String title;
  final String? message;
  final AppNotificationType type;
  final Duration duration;
}
