import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class SkillSearchScreen extends StatefulWidget {
  final bool multiSelect;
  final List<Skill> selectedSkills;
  final Widget title;
  final Duty role;
  SkillSearchScreen({
    Key key,
    this.title,
    this.multiSelect = false,
    this.role,
    this.selectedSkills = const [],
  }) : super(key: key);
  _SkillSearchScreenState createState() => _SkillSearchScreenState();
}

class _SkillSearchScreenState extends State<SkillSearchScreen> {
  TextEditingController searchTextController;
  SkillSearchBloc _bloc;
  SkillSelectBloc _selectBloc;

  @override
  void initState() {
    searchTextController = TextEditingController();
    _selectBloc = SkillSelectBloc(
      selectedSkills: widget.selectedSkills,
    );

    _bloc = SkillSearchBloc(
      currentRole: widget.role,
    );
    _bloc.add(SkillSearchStarted());
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    _bloc.dispose();
    _selectBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: KeyboardDismissable(
        child: Scaffold(
          backgroundColor: YodelTheme.lightPaleGrey,
          appBar: AppBar(
            title: widget.title,
            centerTitle: true,
            leading: OverflowBox(
              maxWidth: 90.0,
              child: NavbarButton(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  "Back",
                ),
                onPressed: () {
                  Navigator.pop(
                      context, _selectBloc.initialState.selectedSkills);
                },
              ),
            ),
            automaticallyImplyLeading: false,
            bottom: PreferredSize(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchField(
                  autofocus: false,
                  onQueryChanged: (val) {
                    _bloc.add(
                      SearchSkills(
                        query: val,
                      ),
                    );
                  },
                  onClear: () {
                    _bloc.add(SearchSkills(query: ""));
                  },
                  controller: searchTextController,
                  hintText: "Search",
                ),
              ),
              preferredSize: Size.fromHeight(66),
            ),
            actions: widget.multiSelect
                ? <Widget>[
                    BlocBuilder(
                      bloc: _selectBloc,
                      builder: (context, SkillSelectState state) {
                        return NavbarButton(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Text(
                            "Done",
                          ),
                          onPressed: () {
                            Navigator.pop(context, state.selectedSkills);
                          },
                        );
                      },
                    )
                  ]
                : null,
          ),
          body: BlocBuilder(
            bloc: _bloc,
            builder: (context, SkillSearchState state) {
              if (state is SkillSearchNoTerm) {
                return LoadingIndicator();
              }

              return _buildSearchResults(state);
            },
          ),
        ),
      ),
    );
  }

  _buildSearchResults(SkillSearchState searchState) {
    if (searchState is SkillSearchSuccess) {
      return BlocBuilder(
        bloc: _selectBloc,
        builder: (context, SkillSelectState state) {
          final skills = searchState.skills;
          final selected = state.selectedSkills.map((s) => s.id).toList();
          return ListView.separated(
            separatorBuilder: (context, i) => Container(
              width: double.infinity,
              height: 1,
              color: YodelTheme.paleGrey,
            ),
            itemCount: skills.length,
            itemBuilder: (context, i) {
              final child = SkillItem(
                multiSelect: widget.multiSelect,
                isSelected: selected.contains(skills[i].id),
                onChanged: (skill, selected) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  if (!widget.multiSelect) {
                    Navigator.of(context).maybePop([skill]);
                  } else {
                    _selectBloc.add(
                        SelectSkill(skill: skill, isSelected: selected));
                  }
                },
                skill: skills[i],
              );

              if (i == skills.length - 1) {
                return Column(
                  children: <Widget>[
                    child,
                    SectionHeader(
                      padding: const EdgeInsets.only(top: 8),
                    ),
                  ],
                );
              }

              return child;
            },
          );
        },
      );
    }

    if (searchState is SkillSearchError) {
      return ErrorView(error: searchState.error);
    }

    if (searchState is SkillSearchLoading) {
      return LoadingIndicator();
    }

    return Container();
  }
}
