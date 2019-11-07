import 'package:meta/meta.dart';

@immutable
abstract class ShiftsSyncEvent {}

class SyncShifts extends ShiftsSyncEvent {
  @override
  String toString() => 'SyncShifts';
}

class SyncShiftsCompleted extends ShiftsSyncEvent {
  @override
  String toString() => 'ShiftSyncCompleted';
}
