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

class ManageShiftBloc extends Bloc<ManageShiftEvent, ManageShiftState> {
  final ManageShiftService shiftSevice;
  final ShiftsSyncBloc refresherBloc;
  final ManageShiftsBloc shiftsBloc;

  final BehaviorSubject<ShiftWorkerSearchCriteria> _searchWorkerSubject =
      BehaviorSubject();

  final BehaviorSubject<ManageShift> _shiftSubject;

  final BehaviorSubject<bool> _menuSubject = BehaviorSubject.seeded(false);
  final SessionTracker sessionTracker;

  StreamSubscription _subscription;
  ManageShiftBloc({
    @required this.refresherBloc,
    @required this.shiftsBloc,
    ManageShiftService shiftService,
    SessionTracker sessionTracker,
    ManageShift shift,
  })  : this._shiftSubject = BehaviorSubject<ManageShift>.seeded(shift),
        this.shiftSevice = shiftService ?? sl<ManageShiftService>(),
        this.sessionTracker = sessionTracker ?? sl<SessionTracker>() {
    _subscription = listen((state) {
      if (state is ManageShiftLoaded) {
        _shiftSubject.add(state.shift);
      }
    });
  }

  @override
  void close() {
    _searchWorkerSubject.close();
    _subscription?.cancel();
    _shiftSubject.close();
    _menuSubject.close();
    super.close();
  }

  @override
  ManageShiftState get initialState => InitialManageShiftState();

  @override
  Stream<ManageShiftState> mapEventToState(
    ManageShiftEvent event,
  ) async* {
    if (event is FetchManageShift) {
      yield ManageShiftLoading();
      final r = await shiftSevice.getShift(event.id);

      if (r.isSuccessful) {
        yield ManageShiftLoaded(
          shift: r.result,
        );
      } else {
        yield ManageShiftError("Failed to get the shift details",
            exception: r.getException());
      }
    }

    if (event is UpdateResponseStatus) {
      final current = currentShift;
      yield ManageShiftActionLoading(
        shiftId: current.id,
        workerId: event.worker.id,
      );
      final r = await shiftSevice.updateWorkerStatus(ShiftWorkerUpdateRequest(
        shiftId: current.id,
        workerId: event.worker.id,
        workerStaus: event.status,
      ));

      if (r.isSuccessful) {
        shiftsBloc.add(ManageShiftUpdated(r.result));
        refresherBloc.add(SyncShifts());
        yield ManageShiftLoaded(
          shift: r.result,
        );
      } else {
        yield ManageShiftError(
          r.error,
          exception: r.getException(),
        );
      }
    }

    if (event is ResendInvites) {
      yield ManageShiftMenuActionLoading();
      final r = await shiftSevice.sendNotification(event.shiftId);
      _menuSubject.add(false);
      if (r.isSuccessful) {
        refresherBloc.add(SyncShifts());
        yield ManageShiftLoaded(
          shift: r.result,
          actionResult: ManageShiftActionResult.success,
          actionMessage: "Invitation successfully resent",
        );
      } else {
        yield ManageShiftError(
          "Failed to send invitations. Please try again",
          exception: r.getException(),
        );
      }
    }

    if (event is DeleteShift) {
      yield ManageShiftLoading();
      final r = await shiftSevice.deleteShift(event.shiftId);
      _menuSubject.add(false);
      if (r.isSuccessful) {
        refresherBloc.add(SyncShifts());
        yield ManageShiftLoaded(
          shift: r.result,
          actionResult: ManageShiftActionResult.success,
          actionMessage: "Shift successfully deleted",
        );
      } else {
        yield ManageShiftError(
          "Failed to delete shift. Please try again",
          exception: r.getException(),
        );
      }
    }

    if (event is InviteFromOtherSites) {
      yield ManageShiftActionLoading(
        shiftId: event.shiftId,
      );
      final r = await shiftSevice.updateShift(
        PatchShiftRequest(
          id: event.shiftId,
          otherSiteIds: event.sites.map((s) => s.id).toList(),
        ),
      );
      if (r.isSuccessful) {
        refresherBloc.add(SyncShifts());
        yield ManageShiftLoaded(
          shift: r.result,
          action: ManageShiftAction.inviteFromOtherSite,
          actionResult: ManageShiftActionResult.success,
          actionMessage: "Successfully invited",
        );
      } else {
        yield ManageShiftError(
          "Failed to invite other sites. Please try again",
          exception: r.getException(),
        );
      }
    }

    if (event is ResetShiftActionResult) {
      yield ManageShiftLoaded(
        shift: _shiftSubject.value,
        actionMessage: "",
        actionResult: ManageShiftActionResult.none,
        action: ManageShiftAction.none,
      );
    }

    if (event is TurnOnOrOffNotification) {
      yield ManageShiftMenuActionLoading();

      List<int> otherManagers = [];

      if (event.managerId != null) {
        otherManagers = currentShift?.managers
                ?.where((m) => m.id != event.managerId)
                ?.map((m) => m.id)
                ?.toList() ??
            [];
      } else if (sessionTracker?.currentSession?.userData?.userId != null) {
        otherManagers = [
          sessionTracker.currentSession.userData.userId ?? 0,
        ];
      }

      final r = await shiftSevice.updateShift(
        PatchShiftRequest(
          id: event.shiftId,
          otherSiteIds: currentShift.otherSiteIds,
          otherManagerIds: otherManagers,
        ),
      );
      _menuSubject.add(false);
      if (r.isSuccessful) {
        refresherBloc.add(SyncShifts());
        yield ManageShiftLoaded(
          shift: r.result,
          action: ManageShiftAction.none,
        );
      } else {
        yield ManageShiftError(
          r.error,
          exception: r.getException(),
        );
      }
    }
  }

  void Function(ShiftWorkerSearchCriteria) get onQueryChanged =>
      _searchWorkerSubject.add;

  void Function(bool) get enableMenu => _menuSubject.add;
  Stream<bool> get menuEnabled => _menuSubject.stream;

  Stream<List<Worker>> get workers => _searchWorkerSubject
      .distinct()
      .debounceTime(Duration(milliseconds: 250))
      .switchMap<List<Worker>>(
          (ShiftWorkerSearchCriteria criteria) => _search(criteria));

  Stream<List<Worker>> _search(ShiftWorkerSearchCriteria criteria) {
    return _shiftSubject.stream.map((shift) {
      final responses = FilteredResponses(workers: shift.workers);
      if (criteria.filter == ShiftResponseFilterType.approved) {
        return responses.approved
            .where((w) => w.name.contains(criteria.query))
            .toList();
      } else {
        return responses.workers
            .where((w) => w.name.contains(criteria.query))
            .toList();
      }
    });
  }

  Stream<ManageShift> get shift => _shiftSubject.stream;
  ManageShift get currentShift => _shiftSubject.value;
}

enum ShiftResponseFilterType {
  responses,
  approved,
}

class ShiftWorkerSearchCriteria {
  final ShiftResponseFilterType filter;
  final String query;

  ShiftWorkerSearchCriteria({
    this.filter = ShiftResponseFilterType.approved,
    this.query = "",
  });
}
