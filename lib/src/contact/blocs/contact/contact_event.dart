import 'package:meta/meta.dart';

@immutable
abstract class ContactEvent {}

class FetchContactDetails extends ContactEvent {
  final int id;

  FetchContactDetails(this.id);

  @override
  String toString() => 'FetchUserDetails';
}
