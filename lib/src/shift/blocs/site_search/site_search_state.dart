import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class SiteSearchState extends Equatable {}

class SiteSearchNoTerm extends SiteSearchState {
  @override
  String toString() => 'SiteSearchNoTerm';

  @override
  List<Object> get props => [];
}

class SiteSearchEmpty extends SiteSearchState {
  @override
  String toString() => 'SiteSearchEmpty';

  @override
  List<Object> get props => [];
}

class SiteSearchLoading extends SiteSearchState {
  @override
  String toString() => 'SiteSearchLoading';

  @override
  List<Object> get props => [];
}

class SiteSearchSuccess extends SiteSearchState {
  final List<Site> sites;

  SiteSearchSuccess({this.sites});

  @override
  String toString() => 'SiteSearchSuccess';

  @override
  List<Object> get props => [
        sites,
      ];
}

class SiteSearchError extends SiteSearchState {
  final Exception exception;
  final String error;

  SiteSearchError(
    this.error, {
    this.exception,
  });

  @override
  String toString() =>
      'SiteSearchError => error: $error, exception: ${exception.toString()}';
  @override
  List<Object> get props => [error];
}
