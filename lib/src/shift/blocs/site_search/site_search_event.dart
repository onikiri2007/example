import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class SiteSearchEvent extends Equatable {}

class SiteSearchStarted extends SiteSearchEvent {
  final Site currentLocation;

  SiteSearchStarted({
    this.currentLocation,
  });

  @override
  String toString() => 'SiteSearchStarted';

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SearchSites extends SiteSearchEvent {
  final String query;

  final Site currentLocation;

  SearchSites({
    this.query,
    this.currentLocation,
  });

  @override
  String toString() => 'SearchSite $query';

  @override
  // TODO: implement props
  List<Object> get props => [query];
}
