import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';
import './bloc.dart';

class WorkerSearchBloc extends Bloc<WorkerSearchEvent, WorkerSearchState>
    implements BlocBase {
  final CompanyService companyService;
  WorkerSearchBloc({
    CompanyService companyService,
  }) : this.companyService = companyService ?? sl<CompanyService>();

  @override
  WorkerSearchState get initialState => WorkerNoTerm();

  @override
  Stream<WorkerSearchState> mapEventToState(
    WorkerSearchEvent event,
  ) async* {
    if (event is LoadWorkers) {
      yield* search(event.siteId, null);
    }

    if (event is SearchWorker) {
      yield WorkerSearchLoading();
      yield* search(event.siteId, event.query);
    }
  }

  Stream<WorkerSearchState> search(int siteId, String query) async* {
    var r = await companyService.searchManagers(query, siteId: siteId);
    if (r.isSuccessful) {
      final workers = List<Worker>.of(r.result);
      if (query == null || query.isEmpty && workers.isNotEmpty) {
        workers.insert(0, Worker.all());
      }
      yield WorkerSearchSuccess(workers: workers);
    } else {
      yield WorkerSearchError(
        r.error,
        exception: r.getException(),
      );
    }
  }

  @override
  Stream<WorkerSearchState> transformEvents(Stream<WorkerSearchEvent> events,
      Stream<WorkerSearchState> Function(WorkerSearchEvent event) next) {
    var eventsObservable = events as Observable<WorkerSearchEvent>;
    return super.transformEvents(
        eventsObservable
            .distinct()
            .debounceTime(const Duration(milliseconds: 250)),
        next);
  }

  @override
  void dispose() {
    this.close();
  }
}
