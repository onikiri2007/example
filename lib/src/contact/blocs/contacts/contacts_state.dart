import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class ContactsState {}

class InitialContactsState extends ContactsState {}

class ContactsSuccess extends ContactsState {
  final List<Contact> contacts;

  ContactsSuccess({
    this.contacts,
  });

  @override
  String toString() => 'ContactsSuccess';
}

class ContactsLoading extends ContactsState {
  @override
  String toString() => 'ContactsLoading';
}

class ContactsError extends ContactsState {
  final Exception exception;
  final String error;

  ContactsError(
    this.error, {
    this.exception,
  });

  @override
  String toString() =>
      'Contacts => error: error, exception: ${exception.toString()}';
}
