import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';
import './bloc.dart';

enum ManageShiftListFilterType {
  All,
  Pending,
  Filled,
}

class ManageShiftsBloc extends Bloc<ManageShiftsEvent, ManageShiftsState> {
  ManageShiftsBloc({
    @required this.refresherBloc,
    ManageShiftService shiftService,
  }) : this._shiftService = sl<ManageShiftService>() {
    _subscriptions.add(
      _shiftListFilterSubject.listen(
        (filter) {
          final currentState = this.state;
          if (currentState is ManageShiftsLoaded) {
            _filteredShiftsSubject
                .add(_groupShiftsByDate(currentState.shifts, filter));
          }
        },
      ),
    );

    _subscriptions.add(
      listen((state) {
        if (state is ManageShiftsLoaded) {
          _filteredShiftsSubject.add(
              _groupShiftsByDate(state.shifts, _shiftListFilterSubject.value));
        }
      }),
    );

    _subscriptions.add(refresherBloc.listen((state) {
      if (state is ShiftsSyncing) {
        add(RefreshManageShifts());
      }
    }));
  }

  final ShiftsSyncBloc refresherBloc;

  final BehaviorSubject<Map<DateTime, List<ManageShift>>>
      _filteredShiftsSubject = BehaviorSubject.seeded({});

  final BehaviorSubject<ManageShiftListFilterType> _shiftListFilterSubject =
      BehaviorSubject.seeded(ManageShiftListFilterType.All);

  final CompositeSubscription _subscriptions = CompositeSubscription();

  final ManageShiftService _shiftService;
  StreamSubscription _refreshSubscription;

  @override
  ManageShiftsState get initialState => InitialManageShiftsState();

  @override
  void close() {
    _filteredShiftsSubject.close();
    _shiftListFilterSubject.close();
    _subscriptions.dispose();
    _refreshSubscription?.cancel();
    super.close();
  }

  @override
  Stream<ManageShiftsState> mapEventToState(
    ManageShiftsEvent event,
  ) async* {
    if (event is FetchManageShifts) {
      yield ManageShiftsLoading();
      final result = await _shiftService.getShifts();
      if (!result.isSuccessful) {
        yield ManageShiftsError(result.error, exception: result.getException());
      } else {
        yield ManageShiftsLoaded(
            shifts: result.result, autoScroll: event.autoScroll);
      }
    }

    if (event is ManageShiftUpdated) {
      final currentState = this.state;
      if (currentState is ManageShiftsLoaded) {
        List<ManageShift> newShifts = [];
        final changed = currentState.shifts.firstWhere(
            (s) => s.id == event.shift.id,
            orElse: () => currentState.shifts.first);
        if (changed != null) {
          final changedIndex = currentState.shifts.indexOf(changed);
          newShifts.addAll(currentState.shifts.toList());
          newShifts[changedIndex] = event.shift;
          yield ManageShiftsLoaded(shifts: newShifts);
        }
      }
    }

    if (event is RefreshManageShifts) {
      final result = await _shiftService.getShifts();
      if (result.isSuccessful) {
        yield ManageShiftsLoaded(shifts: result.result);
      }

      refresherBloc.add(SyncShiftsCompleted());
    }
  }

  ValueObservable<ManageShiftListFilterType> get currentFilter =>
      _shiftListFilterSubject.stream;
  void Function(ManageShiftListFilterType) get changeFilter =>
      _shiftListFilterSubject.add;

  ValueObservable<Map<DateTime, List<ManageShift>>> get shifts =>
      _filteredShiftsSubject.stream;

  Map<DateTime, List<ManageShift>> _groupShiftsByDate(
      List<Shift> shifts, ManageShiftListFilterType value) {
    List<Shift> filtered = shifts;

    switch (value) {
      case ManageShiftListFilterType.Pending:
        filtered = shifts
            .where((shift) =>
                shift.status == ShiftStatus.unfilled && shift.isActive)
            .toList();
        break;
      case ManageShiftListFilterType.Filled:
        filtered = shifts
            .where(
                (shift) => shift.status == ShiftStatus.filled && shift.isActive)
            .toList();
        break;
      default:
        filtered = shifts;
        break;
    }

    Map<DateTime, List<ManageShift>> maps = {};
    filtered.forEach((shift) {
      final dateKey = DateTimeHelper.toDateOnly(shift.startOn);
      maps.update(
          dateKey,
          (shifts) => shifts
            ..add(shift)
            ..sort((s1, s2) => s1.startOn.compareTo(s2.startOn)),
          ifAbsent: () => [shift]);
    });

    return maps;
  }

  void startAutoRefresh({bool myShifts = false}) {
    _refreshSubscription?.cancel();
    _refreshSubscription = Observable.periodic(Duration(hours: 1)).listen((_) {
      add(RefreshManageShifts());
    });
  }

  void stopAutoRefresh() {
    _refreshSubscription?.cancel();
    _refreshSubscription = null;
  }
}
