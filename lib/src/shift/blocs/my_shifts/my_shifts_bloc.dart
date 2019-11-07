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

enum MyShiftListFilterType {
  All,
  Available,
  Approved,
}

class MyShiftsBloc extends Bloc<MyShiftsEvent, MyShiftsState> {
  MyShiftsBloc({
    @required this.refresherBloc,
    MyShiftsBloc shiftService,
  })  : assert(refresherBloc != null),
        this._shiftService = sl<MyShiftService>() {
    _subscriptions.add(
      _myShiftListFilterSubject.listen(
        (filter) {
          final currentState = this.state;
          if (currentState is MyShiftsLoaded) {
            _filteredShiftsSubject.add(
                _groupShiftsByDate(_getMyShifts(currentState.shifts), filter));
          }
        },
      ),
    );

    _subscriptions.add(
      listen((state) {
        if (state is MyShiftsLoaded) {
          _filteredShiftsSubject.add(_groupShiftsByDate(
              _getMyShifts(state.shifts), _myShiftListFilterSubject.value));
        }
      }),
    );

    _subscriptions.add(refresherBloc.listen((state) {
      if (state is ShiftsSyncing) {
        add(RefreshMyShifts());
      }
    }));
  }

  final ShiftsSyncBloc refresherBloc;

  final BehaviorSubject<Map<DateTime, List<MyShift>>> _filteredShiftsSubject =
      BehaviorSubject.seeded({});

  final BehaviorSubject<MyShiftListFilterType> _myShiftListFilterSubject =
      BehaviorSubject.seeded(MyShiftListFilterType.All);

  final CompositeSubscription _subscriptions = CompositeSubscription();
  final MyShiftService _shiftService;
  StreamSubscription _refreshSubscription;

  @override
  MyShiftsState get initialState => InitialMyShiftsState();

  @override
  Stream<MyShiftsState> mapEventToState(
    MyShiftsEvent event,
  ) async* {
    if (event is FetchMyShifts) {
      yield MyShiftsLoading();
      final result = await _shiftService.getShifts();
      if (!result.isSuccessful) {
        yield MyShiftsError(result.error, exception: result.getException());
      } else {
        yield MyShiftsLoaded(
            shifts: result.result, autoScroll: event.autoScroll);
      }
    }

    if (event is MyShiftUpdated) {
      final currentState = this.state;
      if (currentState is MyShiftsLoaded) {
        List<MyShift> newShifts = [];
        final changed = currentState.shifts.firstWhere(
            (s) => s.id == event.shift.id,
            orElse: () => currentState.shifts.first);
        if (changed != null) {
          final changedIndex = currentState.shifts.indexOf(changed);
          newShifts.addAll(currentState.shifts.toList());
          newShifts[changedIndex] = event.shift;
          yield MyShiftsLoaded(shifts: newShifts);
        }
      }
    }

    if (event is RefreshMyShifts) {
      final result = await _shiftService.getShifts();
      if (result.isSuccessful) {
        yield MyShiftsLoaded(shifts: result.result);
      }
      refresherBloc.add(SyncShiftsCompleted());
    }
  }

  @override
  void close() {
    _filteredShiftsSubject.close();
    _myShiftListFilterSubject.close();
    _subscriptions.dispose();
    _refreshSubscription?.cancel();
    _refreshSubscription = null;
    super.close();
  }

  void startAutoRefresh({bool myShifts = false}) {
    _refreshSubscription?.cancel();
    _refreshSubscription = Observable.periodic(Duration(hours: 1)).listen((_) {
      add(RefreshMyShifts());
    });
  }

  void stopAutoRefresh() {
    _refreshSubscription?.cancel();
    _refreshSubscription = null;
  }

  Map<DateTime, List<MyShift>> _groupShiftsByDate(
      List<MyShift> shifts, MyShiftListFilterType value) {
    List<MyShift> filtered = shifts;

    switch (value) {
      case MyShiftListFilterType.Available:
        filtered = shifts.where((shift) {
          return (shift.worker.isNew ||
                  shift.worker.isRequested ||
                  shift.worker.isInvited) &&
              shift.isActive;
        }).toList();
        break;
      case MyShiftListFilterType.Approved:
        filtered = shifts.where((shift) {
          return shift.worker.isApproved && shift.isActive;
        }).toList();

        break;
      default:
        filtered = shifts;
        break;
    }

    Map<DateTime, List<MyShift>> maps = {};
    filtered.forEach((shift) {
      final dateKey = DateTimeHelper.toDateOnly(shift.startOn);
      maps.update(
          dateKey,
          (shifts) => shifts
            ..add(shift)
            ..sort((s1, s2) => s2.startOn.compareTo(s2.startOn)),
          ifAbsent: () => [shift]);
    });

    return maps; //_filterApprovedShifts(maps);
  }

  List<Shift> _getMyShifts(List<MyShift> shifts) {
    return shifts.where((shift) {
      return !shift.worker.isDeclined &&
          (shift.isUnFilled || (shift.isFilled && shift.worker.isApproved)) &&
          !shift.isCancelled;
    }).toList();
  }

  ValueObservable<MyShiftListFilterType> get currentFilter =>
      _myShiftListFilterSubject.stream;
  void Function(MyShiftListFilterType) get changeFilter =>
      _myShiftListFilterSubject.add;

  ValueObservable<Map<DateTime, List<MyShift>>> get shifts =>
      _filteredShiftsSubject.stream;

  // //3. once a shift is approved any other shift requests made by the user at the same time should be cancelled
  // Map<DateTime, List<MyShift>> _filterApprovedShifts(
  //     Map<DateTime, List<MyShift>> maps) {
  //   maps.keys.forEach((key) {
  //     final shifts = maps[key];
  //     shifts.sort((s1, s2) => s1.startOn.compareTo(s2.startOn));
  //     final approvedShifts = shifts.where((shift) {
  //       return shift.worker.isApproved;
  //     }).toList();

  //     List<int> excludeShifts = [];
  //     //2. once a shift is approved other available shifts at the same time should no longer be visible
  //     approvedShifts.forEach((shift) {
  //       final sameTimeShifts = shifts.where((s) =>
  //           s.id != shift.id &&
  //           s.startOn.isAtSameMomentAs(shift.startOn) &&
  //           s.isActive);
  //       if (sameTimeShifts.isNotEmpty) {
  //         excludeShifts.addAll(sameTimeShifts.map((s) => s.id));
  //       }
  //     });

  //     maps.update(
  //         key,
  //         (shifts) =>
  //             shifts.where((s) => !excludeShifts.contains(s.id)).toList(),
  //         ifAbsent: () => shifts);
  //   });

  //   return maps;
  // }
}
