import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class SkillSelectEvent {}

class SelectSkill extends SkillSelectEvent {
  final Skill skill;
  final bool isSelected;
  SelectSkill({
    this.skill,
    this.isSelected,
  });

  @override
  String toString() => 'SelectSkill';
}
