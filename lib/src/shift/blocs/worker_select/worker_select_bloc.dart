import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import './bloc.dart';

class WorkerSelectBloc extends Bloc<WorkerSelectEvent, WorkerSelectState>
    implements BlocBase {
  final List<Worker> selectedWorkers;
  final Worker currentWorker;

  WorkerSelectBloc({
    this.selectedWorkers = const [],
    this.currentWorker,
  });

  @override
  WorkerSelectState get initialState => WorkerSelectState(
        currentWorker: currentWorker,
        selectedWorkers: List.from(selectedWorkers),
        noOfSelected: selectedWorkers.length,
      );

  @override
  Stream<WorkerSelectState> mapEventToState(
    WorkerSelectEvent event,
  ) async* {
    if (event is SelectEmployee) {
      if (event.isSelected) {
        yield state.addWorker(event.workers);
      } else {
        yield state.removeWorker(event.workers);
      }
    }

    if (event is SelectAllWorkers) {
      if (event.isSelected) {
        yield state.addWorkers(event.allWorkers,
            isAllWorkers: event.isSelected);
      } else {
        yield state.removeWorkers(event.allWorkers,
            isAllWorkers: event.isSelected);
      }
    }
  }

  @override
  void dispose() {
    this.close();
  }
}
