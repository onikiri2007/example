import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
class WorkerSelectState extends Equatable {
  final List<Worker> selectedWorkers;
  final bool isAllWorkers;
  final Worker currentWorker;
  final int noOfSelected;
  WorkerSelectState({
    this.currentWorker,
    this.selectedWorkers = const [],
    this.noOfSelected,
    this.isAllWorkers = false,
  });

  WorkerSelectState addWorker(Worker employee) {
    final selected = <Worker>[]
      ..addAll(selectedWorkers ?? [])
      ..add(employee);

    return copyWith(
      selectedWorkers: selected,
    );
  }

  WorkerSelectState removeWorker(Worker employee) {
    selectedWorkers?.removeWhere((s) => s.id == employee.id);
    final selected = <Worker>[]..addAll(selectedWorkers);
    return copyWith(
      selectedWorkers: selected,
    );
  }

  WorkerSelectState addWorkers(
    List<Worker> workers, {
    bool isAllWorkers = false,
  }) {
    return copyWith(
      selectedWorkers: workers,
      isAllWorkers: isAllWorkers,
    );
  }

  WorkerSelectState removeWorkers(
    List<Worker> workers, {
    bool isAllWorkers = false,
  }) {
    final ids = workers.map((e) => e.id).toList();
    selectedWorkers?.removeWhere((s) => ids.contains(s.id));
    final selected = <Worker>[]..addAll(selectedWorkers);
    return copyWith(
      selectedWorkers: selected,
      isAllWorkers: isAllWorkers,
    );
  }

  WorkerSelectState copyWith({
    List<Worker> selectedWorkers,
    bool isAllWorkers,
    Worker currentWorker,
  }) =>
      WorkerSelectState(
        currentWorker: currentWorker ?? this.currentWorker,
        isAllWorkers: isAllWorkers ?? this.isAllWorkers,
        selectedWorkers: selectedWorkers ?? this.selectedWorkers,
        noOfSelected: selectedWorkers != null
            ? selectedWorkers.length
            : this.selectedWorkers.length,
      );

  @override
  // TODO: implement props
  List<Object> get props => [
        selectedWorkers,
        noOfSelected,
        isAllWorkers,
      ];
}
