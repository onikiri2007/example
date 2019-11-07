import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class WorkerSelectEvent extends Equatable {}

class SelectEmployee extends WorkerSelectEvent {
  final Worker workers;
  final bool isSelected;
  SelectEmployee({
    this.workers,
    this.isSelected,
  });

  @override
  String toString() => 'SelectEmployee';

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SelectAllWorkers extends WorkerSelectEvent {
  final List<Worker> allWorkers;
  final bool isSelected;
  SelectAllWorkers({
    this.allWorkers,
    this.isSelected,
  });

  @override
  String toString() => 'SelectAllWorkers';

  @override
  // TODO: implement props
  List<Object> get props => [];
}
