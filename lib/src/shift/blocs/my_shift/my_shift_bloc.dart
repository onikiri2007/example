import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';
import './bloc.dart';
import 'package:rxdart/rxdart.dart';

class MyShiftBloc extends Bloc<MyShiftEvent, MyShiftState> {
  final MyShiftService _shiftSevice;
  final ShiftsSyncBloc refresherBloc;
  final MyShiftsBloc shiftsBloc;

  final BehaviorSubject<MyShift> _shiftSubject;
  final SessionTracker sessionTracker;

  StreamSubscription _subscription;

  MyShiftBloc({
    @required this.refresherBloc,
    @required this.shiftsBloc,
    MyShiftService shiftService,
    SessionTracker sessionTracker,
    MyShift shift,
  })  : this._shiftSubject = BehaviorSubject<MyShift>.seeded(shift),
        this._shiftSevice = shiftService ?? sl<MyShiftService>(),
        this.sessionTracker = sessionTracker ?? sl<SessionTracker>() {
    _subscription = listen((state) {
      if (state is MyShiftLoaded) {
        _shiftSubject.add(state.shift);
      }
    });
  }

  @override
  void close() {
    _subscription?.cancel();
    _shiftSubject.close();
    super.close();
  }

  @override
  MyShiftState get initialState => InitialMyShiftState();

  @override
  Stream<MyShiftState> mapEventToState(
    MyShiftEvent event,
  ) async* {
    if (event is FetchAndUpdateMyStatus) {
      yield MyShiftLoading();
      final r = await _shiftSevice.getShift(event.shiftId);

      if (r.isSuccessful) {
        var shift = r.result;

        if (shift.worker.isNew && shift.isUnFilled) {
          final r1 = await _shiftSevice.updateStatus(ShiftWorkerUpdateRequest(
            shiftId: event.shiftId,
            workerStaus: WorkerStatus.undecided,
          ));

          if (!r1.isSuccessful) {
            shift = r1.result;
          }
        }

        yield MyShiftLoaded(
          shift: shift,
        );
      } else {
        yield MyShiftError("Failed to get the shift details",
            exception: r.getException());
      }
    }

    if (event is FetchMyShift) {
      yield MyShiftLoading();
      final r = await _shiftSevice.getShift(event.id);

      if (r.isSuccessful) {
        yield MyShiftLoaded(
          shift: r.result,
        );
      } else {
        yield MyShiftError("Failed to get the shift details",
            exception: r.getException());
      }
    }

    if (event is UpdateMyStatus) {
      final current = currentShift;
      yield MyShiftActionLoading();
      final r = await _shiftSevice.updateStatus(ShiftWorkerUpdateRequest(
        shiftId: current.id,
        workerStaus: event.status,
      ));

      if (r.isSuccessful) {
        shiftsBloc.add(MyShiftUpdated(r.result));
        refresherBloc.add(SyncShifts());
        yield MyShiftLoaded(
          shift: r.result,
        );
      } else {
        yield MyShiftError(
          r.error,
          exception: r.getException(),
        );
      }
    }
  }

  Stream<MyShift> get shift => _shiftSubject.stream;
  MyShift get currentShift => _shiftSubject.value;
}
