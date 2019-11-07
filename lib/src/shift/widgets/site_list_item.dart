import 'package:flutter/material.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class SiteItem extends StatelessWidget {
  final Site site;
  final bool multiSelect;
  final bool isSelected;
  final Function(Site site, bool selected) onChanged;
  final Function(Site site) onRemoved;
  final WidgetPartBuilder<Site> trailingBuilder;
  final WidgetPartBuilder<Site> leadingBuilder;
  final EdgeInsets contentPadding;
  final Color activeColor;
  final Color backgroundColor;

  SiteItem({
    @required this.site,
    this.multiSelect = false,
    this.isSelected = false,
    this.onChanged,
    this.onRemoved,
    this.leadingBuilder,
    this.trailingBuilder,
    this.contentPadding,
    this.activeColor,
    this.backgroundColor,
  }) : assert(site != null);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    if (!multiSelect && isSelected) {
      widgets.add(Container(
        width: 4,
        height: contentPadding != null
            ? 80 + contentPadding.top + contentPadding.bottom
            : 80.0 + 16.0,
        color: YodelTheme.iris,
      ));
    }

    widgets.add(Expanded(
      child: ListTileItem<Site>(
        backgroundColor: backgroundColor,
        activeColor: activeColor,
        isMultiSelect: multiSelect,
        contentPadding: this.contentPadding,
        isSelected: isSelected,
        leadingBuilder: (context, site) => SiteAvatarImage(
              site: site,
              size: 50,
            ),
        onChange: onChanged,
        onRemove: onRemoved,
        source: site,
        titleBuilder: (context, site) => Text(
              site.name,
              style: YodelTheme.bodyDefault,
              overflow: TextOverflow.ellipsis,
            ),
        subtitleBuilder: (context, site) => Text(site.address ?? "-",
            style: YodelTheme.metaDefault, overflow: TextOverflow.ellipsis),
        trailingBuilder: trailingBuilder,
      ),
    ));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }
}
