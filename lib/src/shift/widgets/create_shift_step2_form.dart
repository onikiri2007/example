import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/home/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class CreateShiftStep2Form extends StatefulWidget {
  final CreateShiftStep2FormBloc formBloc;

  CreateShiftStep2Form({
    Key key,
    @required this.formBloc,
  }) : super(key: key);

  _CreateShiftStep2FormState createState() => _CreateShiftStep2FormState();
}

class _CreateShiftStep2FormState extends State<CreateShiftStep2Form> {
  CreateShiftBloc _bloc;
  CompanyBloc _companyBloc;
  TextEditingController noOfPeopleController;
  final noOfPeopleFocusNode = FocusNode();
  final GlobalKey<AnimatedItemListState> _skillListKey = GlobalKey();
  final GlobalKey<AnimatedItemListState> _siteListKey = GlobalKey();
  CreateShiftStep2FormBloc get _formBloc => widget.formBloc;

  @override
  void initState() {
    noOfPeopleController =
        TextEditingController(text: "${_formBloc.currentHeadCountRequired}");
    super.initState();
  }

  @override
  void dispose() {
    noOfPeopleController.dispose();
    noOfPeopleFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<CreateShiftBloc>(context);
    _companyBloc = BlocProvider.of<CompanyBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FormKeyboardActions(
      actions: [
        KeyboardAction(
            focusNode: noOfPeopleFocusNode,
            closeWidget: Padding(
              padding: EdgeInsets.all(8),
              child: Text("Done"),
            ))
      ],
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      child: ListView(
        children: <Widget>[
          SectionHeader(
            child: Text(
              "Shift role",
              style: YodelTheme.metaRegular,
            ),
          ),
          StreamBuilder<Duty>(
              initialData: _formBloc.selectedRole,
              stream: _formBloc.shiftRole,
              builder: (context, snapshot) {
                return Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.white,
                  child: ToggleItemDropdown(
                    items: _companyBloc.company.sortedDuties
                        .map((duty) => ToggleItem(
                              id: duty.id,
                              text: duty.name,
                              isSelected: snapshot.hasData &&
                                  snapshot.data.id == duty.id,
                            ))
                        .toList(),
                    onChanged: (item) {
                      final duty = _companyBloc.company.sortedDuties.firstWhere(
                          (d) => d.id == item.id,
                          orElse: () => null);
                      _formBloc.selectRole(duty);
                    },
                  ),
                );
              }),
          SectionHeader(
            child: Text(
              "How many people do you need?",
              style: YodelTheme.metaRegular,
            ),
          ),
          StreamBuilder<int>(
              initialData: _formBloc.currentHeadCountRequired,
              stream: _formBloc.headCount,
              builder: (context, snapshot) {
                return Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.white,
                  child: NumberStepper(
                      min: 1,
                      highlightColor: YodelTheme.iris,
                      onChanged: _formBloc.onHeadCountChanged,
                      buttonColor: YodelTheme.lightIris,
                      iconColor: YodelTheme.iris,
                      splashColor: YodelTheme.iris,
                      focusNode: noOfPeopleFocusNode,
                      controller: noOfPeopleController),
                );
              }),
          SectionHeader(
            child: Text(
              "Find people from",
              style: YodelTheme.metaRegular,
            ),
          ),
          StreamBuilder<List<Site>>(
              initialData: _formBloc.selectedSites,
              stream: _formBloc.sites,
              builder: (context, snapshot) {
                return AnimatedItemList(
                  key: _siteListKey,
                  initialItemCount: snapshot.data.length,
                  onRemoved: (index) {
                    _formBloc.removeSite(snapshot.data[index]);
                  },
                  itemBuilder: (context, index, animation) {
                    final trailBuilder = (context, site) {
                      if (_formBloc.step1FormBloc.currentLocation.id ==
                          site.id) {
                        return Container(
                          width: 120,
                          alignment: Alignment.centerRight,
                          child: LinkButton(
                            highlightStyle:
                                YodelTheme.metaRegularManage.copyWith(
                              color: YodelTheme.darkGreyBlue.withOpacity(0.8),
                            ),
                            style: YodelTheme.metaRegularManage,
                            child: Text(
                              "Shift location",
                              textAlign: TextAlign.right,
                            ),
                            onPressed: () async {
                              final url = UrlHelper.getMapUrl(
                                  address: site.address,
                                  lat: site.latitude,
                                  long: site.longitude);
                              if (await canLaunch(url)) {
                                await launch(url);
                              }
                            },
                          ),
                        );
                      } else {
                        final distance = site.distanceFrom(
                            _formBloc.step1FormBloc.currentLocation.latitude,
                            _formBloc.step1FormBloc.currentLocation.longitude);
                        return Text(
                          distance != null ? "${distance}km" : "",
                          style: YodelTheme.metaDefaultInactive,
                          textAlign: TextAlign.right,
                        );
                      }
                    };

                    return [
                      SiteItem(
                        trailingBuilder: trailBuilder,
                        site: snapshot.data[index],
                        multiSelect: false,
                        onRemoved: (site) {
                          _siteListKey.currentState.removeItem(index,
                              (context, animation) {
                            return [
                              SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.vertical,
                                child: SiteItem(
                                  trailingBuilder: trailBuilder,
                                  site: site,
                                  multiSelect: false,
                                ),
                              ),
                              Separator(),
                            ];
                          });
                        },
                      ),
                      Separator(),
                    ];
                  },
                );
              }),
          StreamBuilder<List<Site>>(
              initialData: _formBloc.selectedSites,
              stream: _formBloc.sites,
              builder: (context, snapshot) {
                return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () async {
                    var sites = await Navigator.of(context)
                        .push<List<Site>>(MaterialPageRoute(
                            builder: (context) => SiteSearchScreen(
                                  header: Text(
                                    "Select sites to find people for this shift",
                                    style: YodelTheme.metaRegular,
                                  ),
                                  title: Text(
                                    "Find People From",
                                    style: YodelTheme.titleWhite,
                                  ),
                                  multiSelect: true,
                                  mode: SiteSelectionMode.ShiftLocation,
                                  location:
                                      _formBloc.step1FormBloc.currentLocation,
                                  selected: snapshot.data,
                                )));
                    if (sites != null && sites.length > 0) {
                      _formBloc.addSites(sites);
                    }
                  },
                  leading: Container(
                    width: 200,
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          YodelIcons.add,
                          size: 18.0,
                          color: YodelTheme.iris,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text("Add site", style: YodelTheme.bodyActive),
                      ],
                    ),
                  ),
                );
              }),
          SectionHeader(
            child: Text(
              "Skills required",
              style: YodelTheme.metaRegular,
            ),
          ),
          StreamBuilder<List<Skill>>(
              initialData: _formBloc.selectedSkills,
              stream: _formBloc.skills,
              builder: (context, snapshot) {
                return AnimatedItemList(
                  key: _skillListKey,
                  initialItemCount: snapshot.data.length,
                  onRemoved: (index) {
                    _formBloc.removeSkill(snapshot.data[index]);
                  },
                  itemBuilder: (context, index, animation) {
                    return [
                      SkillItem(
                        skill: snapshot.data[index],
                        multiSelect: false,
                        onRemoved: (skill) {
                          _skillListKey.currentState.removeItem(index,
                              (context, animation) {
                            return [
                              SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.vertical,
                                child: SkillItem(
                                  skill: skill,
                                  multiSelect: false,
                                ),
                              ),
                              Separator(),
                            ];
                          });
                        },
                      ),
                      Separator(),
                    ];
                  },
                );
              }),
          StreamBuilder<List<Skill>>(
              initialData: _formBloc.selectedSkills,
              stream: _formBloc.skills,
              builder: (context, snapshot) {
                return ListTile(
                  onTap: () async {
                    var skills = await Navigator.of(context)
                        .push<List<Skill>>(MaterialPageRoute(
                            builder: (context) => SkillSearchScreen(
                                  multiSelect: true,
                                  selectedSkills: snapshot.data,
                                  role: _formBloc.selectedRole,
                                  title: Text(
                                    "Select Skills",
                                    style: YodelTheme.titleWhite,
                                  ),
                                )));
                    if (skills != null) {
                      _formBloc.addSkills(skills);
                    }
                  },
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 200,
                    height: 50,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          YodelIcons.add,
                          size: 18.0,
                          color: YodelTheme.iris,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text("Add skill", style: YodelTheme.bodyActive),
                      ],
                    ),
                  ),
                );
              }),
          SectionHeader(
            padding: const EdgeInsets.only(top: 8),
          ),
          Container(
            height: 130,
          ),
        ],
      ),
    );
  }
}

class ToggleItemDropdown extends StatelessWidget {
  ToggleItemDropdown({
    this.items,
    this.onChanged,
  }) : assert(items != null && items.length >= 2);

  @required
  final List<ToggleItem> items;
  final void Function(ToggleItem item) onChanged;

  @override
  Widget build(BuildContext context) {
    if (items.length > 2) {
      final dropdowns = items.map((item) {
        final widget = DropdownMenuItem<ToggleItem>(
          child: Text(item.text, style: YodelTheme.bodyActive),
          value: item,
        );
        return widget;
      }).toList();

      final value =
          items.firstWhere((item) => item.isSelected, orElse: () => null);
      return DropdownButtonFormField(
        items: dropdowns,
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        ),
      );
    } else {
      return YodelToggleButton(
        defaultColor: YodelTheme.iris,
        defaultStyle: YodelTheme.toggleButtonTextNotSelected,
        selectedColor: YodelTheme.iris,
        selectedStyle: YodelTheme.bodyWhite,
        onChanged: onChanged,
        items: items,
      );
    }
  }
}
