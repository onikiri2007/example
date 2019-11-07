import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/shift/index.dart';
import './bloc.dart';

class SkillSelectBloc extends Bloc<SkillSelectEvent, SkillSelectState>
    implements BlocBase {
  final List<Skill> selectedSkills;
  SkillSelectBloc({
    this.selectedSkills = const [],
  });

  @override
  SkillSelectState get initialState => SkillSelectState(
        selectedSkills: List.from(selectedSkills),
        noOfSelected: selectedSkills.length,
      );

  @override
  Stream<SkillSelectState> mapEventToState(
    SkillSelectEvent event,
  ) async* {
    if (event is SelectSkill) {
      if (event.isSelected) {
        yield state.addSkill(event.skill);
      } else {
        yield state.removeSite(event.skill);
      }
    }
  }

  @override
  void dispose() {
    this.close();
  }
}
