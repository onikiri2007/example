import 'package:flutter/material.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/theme/themes.dart';

class SkillItem extends StatelessWidget {
  final Skill skill;
  final bool multiSelect;
  final bool isSelected;
  final Function(Skill skill, bool selected) onChanged;
  final Function(Skill skill) onRemoved;
  final EdgeInsets contentPadding;
  final Color activeColor;
  final Color backgroundColor;

  SkillItem({
    Key key,
    @required this.skill,
    this.isSelected = false,
    this.multiSelect = false,
    this.onChanged,
    this.onRemoved,
    this.contentPadding,
    this.activeColor,
    this.backgroundColor,
  })  : assert(skill != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTileItem<Skill>(
      backgroundColor: backgroundColor,
      contentPadding: contentPadding,
      activeColor: activeColor,
      isMultiSelect: multiSelect,
      isSelected: isSelected,
      onChange: onChanged,
      onRemove: onRemoved,
      source: skill,
      titleBuilder: (context, skll) => Text(
            skll.name,
            style: YodelTheme.bodyDefault,
          ),
    );
  }
}
