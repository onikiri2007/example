import 'package:meta/meta.dart';

@immutable
abstract class ContactsEvent {}

class FetchContacts extends ContactsEvent {
  @override
  String toString() => 'FetchContacts';
}
