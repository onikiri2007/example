import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class NotificationsState {}

class InitialNotificationsState extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<YodelNotification> notifications;

  NotificationsLoaded(this.notifications);

  @override
  String toString() => 'NotificationsLoaded';
}

class NotificationsLoading extends NotificationsState {
  @override
  String toString() => 'Loading';
}

class NotificationsError extends NotificationsState {
  final Exception exception;
  final String error;

  NotificationsError(
    this.error, {
    this.exception,
  });

  @override
  String toString() =>
      'Notifications => error: error, exception: ${exception.toString()}';
}
