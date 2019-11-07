import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class ManageShiftState {}

class InitialManageShiftState extends ManageShiftState {}

class ManageShiftError extends ManageShiftState {
  final Exception exception;
  final String error;

  ManageShiftError(
    this.error, {
    this.exception,
  });

  @override
  String toString() =>
      'ManageShiftError => error: error, exception: ${exception.toString()}';
}

class ManageShiftLoading extends ManageShiftState {
  @override
  String toString() => 'ManageShiftLoading';
}

class ManageShiftActionLoading extends ManageShiftState {
  final int shiftId;
  final int workerId;
  ManageShiftActionLoading({
    this.shiftId,
    this.workerId,
  });

  @override
  String toString() => 'ManageShiftActionLoading';
}

class ManageShiftMenuActionLoading extends ManageShiftState {
  @override
  String toString() => 'ManageShiftMenuActionLoading';
}

enum ManageShiftActionResult {
  none,
  error,
  success,
}

enum ManageShiftAction {
  none,
  changeStatus,
  resendInvites,
  inviteFromOtherSite,
  turnOnNotification,
  deleteShift
}

class ManageShiftLoaded extends ManageShiftState {
  final ManageShift shift;
  final ManageShiftActionResult actionResult;
  final ManageShiftAction action;
  final String actionMessage;

  ManageShiftLoaded({
    this.shift,
    this.action = ManageShiftAction.none,
    this.actionResult = ManageShiftActionResult.none,
    this.actionMessage,
  });

  @override
  String toString() => 'ManageShiftLoaded';
}
