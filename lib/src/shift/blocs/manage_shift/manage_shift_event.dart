import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class ManageShiftEvent {}

class FetchManageShift extends ManageShiftEvent {
  final int id;

  FetchManageShift(this.id) : assert(id != null);

  @override
  String toString() => 'FetchManageShift';
}

class UpdateResponseStatus extends ManageShiftEvent {
  final Worker worker;
  final WorkerStatus status;

  UpdateResponseStatus({
    @required this.worker,
    @required this.status,
  });

  @override
  String toString() => 'UpdateResponseStatus';
}

class ResendInvites extends ManageShiftEvent {
  @required
  final int shiftId;
  ResendInvites(this.shiftId);

  @override
  String toString() => 'ResendInvites';
}

class DeleteShift extends ManageShiftEvent {
  @required
  final int shiftId;
  DeleteShift(this.shiftId);

  @override
  String toString() => 'DeleteShift';
}

class InviteFromOtherSites extends ManageShiftEvent {
  final int shiftId;
  final List<Site> sites;
  InviteFromOtherSites({
    @required this.shiftId,
    this.sites = const [],
  });

  @override
  String toString() => 'InviteFromOtherSites';
}

class ResetShiftActionResult extends ManageShiftEvent {
  @override
  String toString() => 'ResetShiftActionResult';
}

class TurnOnOrOffNotification extends ManageShiftEvent {
  final int shiftId;
  final int managerId;
  TurnOnOrOffNotification({
    @required this.shiftId,
    this.managerId,
  });

  @override
  String toString() => 'TurnOnOrOffNotification';
}
