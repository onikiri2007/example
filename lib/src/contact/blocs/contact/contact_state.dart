import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class ContactState {}

class InitialContactState extends ContactState {}

class ContactLoaded extends ContactState {
  final UserData user;

  ContactLoaded(this.user);

  @override
  String toString() => 'ContactLoaded';
}

class ContactError extends ContactState {
  final Exception exception;
  final String error;

  ContactError(
    this.error, {
    this.exception,
  });

  @override
  String toString() =>
      'Contact => error: error, exception: ${exception.toString()}';
}

class ContactLoading extends ContactState {
  @override
  String toString() => 'ContactLoading';
}
