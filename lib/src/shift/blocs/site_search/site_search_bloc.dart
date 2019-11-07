import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';

class SiteSearchBloc extends Bloc<SiteSearchEvent, SiteSearchState>
    implements BlocBase {
  final CompanyService companyService;

  SiteSearchBloc({
    CompanyService companyService,
  }) : this.companyService = companyService ?? sl<CompanyService>();

  @override
  SiteSearchState get initialState => SiteSearchNoTerm();

  @override
  Stream<SiteSearchState> mapEventToState(
    SiteSearchEvent event,
  ) async* {
    if (event is SiteSearchStarted) {
      yield* search(null, currentLocation: event.currentLocation);
    }

    if (event is SearchSites) {
      yield SiteSearchLoading();
      yield* search(event.query, currentLocation: event.currentLocation);
    }
  }

  Stream<SiteSearchState> search(String query, {Site currentLocation}) async* {
    var r = await companyService.searchSites(query);
    if (r.isSuccessful) {
      if (r.result.isEmpty) {
        yield SiteSearchEmpty();
      } else {
        List<Site> sites = r.result;

        if (currentLocation != null) {
          sites = r.result
              .map((s) => s.copyWith(
                  distanceKm: s.distanceFrom(
                      currentLocation.latitude, currentLocation.longitude)))
              .toList();
          sites.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        }

        yield SiteSearchSuccess(sites: sites);
      }
    } else {
      yield SiteSearchError(
        r.error,
        exception: r.getException(),
      );
    }
  }

  @override
  Stream<SiteSearchState> transformEvents(Stream<SiteSearchEvent> events,
      Stream<SiteSearchState> Function(SiteSearchEvent event) next) {
    return super.transformEvents(
        (events as Observable<SiteSearchEvent>)
            .distinct()
            .debounceTime(const Duration(milliseconds: 250)),
        next);
  }

  @override
  void dispose() {
    this.close();
  }
}
