import 'package:meta/meta.dart';

@immutable
abstract class CompanyEvent {}

class Fetch extends CompanyEvent {
  @override
  String toString() => 'Fetch';
}

class SyncCompany extends CompanyEvent {
  @override
  String toString() => 'SyncCompany';
}
