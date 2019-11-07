import 'package:flutter/material.dart';

class EditableField extends StatelessWidget {
  final Widget readonlyChild;
  final Widget editableChild;
  final bool isEditable;

  EditableField({
    Key key,
    this.isEditable = false,
    @required this.readonlyChild,
    @required this.editableChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      child: isEditable ? editableChild : readonlyChild,
      duration: Duration(milliseconds: 250),
    );
  }
}
