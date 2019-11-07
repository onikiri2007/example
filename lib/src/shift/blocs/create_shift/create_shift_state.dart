import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/shift/index.dart';

@immutable
abstract class CreateShiftState extends Equatable {}

abstract class CreateShiftActionState extends CreateShiftState {
  final ShiftDetails shiftDetails;
  final ShiftPeopleRequirements peopleDetails;
  final ShiftApprovalRequirements approvalDetails;
  final int eligibleWorkers;

  CreateShiftActionState({
    this.shiftDetails,
    this.peopleDetails,
    this.approvalDetails,
    this.eligibleWorkers,
  });
}

class CreateShiftStepState extends CreateShiftActionState {
  final int currentStep;
  final ShiftDetails shiftDetails;
  final ShiftPeopleRequirements peopleDetails;
  final ShiftApprovalRequirements approvalDetails;
  final bool canNavigate;

  CreateShiftStepState({
    this.currentStep = 1,
    this.canNavigate = false,
    int eligibleWorkers = 0,
    ShiftDetails shiftDetails,
    ShiftPeopleRequirements peopleDetails,
    ShiftApprovalRequirements approvalDetails,
  })  : shiftDetails = shiftDetails ?? ShiftDetails(),
        peopleDetails = peopleDetails ?? ShiftPeopleRequirements(),
        approvalDetails = approvalDetails ?? ShiftApprovalRequirements(),
        super(
          shiftDetails: shiftDetails,
          approvalDetails: approvalDetails,
          peopleDetails: peopleDetails,
          eligibleWorkers: eligibleWorkers,
        );

  @override
  String toString() => 'CreateShiftStepState';

  CreateShiftStepState copyWith({
    int currentStep,
    bool canNavigate,
    int eligibleWorkers,
    ShiftDetails shiftDetails,
    ShiftPeopleRequirements peopleDetails,
    ShiftApprovalRequirements approvalDetails,
  }) =>
      CreateShiftStepState(
        currentStep: currentStep ?? this.currentStep,
        canNavigate: canNavigate ?? this.canNavigate,
        eligibleWorkers: eligibleWorkers ?? this.eligibleWorkers,
        shiftDetails: shiftDetails ?? this.shiftDetails,
        peopleDetails: peopleDetails ?? this.peopleDetails,
        approvalDetails: approvalDetails ?? this.approvalDetails,
      );

  @override
  // TODO: implement props
  List<Object> get props =>
      [shiftDetails, approvalDetails, peopleDetails, currentStep];
}

class CreateShiftLoading extends CreateShiftState {
  @override
  String toString() => 'CreateShiftLoading';
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class CreateShiftError extends CreateShiftState {
  final Exception exception;
  final String error;

  CreateShiftError(
    this.error, {
    this.exception,
  });

  @override
  String toString() =>
      'CreateShiftError => error: error, exception: ${exception.toString()}';

  @override
  // TODO: implement props
  List<Object> get props => [error, exception];
}

class CreateShiftInitial extends CreateShiftState {
  @override
  String toString() => 'CreateShiftInitial';

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class CreateShiftSuccess extends CreateShiftState {
  @override
  String toString() => 'CreateShiftSuccess';
  @override
  // TODO: implement props
  List<Object> get props => [];
}
