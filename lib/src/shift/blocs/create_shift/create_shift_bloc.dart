import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';
import './bloc.dart';
import 'package:rxdart/rxdart.dart';

const int kShiftMinuteInterval = 15;

class CreateShiftBloc extends Bloc<CreateShiftEvent, CreateShiftState>
    implements BlocBase {
  final SessionTracker sessionTracker;
  final ShiftsSyncBloc refresherBloc;
  final ManageShiftService shiftService;

  final BehaviorSubject<CreateShiftSteps> _stepsController =
      BehaviorSubject.seeded(CreateShiftSteps(
    step: 1,
    maxSteps: 4,
    currentMaxStep: 3,
  ));

  CreateShiftBloc({
    @required this.refresherBloc,
    SessionTracker sessionTracker,
    ManageShiftService shiftService,
  })  : this.shiftService = shiftService ?? sl<ManageShiftService>(),
        this.sessionTracker = sessionTracker ?? sl<SessionTracker>();

  @override
  void close() {
    _stepsController.close();
    super.close();
  }

  @override
  CreateShiftState get initialState => CreateShiftStepState(
      currentStep: 1,
      shiftDetails: ShiftDetails(
        manager: currentWorker,
      ));

  @override
  Stream<CreateShiftState> mapEventToState(
    CreateShiftEvent event,
  ) async* {
    final currentState = state;

    if (event is CreateShiftMoveToStepFromReview) {
      _stepsController.add(_stepsController.value.moveBackword());

      yield* _handleCreateShiftStepEvent(event);
    }

    if (event is ResetCreateShift) {
      yield* _handleCreateShiftStepEvent(event);
    }

    if (currentState is CreateShiftStepState) {
      yield* _handleCreateShiftStepEvents(event, currentState);
    }
  }

  Worker get currentWorker => Worker(
        id: -1,
        name: sessionTracker.session.value.userData.fullName,
      );

  Stream<CreateShiftSteps> get steps => _stepsController;

  CreateShiftSteps get initialStep => _stepsController.value;

  Stream<CreateShiftState> _handleCreateShiftStepEvent(
      CreateShiftStepEvent event) async* {
    yield CreateShiftStepState(
      approvalDetails: event.approvalDetails,
      canNavigate: false,
      currentStep: event.step,
      eligibleWorkers: event.eligibleWorkers,
      peopleDetails: event.peopleDetails,
      shiftDetails: event.shiftDetails,
    );
  }

  Stream<CreateShiftState> _handleCreateShiftStepEvents(
      CreateShiftEvent event, CreateShiftStepState state) async* {
    if (event is CreateShiftMoveToStep) {
      _stepsController.add(_stepsController.value.moveBackword());

      yield state.copyWith(
        currentStep: event.step,
      );
    }

    if (event is ChangeLocation) {
      yield state.copyWith(
          shiftDetails: state.shiftDetails.copyWith(
        location: event.site,
      ));
    }

    if (event is UpdateShiftDetails) {
      _stepsController.add(_stepsController.value.moveForward());

      yield state.copyWith(
          currentStep: 2,
          shiftDetails: state.shiftDetails.copyWith(
            description: event.description,
            endDate: event.endDate,
            startDate: event.startDate,
            name: event.name,
            location: event.location,
          ));
    }

    if (event is UpdatePeopleRequirements) {
      _stepsController.add(_stepsController.value.moveForward());

      yield state.copyWith(
        currentStep: 3,
        eligibleWorkers: event.eligibleWorkers,
        peopleDetails: state.peopleDetails.copyWith(
          noOfPeople: event.headCount,
          role: event.role,
          sites: event.sites,
          skills: event.skills,
        ),
      );
    }

    if (event is UpdateApprovalRequirements) {
      _stepsController.add(_stepsController.value.moveForward());
      yield state.copyWith(
        currentStep: 4,
        canNavigate: true,
        approvalDetails: state.approvalDetails.copyWith(
          mode: event.mode,
          workers: event.workers,
          approver: currentWorker,
        ),
      );
    }

    if (event is ResetShiftStep) {
      yield state.copyWith(
        canNavigate: false,
      );
    }

    if (event is ResetCreateShift) {
      yield CreateShiftInitial();
    }

    if (event is CreateShift) {
      yield CreateShiftLoading();

      var startTime = event.shiftDetails.startDate;
      var endTime = event.shiftDetails.endDate;

      // This shouldn't happen most of the time
      if (startTime.isBefore(DateTime.now())) {
        startTime = DateTimeHelper.convertToIntervalMinutesDateTime(
            DateTime.now(), kShiftMinuteInterval);
        endTime = event.shiftDetails.endDate
            .add(Duration(minutes: kShiftMinuteInterval));
      }

      final result = await shiftService.createShift(
        event.shiftDetails.copyWith(
          startDate: startTime,
          endDate: endTime,
        ),
        event.peopleDetails.copyWith(
          sites: event.peopleDetails.sites
              .where((s) => s.id != event.shiftDetails.location.id)
              .toList(),
        ),
        event.approvalDetails,
      );

      if (!result.isSuccessful) {
        yield CreateShiftError(result.error, exception: result.getException());
      } else {
        refresherBloc.add(SyncShifts());
        yield CreateShiftSuccess();
      }
    }
  }

  @override
  void dispose() {
    this.close();
  }
}
