import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class ShiftsSyncBloc extends Bloc<ShiftsSyncEvent, ShiftsSyncState> {
  @override
  ShiftsSyncState get initialState => InitialShiftsSyncState();

  @override
  Stream<ShiftsSyncState> mapEventToState(
    ShiftsSyncEvent event,
  ) async* {
    if (event is SyncShifts) {
      yield ShiftsSyncing();
    }

    if (event is SyncShiftsCompleted) {
      yield ShiftsSynced();
    }
  }
}
