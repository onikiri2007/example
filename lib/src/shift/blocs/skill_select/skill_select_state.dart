import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
class SkillSelectState extends Equatable {
  final List<Skill> selectedSkills;
  final int noOfSelected;
  SkillSelectState({this.selectedSkills = const [], this.noOfSelected});

  SkillSelectState addSkill(Skill skill) {
    final selected = <Skill>[]
      ..addAll(selectedSkills ?? [])
      ..add(skill);
    _sort(selected);
    return copyWith(
      selectedSkills: selected,
    );
  }

  void _sort(List<Skill> selected) {
    selected.sort((a, b) => a.name.compareTo(b.name));
  }

  SkillSelectState removeSite(Skill skill) {
    selectedSkills?.removeWhere((s) => s.id == skill.id);
    final selected = <Skill>[]..addAll(selectedSkills);
    _sort(selected);
    return copyWith(
      selectedSkills: selected,
    );
  }

  SkillSelectState copyWith({
    List<Skill> selectedSkills,
  }) =>
      SkillSelectState(
        selectedSkills: selectedSkills ?? this.selectedSkills,
        noOfSelected: selectedSkills != null
            ? selectedSkills.length
            : this.selectedSkills.length,
      );

  @override
  // TODO: implement props
  List<Object> get props => [
        selectedSkills,
        noOfSelected,
      ];
}
