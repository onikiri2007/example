import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';
import './bloc.dart';

class SkillSearchBloc extends Bloc<SkillSearchEvent, SkillSearchState>
    implements BlocBase {
  final CompanyService companyService;
  final Duty currentRole;

  SkillSearchBloc({
    this.currentRole,
    CompanyService companyService,
  }) : this.companyService = companyService ?? sl<CompanyService>();

  @override
  SkillSearchState get initialState => SkillSearchNoTerm();

  @override
  Stream<SkillSearchState> mapEventToState(
    SkillSearchEvent event,
  ) async* {
    if (event is SkillSearchStarted) {
      yield* search(currentRole?.id, null);
    }

    if (event is SearchSkills) {
      yield SkillSearchLoading();
      yield* search(currentRole?.id, event.query);
    }
  }

  Stream<SkillSearchState> search(int dutyId, String query) async* {
    var r = await companyService.searchSkills(query, dutyId: dutyId);
    if (r.isSuccessful) {
      if (r.result.isEmpty) {
        yield SkillSearchEmpty();
      } else {
        yield SkillSearchSuccess(skills: r.result);
      }
    } else {
      yield SkillSearchError(
        r.error,
        exception: r.getException(),
      );
    }
  }

  @override
  Stream<SkillSearchState> transformEvents(Stream<SkillSearchEvent> events,
      Stream<SkillSearchState> Function(SkillSearchEvent event) next) {
    var eventsObservable = events as Observable<SkillSearchEvent>;
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
