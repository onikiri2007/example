import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class CreateShiftStep1Form extends StatefulWidget {
  final CreateShiftStep1FormBloc formBloc;
  CreateShiftStep1Form({
    Key key,
    @required this.formBloc,
  }) : super(key: key);

  _CreateShiftStep1FormState createState() => _CreateShiftStep1FormState();
}

class _CreateShiftStep1FormState extends State<CreateShiftStep1Form> {
  CreateShiftBloc _bloc;

  TextEditingController shiftNameController;
  TextEditingController descriptionController;
  var shiftNameFocusNode = FocusNode();
  var startDateFocusNode = FocusNode();
  var endDateFocusNode = FocusNode();
  var descriptionFocusNode = FocusNode();
  var startDatePickerFocusNode = DateTimePickerFocusNode();
  var endDatePickerFocusNode = DateTimePickerFocusNode();

  CreateShiftStep1FormBloc get _formBloc => widget.formBloc;

  @override
  void initState() {
    shiftNameController = TextEditingController(text: _formBloc.currentName);
    descriptionController =
        TextEditingController(text: _formBloc.currentDescription);

    super.initState();
  }

  @override
  void dispose() {
    shiftNameController.dispose();
    descriptionController.dispose();
    shiftNameFocusNode.dispose();
    startDateFocusNode.dispose();
    endDateFocusNode.dispose();
    descriptionFocusNode.dispose();
    startDatePickerFocusNode.dispose();
    endDatePickerFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _bloc = BlocProvider.of<CreateShiftBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FormKeyboardActions(
      actions: [
        KeyboardAction(
            focusNode: descriptionFocusNode,
            closeWidget: Padding(
              padding: EdgeInsets.all(8),
              child: Text("Done"),
            ))
      ],
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 4),
                      child: StreamBuilder(
                        stream: _formBloc.shiftName,
                        builder: (context, snapshot) {
                          return TextField(
                            style: YodelTheme.bodyDefault,
                            onChanged: _formBloc.onNameChanged,
                            focusNode: shiftNameFocusNode,
                            controller: shiftNameController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              labelStyle: shiftNameFocusNode.hasFocus
                                  ? YodelTheme.bodyActive.copyWith(
                                      color: YodelTheme.iris,
                                    )
                                  : YodelTheme.bodyInactive,
                              labelText: "Shift name",
                              hintStyle: YodelTheme.bodyInactive,
                              hintText: "Shift name",
                              alignLabelWithHint: true,
                              errorStyle: YodelTheme.errorText,
                              errorText:
                                  snapshot.hasError ? snapshot.error : null,
                            ),
                          );
                        },
                      ),
                    ),
                    SectionHeader(
                      child: Text(
                        "Shift details",
                        style: YodelTheme.metaRegular,
                      ),
                    ),
                    StreamBuilder<DateTime>(
                        initialData: _formBloc.currentStartDate,
                        stream: _formBloc.startDate,
                        builder: (context, snapshot) {
                          return YodelDateTimePicker(
                            pickerFocusNode: startDatePickerFocusNode,
                            focusNode: startDateFocusNode,
                            initialDate: snapshot.data,
                            initialValue: snapshot.data,
                            style: YodelTheme.bodyDefault,
                            contentPadding: EdgeInsets.only(
                                left: 0, right: 0, top: 10, bottom: 10),
                            inputType: InputType.both,
                            format: DateFormat("EE dd MMM yyyy HH:mm"),
                            align: TextAlign.right,
                            firstDate:
                                DateTimeHelper.toDateOnly(DateTime.now()),
                            lastDate: DateTimeHelper.toDateOnly(
                                DateTime.now().add(Duration(days: 360))),
                            onChanged: _formBloc.onStartDateChanged,
                            focusLabelStyle: YodelTheme.bodyActive,
                            labelStyle: YodelTheme.bodyInactive,
                            labelText: "Starts",
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              errorText:
                                  snapshot.hasError ? snapshot.error : null,
                            ),
                          );
                        }),
                    SectionHeader(
                      child: Container(),
                    ),
                    StreamBuilder<DateTime>(
                        initialData: _formBloc.currentEndDate,
                        stream: _formBloc.endDate,
                        builder: (context, snapshot) {
                          return StreamBuilder<DateTime>(
                              initialData: _formBloc.currentStartDate,
                              stream: _formBloc.startDate,
                              builder: (context, snapshot1) {
                                return YodelDateTimePicker(
                                  pickerFocusNode: endDatePickerFocusNode,
                                  enabled: snapshot1.hasData,
                                  initialDate: snapshot1.data,
                                  initialValue: snapshot.data,
                                  focusNode: endDateFocusNode,
                                  style: YodelTheme.bodyDefault,
                                  contentPadding: EdgeInsets.only(
                                      left: 0, right: 0, top: 10, bottom: 10),
                                  inputType: InputType.both,
                                  format: DateFormat("EE dd MMM yyyy HH:mm"),
                                  align: TextAlign.right,
                                  firstDate:
                                      DateTimeHelper.toDateOnly(DateTime.now()),
                                  lastDate: DateTimeHelper.toDateOnly(
                                      DateTime.now().add(Duration(days: 360))),
                                  onChanged: _formBloc.onEndDateChanged,
                                  focusLabelStyle: YodelTheme.bodyActive,
                                  labelStyle: YodelTheme.bodyInactive,
                                  labelText: "Ends",
                                  decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      errorText: snapshot.hasError
                                          ? snapshot.error
                                          : null),
                                );
                              });
                        }),
                    SectionHeader(
                      child: Container(),
                    ),
                    StreamBuilder<Site>(
                        initialData: _formBloc.currentLocation,
                        stream: _formBloc.location,
                        builder: (context, snapshot) {
                          return Container(
                            height: 76,
                            color: Colors.white,
                            alignment: Alignment.centerLeft,
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              leading: SizedBox(
                                width: 100,
                                child: Text("Location",
                                    style: YodelTheme.bodyInactive),
                              ),
                              title: Text(
                                snapshot.hasData ? snapshot.data.name : "",
                                style: YodelTheme.bodyDefault,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                              onTap: () async {
                                var sites = await Navigator.of(context)
                                    .push<List<Site>>(MaterialPageRoute(
                                        builder: (context) => SiteSearchScreen(
                                              header: Text(
                                                "Select shift location",
                                                style: YodelTheme.metaRegular,
                                              ),
                                              selected: [snapshot.data],
                                              title: Text(
                                                "Shift location",
                                                style: YodelTheme.titleWhite,
                                              ),
                                            )));
                                if (sites != null && sites.length > 0) {
                                  _formBloc.onLocationChanged(sites[0]);
                                }
                              },
                            ),
                          );
                        }),
                    SectionHeader(
                      child: Text(
                        "Additional information",
                        style: YodelTheme.metaRegular,
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 16),
                      child: StreamBuilder(
                        stream: _formBloc.description,
                        builder: (context, snapshot) {
                          return TextField(
                            maxLines: 6,
                            expands: false,
                            maxLength: 1000,
                            style: YodelTheme.bodyDefault,
                            controller: descriptionController,
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,
                            onChanged: _formBloc.onDescriptionChanged,
                            focusNode: descriptionFocusNode,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 16, right: 16, bottom: 16, top: 0),
                              labelStyle: descriptionFocusNode.hasFocus
                                  ? YodelTheme.bodyActive.copyWith(
                                      color: YodelTheme.iris,
                                    )
                                  : YodelTheme.bodyInactive,
                              labelText: "Description (Optional)",
                              hintStyle: YodelTheme.bodyInactive,
                              hintText: "Description (Optional)",
                              alignLabelWithHint: true,
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      height: 120,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class YodelDateTimePicker extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<DateTime> validator;
  final InputType inputType;
  final FocusNode focusNode;
  final DateTime initialDate;
  final ValueChanged<DateTime> onChanged;
  final DateFormat format;
  final TextAlign align;
  final bool validate;
  final DateTime firstDate;
  final DateTime lastDate;
  final InputDecoration decoration;
  final TextStyle style;
  final EdgeInsets contentPadding;
  final TextStyle focusLabelStyle;
  final TextStyle labelStyle;
  final String labelText;
  final bool enabled;
  final DateTime initialValue;
  final DateTimePickerFocusNode pickerFocusNode;

  YodelDateTimePicker({
    Key key,
    this.controller,
    this.validator,
    this.inputType = InputType.date,
    @required this.focusNode,
    this.initialDate,
    this.onChanged,
    this.format,
    this.align = TextAlign.left,
    this.validate: false,
    this.firstDate,
    this.lastDate,
    this.decoration,
    this.style,
    this.contentPadding,
    this.labelText,
    this.labelStyle,
    this.focusLabelStyle,
    this.enabled = true,
    this.initialValue,
    this.pickerFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: decoration.fillColor,
      padding: contentPadding,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(focusNode);
        },
        child: Stack(
          children: <Widget>[
            AnimatedBuilder(
                animation: pickerFocusNode,
                builder: (context, child) {
                  return Container(
                    height: 50,
                    padding: EdgeInsets.only(left: 16),
                    alignment: Alignment.centerLeft,
                    color: Colors.white,
                    child: labelText != null
                        ? Text(labelText,
                            style: pickerFocusNode.hasFocus
                                ? focusLabelStyle
                                : labelStyle)
                        : null,
                  );
                }),
            DateTimePickerFormField(
              key: key,
              resetIcon: null,
              format: format ?? DateFormat("yyyy-MM-dd"),
              firstDate: firstDate,
              lastDate: lastDate,
              autocorrect: false,
              autovalidate: false,
              editable: false,
              focusNode: focusNode,
              inputType: inputType,
              onChanged: onChanged,
              validator: validator,
              textAlign: align,
              initialDate: initialDate,
              style: style,
              decoration: decoration,
              initialValue: initialValue,
              minuteInterval: 15,
              pickerFocusNode: pickerFocusNode,
            ),
          ],
        ),
      ),
    );
  }
}
