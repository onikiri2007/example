import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class SkillSearchState extends Equatable {}

class SkillSearchNoTerm extends SkillSearchState {
  @override
  String toString() => 'SiteSearchNoTerm';

  @override
  List<Object> get props => [];
}

class SkillSearchEmpty extends SkillSearchState {
  @override
  String toString() => 'SiteSearchEmpty';
  @override
  List<Object> get props => [];
}

class SkillSearchLoading extends SkillSearchState {
  @override
  String toString() => 'SiteSearchLoading';
  @override
  List<Object> get props => [];
}

class SkillSearchSuccess extends SkillSearchState {
  final List<Skill> skills;

  SkillSearchSuccess({
    this.skills,
  });

  @override
  String toString() => 'SkillSearchSuccess';
  @override
  List<Object> get props => [
        skills,
      ];
}

class SkillSearchError extends SkillSearchState {
  final Exception exception;
  final String error;

  SkillSearchError(
    this.error, {
    this.exception,
  });

  @override
  String toString() =>
      'SkillSearchError => error: $error, exception: ${exception.toString()}';

  @override
  List<Object> get props => [error];
}
