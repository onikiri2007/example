import 'package:equatable/equatable.dart';
import 'package:yodel/src/api/index.dart';

abstract class WorkerSearchState extends Equatable {}

class WorkerNoTerm extends WorkerSearchState {
  @override
  String toString() => 'WorkerSearchNoTerm';

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class WorkerSearchEmpty extends WorkerSearchState {
  @override
  String toString() => 'WorkerSearchEmpty';
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class WorkerSearchLoading extends WorkerSearchState {
  @override
  String toString() => 'WorkerSearchLoading';
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class WorkerSearchSuccess extends WorkerSearchState {
  final List<Worker> workers;

  WorkerSearchSuccess({
    this.workers,
  });

  @override
  String toString() => 'WorkerSearchSuccess';
  @override
  // TODO: implement props
  List<Object> get props => [
        workers,
      ];
}

class WorkerSearchError extends WorkerSearchState {
  final Exception exception;
  final String error;

  WorkerSearchError(
    this.error, {
    this.exception,
  });

  @override
  String toString() =>
      'WorkerSearchError => error: $error, exception: ${exception.toString()}';
  @override
  // TODO: implement props
  List<Object> get props => [error];
}
