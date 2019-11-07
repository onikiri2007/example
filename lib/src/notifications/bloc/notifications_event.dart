import 'package:meta/meta.dart';

@immutable
abstract class NotificationsEvent {}

class FetchNotifications extends NotificationsEvent {
  @override
  String toString() => 'FetchNotifications';
}

class NotificationViewed extends NotificationsEvent {
  final int id;

  NotificationViewed(this.id);

  @override
  String toString() => 'NotificationViewed';
}
