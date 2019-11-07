import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:yodel/src/common/widgets/index.dart';

class ToggleItem extends Equatable {
  int id;
  String text;
  bool isSelected;
  ToggleItem({
    @required this.id,
    @required this.text,
    this.isSelected = false,
  });

  @override
  // TODO: implement props
  List<Object> get props => [id, text];
}

class YodelToggleButton extends StatefulWidget {
  final Color selectedColor;
  final Color defaultColor;
  final TextStyle selectedStyle;
  final TextStyle defaultStyle;
  final ValueChanged<ToggleItem> onChanged;
  final List<ToggleItem> items;

  YodelToggleButton({
    @required this.items,
    @required this.selectedColor,
    @required this.defaultColor,
    @required this.selectedStyle,
    @required this.defaultStyle,
    this.onChanged,
  })  : assert(items != null && items.length >= 2,
            "items is required and must be at least 2 items"),
        assert(selectedColor != null),
        assert(defaultColor != null),
        assert(selectedStyle != null),
        assert(defaultStyle != null);

  @override
  _YodelToggleButtonState createState() => _YodelToggleButtonState();
}

class _YodelToggleButtonState extends State<YodelToggleButton> {
  ToggleItem selectedItem;

  @override
  void initState() {
    selectedItem =
        widget.items.firstWhere((item) => item.isSelected, orElse: () => null);
    super.initState();
  }

  Widget getButton(ToggleItem item, bool isSelected) {
    return isSelected
        ? SizedBox(
            width: double.infinity,
            height: 44,
            child: RaisedButton(
              color: widget.selectedColor,
              child: Text(item.text, style: widget.selectedStyle),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onPressed: () {},
            ),
          )
        : BorderButton(
            height: 44,
            borderColor: widget.defaultColor,
            borderWidth: 1,
            hasBorder: true,
            onPressed: () {
              setState(() {
                selectedItem = item;
                if (widget.onChanged != null) {
                  widget.onChanged(item);
                }
              });
            },
            child: Text(
              item.text,
              style: widget.defaultStyle,
            ),
          );
  }

  @override
  void didUpdateWidget(YodelToggleButton oldWidget) {
    if (oldWidget.items != widget.items) {
      selectedItem = widget.items
          .firstWhere((item) => item.isSelected, orElse: () => null);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];

    for (var i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      buttons.add(Expanded(
        child: getButton(item, selectedItem == item),
      ));

      if (i < widget.items.length - 1) {
        buttons.add(
          SizedBox(
            width: 8,
          ),
        );
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }
}
