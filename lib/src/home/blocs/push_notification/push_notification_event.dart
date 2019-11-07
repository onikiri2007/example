import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class PushNotificationEvent {}

class InitializeNotification extends PushNotificationEvent {
  @override
  String toString() => 'Initialize';
}

class RegisterPushToken extends PushNotificationEvent {
  final String token;
  RegisterPushToken(this.token);

  @override
  String toString() => 'RegisterPushToken';
}

class ShiftMessageRecieved extends PushNotificationEvent {
  final Shift shift;

  ShiftMessageRecieved(this.shift);

  @override
  String toString() => 'ShiftNotificationRecieved';
}
