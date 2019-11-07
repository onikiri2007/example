import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/shift/index.dart';
import './bloc.dart';

class SiteSelectBloc extends Bloc<SiteSelectEvent, SiteSelectState>
    implements BlocBase {
  final List<Site> selectedSites;
  final Site currentLocation;
  SiteSelectBloc({
    this.currentLocation,
    this.selectedSites = const [],
  });

  @override
  SiteSelectState get initialState => SiteSelectState(
        currentLocation: currentLocation,
        selectedSites: List.from(selectedSites),
        noOfSelected: selectedSites.length,
      );

  List<Site> get initialSelected {
    final list = initialState.selectedSites
        .map((site) => site.copyWith(
            distanceKm: site.distanceFrom(
                this.currentLocation.latitude, this.currentLocation.longitude)))
        .toList();

    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }

  @override
  Stream<SiteSelectState> mapEventToState(
    SiteSelectEvent event,
  ) async* {
    if (event is SelectSite) {
      if (event.isSelected) {
        yield state.addSite(event.site);
      } else {
        yield state.removeSite(event.site);
      }
    }
  }

  @override
  void dispose() {
    this.close();
  }
}
