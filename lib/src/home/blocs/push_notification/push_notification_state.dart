import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class PushNotificationState {}

class InitialPushNotificationState extends PushNotificationState {}

class PushNotificationInitialized extends PushNotificationState {
  @override
  String toString() => 'PushNotificationInitialized';
}

class PushNotificationLoading extends PushNotificationState {
  @override
  String toString() => 'PushNotificationLoading';
}

class PushNotificationError extends PushNotificationState {
  final Exception exception;
  final String error;

  PushNotificationError(
    this.error, {
    this.exception,
  });

  @override
  String toString() =>
      'PushNotification => error: error, exception: ${exception.toString()}';
}

class PushNotificationShiftMessageRecieved extends PushNotificationState {
  final Shift shift;
  final bool myShift;

  PushNotificationShiftMessageRecieved(this.shift, {this.myShift = false});

  @override
  String toString() => 'PushNotificationMessageRecieved';
}
