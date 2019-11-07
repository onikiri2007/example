import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yodel/src/theme/themes.dart';

import 'index.dart';

typedef WidgetPartBuilder<S> = Widget Function(BuildContext context, S source);

class ListTileItem<T> extends StatelessWidget {
  final T source;
  final bool isSelected;
  final bool isMultiSelect;
  final Function(T source, bool checked) onChange;
  final Function(T source) onRemove;
  final Color activeColor;
  final WidgetPartBuilder<T> titleBuilder;
  final WidgetPartBuilder<T> subtitleBuilder;
  final WidgetPartBuilder<T> leadingBuilder;
  final WidgetPartBuilder<T> trailingBuilder;
  final EdgeInsets contentPadding;
  final Color backgroundColor;

  ListTileItem({
    Key key,
    @required this.source,
    this.isSelected = false,
    this.isMultiSelect = false,
    this.onChange,
    this.onRemove,
    this.leadingBuilder,
    this.titleBuilder,
    this.subtitleBuilder,
    this.trailingBuilder,
    this.activeColor,
    this.contentPadding,
    this.backgroundColor,
  })  : assert(source != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      enabled: onRemove != null,
      secondaryActions: <Widget>[
        SlideAction(
          color: YodelTheme.destructionColor,
          child: Text("Remove", style: YodelTheme.caption),
          closeOnTap: true,
          onTap: () {
            if (onRemove != null) {
              onRemove(source);
            }
          },
        )
      ],
      delegate: SlidableDrawerDelegate(),
      child: Ink(
        color: backgroundColor ?? Colors.white,
        child: ListTile(
          contentPadding: contentPadding ??
              (isMultiSelect
                  ? EdgeInsets.only(top: 8.0, bottom: 8, right: 16, left: 8)
                  : EdgeInsets.symmetric(horizontal: 16.0, vertical: 8)),
          leading: isMultiSelect
              ? CircularCheckBox(
                  onChanged: onChange != null
                      ? (changed) {
                          onChange(source, changed);
                        }
                      : null,
                  value: isSelected,
                  activeColor: activeColor ?? YodelTheme.iris,
                )
              : leadingBuilder != null ? leadingBuilder(context, source) : null,
          title: titleBuilder != null ? titleBuilder(context, source) : null,
          subtitle:
              subtitleBuilder != null ? subtitleBuilder(context, source) : null,
          trailing:
              trailingBuilder != null ? trailingBuilder(context, source) : null,
          onTap: onChange != null
              ? () {
                  if (onChange != null) {
                    onChange(source, !isSelected);
                  }
                }
              : null,
        ),
      ),
    );
  }
}
