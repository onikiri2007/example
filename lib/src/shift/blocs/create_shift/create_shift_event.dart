import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/shift/index.dart';

@immutable
abstract class CreateShiftEvent {
  final int step;
  CreateShiftEvent({
    this.step,
  });
}

class ChangeLocation extends CreateShiftEvent {
  final Site site;
  ChangeLocation({
    this.site,
  });

  @override
  String toString() => 'ChangeSite';
}

class CreateShiftMoveToStep extends CreateShiftEvent {
  final int step;
  CreateShiftMoveToStep({
    this.step = 1,
  });
  toString() => "CreateShiftMoveToStep";
}

abstract class CreateShiftStepEvent extends CreateShiftEvent {
  final int step;
  final ShiftDetails shiftDetails;
  final ShiftPeopleRequirements peopleDetails;
  final ShiftApprovalRequirements approvalDetails;
  final int eligibleWorkers;

  CreateShiftStepEvent({
    this.step = 1,
    this.shiftDetails,
    this.peopleDetails,
    this.approvalDetails,
    this.eligibleWorkers,
  });
}

class CreateShiftMoveToStepFromReview extends CreateShiftStepEvent {
  final int step;
  final ShiftDetails shiftDetails;
  final ShiftPeopleRequirements peopleDetails;
  final ShiftApprovalRequirements approvalDetails;
  final int eligibleWorkers;

  CreateShiftMoveToStepFromReview({
    this.step = 1,
    this.shiftDetails,
    this.peopleDetails,
    this.approvalDetails,
    this.eligibleWorkers,
  }) : super(
          step: step,
          shiftDetails: shiftDetails,
          peopleDetails: peopleDetails,
          approvalDetails: approvalDetails,
          eligibleWorkers: eligibleWorkers,
        );

  toString() => "CreateShiftMoveToStep";
}

class ResetShiftStep extends CreateShiftEvent {
  toString() => "ResetShiftStep";
}

class UpdateShiftDetails extends CreateShiftEvent {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final Site location;

  UpdateShiftDetails({
    this.name,
    this.startDate,
    this.endDate,
    this.description,
    this.location,
  }) : super(step: 2);

  @override
  String toString() => 'UpdateShiftDetails';
}

class UpdatePeopleRequirements extends CreateShiftEvent {
  final Duty role;
  final int headCount;
  final List<Site> sites;
  final List<Skill> skills;
  final int eligibleWorkers;

  UpdatePeopleRequirements({
    this.role,
    this.headCount,
    this.sites,
    this.skills,
    this.eligibleWorkers,
  });

  @override
  String toString() => 'UpdatePeopleRequirements';
}

class UpdateApprovalRequirements extends CreateShiftEvent {
  final ShiftApprovalMode mode;
  final ShiftApprovalPermission approvalPrivacyMode;
  final List<Worker> workers;

  UpdateApprovalRequirements({
    this.mode,
    this.approvalPrivacyMode,
    this.workers = const [],
  });

  @override
  String toString() => 'UpdateApprovalRequirements';
}

class CreateShift extends CreateShiftEvent {
  final ShiftDetails shiftDetails;
  final ShiftPeopleRequirements peopleDetails;
  final ShiftApprovalRequirements approvalDetails;
  final int eligibleWorkers;

  CreateShift({
    @required this.shiftDetails,
    @required this.peopleDetails,
    @required this.approvalDetails,
    @required this.eligibleWorkers,
  }) : super(step: 4);

  @override
  String toString() => 'CreateShift';
}

class ResetCreateShift extends CreateShiftStepEvent {
  final ShiftDetails shiftDetails;
  final ShiftPeopleRequirements peopleDetails;
  final ShiftApprovalRequirements approvalDetails;
  final int eligibleWorkers;

  ResetCreateShift({
    this.shiftDetails,
    this.peopleDetails,
    this.approvalDetails,
    this.eligibleWorkers,
  }) : super(
          step: 4,
          shiftDetails: shiftDetails,
          peopleDetails: peopleDetails,
          approvalDetails: approvalDetails,
          eligibleWorkers: eligibleWorkers,
        );

  @override
  String toString() => 'ResetCreateShift';
}
