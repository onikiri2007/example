import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class MyShiftEvent {}

class FetchMyShift extends MyShiftEvent {
  final int id;

  FetchMyShift(this.id) : assert(id != null);

  @override
  String toString() => 'FetchMyShift';
}

class UpdateMyStatus extends MyShiftEvent {
  final WorkerStatus status;
  final int shiftId;

  UpdateMyStatus({
    @required this.shiftId,
    @required this.status,
  });

  @override
  String toString() => 'UpdateMyStatus';
}

class FetchAndUpdateMyStatus extends MyShiftEvent {
  final int shiftId;

  FetchAndUpdateMyStatus(
    this.shiftId,
  );

  @override
  String toString() => 'FetchAndUpdateMyStatus';
}
