import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class WorkerSearchEvent extends Equatable {}

class LoadWorkers extends WorkerSearchEvent {
  final int siteId;
  LoadWorkers({this.siteId});

  @override
  String toString() => 'StartSearchWorker';

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SearchWorker extends WorkerSearchEvent {
  final int siteId;
  final String query;

  SearchWorker({
    this.siteId,
    this.query,
  });

  @override
  String toString() => 'SearchEmployee $query';

  @override
  // TODO: implement props
  List<Object> get props => [query];
}
