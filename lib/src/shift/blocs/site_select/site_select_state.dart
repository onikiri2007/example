import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
class SiteSelectState extends Equatable {
  final List<Site> selectedSites;
  final Site currentLocation;
  final int noOfSelected;

  SiteSelectState({
    this.selectedSites = const [],
    this.noOfSelected,
    this.currentLocation,
  });

  SiteSelectState addSite(Site site) {
    final selected = <Site>[]..addAll(selectedSites ?? []);

    if (this.currentLocation != null && site.id == this.currentLocation.id) {
      selected.insert(0, site);
    } else {
      selected.add(site);
    }

    return copyWith(
      selectedSites: selected,
    );
  }

  SiteSelectState removeSite(Site site) {
    selectedSites?.removeWhere((s) => s.id == site.id);
    final selected = <Site>[]..addAll(selectedSites);
    return copyWith(
      selectedSites: selected,
    );
  }

  List<Site> get selected {
    final list = selectedSites
        .map((site) => site.copyWith(
            distanceKm: site.distanceFrom(
                this.currentLocation.latitude, this.currentLocation.longitude)))
        .toList();

    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }

  SiteSelectState copyWith({
    List<Site> selectedSites,
  }) =>
      SiteSelectState(
        selectedSites: selectedSites ?? this.selectedSites,
        noOfSelected: selectedSites != null
            ? selectedSites.length
            : this.selectedSites.length,
        currentLocation: this.currentLocation,
      );

  @override
  // TODO: implement props
  List<Object> get props => [
        selectedSites,
        noOfSelected,
      ];
}
