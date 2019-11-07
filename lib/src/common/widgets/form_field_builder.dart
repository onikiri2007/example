import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'index.dart';

buildTextFormField({
  TextEditingController controller,
  FormFieldValidator<String> validator,
  TextInputType inputType = TextInputType.text,
  TextInputAction inputAction = TextInputAction.next,
  VoidCallback onEditingComplete,
  FocusNode focusNode,
  String hintText,
  Color color,
  bool isFormDirty = false,
  bool expands = false,
  int minLines,
  int maxLines,
  List<TextInputFormatter> inputFormatters,
  TextAlign textAlign = TextAlign.left,
}) {
  return TextFormField(
    controller: controller,
    autocorrect: false,
    maxLines: maxLines,
    autovalidate: isFormDirty,
    validator: validator,
    keyboardType: inputType,
    textInputAction: inputAction,
    focusNode: focusNode,
    onEditingComplete: onEditingComplete,
    inputFormatters: inputFormatters,
    textAlign: textAlign,
    decoration: InputDecoration(
      contentPadding:
          EdgeInsets.only(left: 11.0, top: 14.0, bottom: 14.0, right: 11.0),
      hintText: hintText,
      fillColor: color ?? Colors.white,
      filled: true,
      border: InputBorder.none,
    ),
  );
}

buildDatePickerField({
  Key key,
  TextEditingController controller,
  FormFieldValidator<DateTime> validator,
  InputType inputType = InputType.date,
  FocusNode focusNode,
  String hintText,
  DateTime initialDate,
  ValueChanged<DateTime> onChanged,
  DateFormat format,
  TextAlign align = TextAlign.left,
  bool isFormDirty = false,
  TextStyle style,
  DateTime firstDate,
  DateTime lastDate,
  Color fillColor = Colors.white,
}) {
  return DateTimePickerFormField(
    key: key,
    format: format ?? DateFormat("yyyy-MM-dd"),
    firstDate: firstDate,
    lastDate: lastDate,
    autocorrect: false,
    autovalidate: isFormDirty,
    controller: controller,
    editable: false,
    initialValue: initialDate,
    focusNode: focusNode,
    inputType: inputType,
    onChanged: onChanged,
    validator: validator,
    textAlign: align,
    style: style,
    decoration: InputDecoration(
      contentPadding:
          EdgeInsets.only(left: 11.0, top: 14.0, bottom: 14.0, right: 11.0),
      hintText: hintText,
      fillColor: fillColor,
      filled: true,
      border: InputBorder.none,
    ),
  );
}
