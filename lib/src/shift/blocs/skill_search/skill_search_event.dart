import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SkillSearchEvent extends Equatable {}

class SkillSearchStarted extends SkillSearchEvent {
  @override
  String toString() => 'SkillSearchStarted';

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SearchSkills extends SkillSearchEvent {
  final String query;

  SearchSkills({
    this.query,
  });

  @override
  String toString() => 'SearchSkills $query';

  @override
  // TODO: implement props
  List<Object> get props => [query];
}
