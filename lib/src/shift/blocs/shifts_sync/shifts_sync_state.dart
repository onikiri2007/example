import 'package:meta/meta.dart';

@immutable
abstract class ShiftsSyncState {}

class InitialShiftsSyncState extends ShiftsSyncState {}

class ShiftsSyncing extends ShiftsSyncState {
  @override
  String toString() => 'ShiftsSyncing';
}

class ShiftsSynced extends ShiftsSyncState {
  @override
  String toString() => 'ShiftsSynced';
}
