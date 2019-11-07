import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/profile/index.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

enum ProfileMode { confirm, edit }

class ProfileDetailsForm extends StatefulWidget {
  final ProfileMode mode;
  final bool isEdit;
  final Function(UserData) onSubmit;
  final String buttonText;
  ProfileDetailsForm({
    Key key,
    this.isEdit = false,
    this.mode = ProfileMode.edit,
    this.onSubmit,
    this.buttonText = "Confirm details",
  }) : super(key: key);

  _ProfileDetailsFormState createState() => _ProfileDetailsFormState();
}

class _ProfileDetailsFormState extends State<ProfileDetailsForm>
    with PostBuildActionMixin {
  ProfileBloc _bloc;
  final formkey = GlobalKey<FormState>();

  TextEditingController firstNameController;
  TextEditingController lastNameController;
  TextEditingController phoneNumberController;
  TextEditingController emailController;
  final emailFocusNode = FocusNode();
  final firstNameFocusNode = FocusNode();
  final lastNameFocusNode = FocusNode();
  final phoneNumberFocusNode = FocusNode();
  final dateOfBirthFocusNode = FocusNode();
  DateTime _dateOfBirth;
  final format = DateFormat("dd MMMM yyyy");

  @override
  void initState() {
    _bloc = BlocProvider.of<ProfileBloc>(context);
    firstNameController =
        TextEditingController(text: _bloc.initialState.profile?.firstName);
    lastNameController =
        TextEditingController(text: _bloc.initialState.profile?.lastName);
    phoneNumberController =
        TextEditingController(text: _bloc.initialState.profile?.phone);
    emailController =
        TextEditingController(text: _bloc.initialState.profile?.email);
    _dateOfBirth =
        DateTime.tryParse(_bloc.initialState.profile?.dateOfBirth ?? "");

    phoneNumberController.addListener(() {
      if (phoneNumberController.text.length > 10) {
        phoneNumberController.text =
            phoneNumberController.text.substring(0, 10);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    emailFocusNode.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    phoneNumberFocusNode.dispose();
    dateOfBirthFocusNode.dispose();

    super.dispose();
  }

  ProfileMode get mode => widget.mode;
  bool get isEdit => widget.isEdit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: _bloc,
        builder: (context, ProfileState state) {
          final profile = state.profile;
          return FormKeyboardActions(
            actions: [
              KeyboardAction(
                  focusNode: phoneNumberFocusNode,
                  closeWidget: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("Done"),
                  ))
            ],
            keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  child: Form(
                    key: formkey,
                    child: Column(
                      children: <Widget>[
                        if (!isEdit)
                          SectionHeader(
                            child: Text(
                              "Personal Details",
                              style: YodelTheme.metaRegular,
                            ),
                          ),
                        if (!isEdit)
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text("First name",
                                style: YodelTheme.metaRegularInactive),
                            subtitle: Text(
                              profile.firstName,
                              style: YodelTheme.bodyDefault.copyWith(
                                color: YodelTheme.darkGreyBlue,
                              ),
                            ),
                          ),
                        if (isEdit)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: AnimatedBuilder(
                                animation: firstNameFocusNode,
                                builder: (context, child) {
                                  return TextFormField(
                                    controller: firstNameController,
                                    focusNode: firstNameFocusNode,
                                    autocorrect: false,
                                    autovalidate: true,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "First name is required";
                                      }
                                      return null;
                                    },
                                    cursorColor: YodelTheme.lightGreyBlue,
                                    textInputAction: TextInputAction.next,
                                    style: YodelTheme.bodyDefault.copyWith(
                                      color: YodelTheme.darkGreyBlue,
                                    ),
                                    onEditingComplete: () =>
                                        FocusScope.of(context)
                                            .requestFocus(lastNameFocusNode),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 16),
                                      labelStyle: firstNameFocusNode.hasFocus
                                          ? YodelTheme.bodyActive.copyWith(
                                              color: YodelTheme.iris,
                                            )
                                          : YodelTheme.bodyInactive,
                                      labelText: "First name",
                                      hintStyle: YodelTheme.bodyInactive,
                                      hintText: "First name",
                                      alignLabelWithHint: true,
                                    ),
                                  );
                                }),
                          ),
                        Separator(),
                        if (!isEdit)
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text("Last name",
                                style: YodelTheme.metaRegularInactive),
                            subtitle: Text(
                              profile.lastName,
                              style: YodelTheme.bodyDefault.copyWith(
                                color: YodelTheme.darkGreyBlue,
                              ),
                            ),
                          ),
                        if (isEdit)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: AnimatedBuilder(
                                animation: lastNameFocusNode,
                                builder: (context, child) {
                                  return TextFormField(
                                    controller: lastNameController,
                                    focusNode: lastNameFocusNode,
                                    autocorrect: false,
                                    autovalidate: true,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Last name is required";
                                      }
                                      return null;
                                    },
                                    cursorColor: YodelTheme.lightGreyBlue,
                                    textInputAction: TextInputAction.next,
                                    style: YodelTheme.bodyDefault.copyWith(
                                      color: YodelTheme.darkGreyBlue,
                                    ),
                                    onEditingComplete: () =>
                                        FocusScope.of(context)
                                            .requestFocus(phoneNumberFocusNode),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 16),
                                      labelStyle: lastNameFocusNode.hasFocus
                                          ? YodelTheme.bodyActive.copyWith(
                                              color: YodelTheme.iris,
                                            )
                                          : YodelTheme.bodyInactive,
                                      labelText: "Last name",
                                      hintStyle: YodelTheme.bodyInactive,
                                      hintText: "Last name",
                                      alignLabelWithHint: true,
                                    ),
                                  );
                                }),
                          ),
                        Separator(),
                        if (!isEdit)
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text("Phone number",
                                style: YodelTheme.metaRegularInactive),
                            subtitle: Text(
                              profile.phone ?? "-",
                              style: YodelTheme.bodyDefault.copyWith(
                                color: YodelTheme.darkGreyBlue,
                              ),
                            ),
                          ),
                        if (isEdit)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: TextFormField(
                              controller: phoneNumberController,
                              focusNode: phoneNumberFocusNode,
                              autocorrect: false,
                              autovalidate: true,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Phone number is required";
                                }

                                return null;
                              },
                              keyboardType: TextInputType.phone,
                              cursorColor: YodelTheme.lightGreyBlue,
                              textInputAction: TextInputAction.next,
                              style: YodelTheme.bodyDefault.copyWith(
                                color: YodelTheme.darkGreyBlue,
                              ),
                              onEditingComplete: () => FocusScope.of(context)
                                  .requestFocus(emailFocusNode),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(16),
                                labelStyle: phoneNumberFocusNode.hasFocus
                                    ? YodelTheme.bodyActive.copyWith(
                                        color: YodelTheme.iris,
                                      )
                                    : YodelTheme.bodyInactive,
                                labelText: "Phone number",
                                hintStyle: YodelTheme.bodyInactive,
                                hintText: "Phone number",
                                alignLabelWithHint: true,
                              ),
                            ),
                          ),
                        Separator(),
                        if (!isEdit)
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text("Email address",
                                style: YodelTheme.metaRegularInactive),
                            subtitle: Text(
                              profile.email,
                              style: YodelTheme.bodyDefault.copyWith(
                                color: YodelTheme.darkGreyBlue,
                              ),
                            ),
                          ),
                        if (isEdit)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: AnimatedBuilder(
                                animation: emailFocusNode,
                                builder: (context, child) {
                                  return TextFormField(
                                    controller: emailController,
                                    focusNode: emailFocusNode,
                                    autocorrect: false,
                                    autovalidate: true,
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Email is required";
                                      }

                                      if (!EmailValidator.validate(val)) {
                                        return "Please enter correct email address";
                                      }

                                      return null;
                                    },
                                    cursorColor: YodelTheme.lightGreyBlue,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.newline,
                                    style: YodelTheme.bodyDefault.copyWith(
                                      color: YodelTheme.darkGreyBlue,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(16),
                                      labelStyle: emailFocusNode.hasFocus
                                          ? YodelTheme.bodyActive.copyWith(
                                              color: YodelTheme.iris,
                                            )
                                          : YodelTheme.bodyInactive,
                                      labelText: "Email address",
                                      hintStyle: YodelTheme.bodyInactive,
                                      hintText: "Email address",
                                      alignLabelWithHint: true,
                                    ),
                                  );
                                }),
                          ),
                        Separator(),
                        if (!isEdit || mode == ProfileMode.edit)
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text("Date of birth",
                                style: YodelTheme.metaRegularInactive),
                            subtitle: Text(
                              profile?.dateOfBirth != null
                                  ? format.format(
                                      DateTime.tryParse(profile.dateOfBirth))
                                  : "-",
                              style: YodelTheme.bodyDefault.copyWith(
                                color: YodelTheme.darkGreyBlue,
                              ),
                            ),
                          ),
                        if (isEdit && mode == ProfileMode.confirm)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: DateTimePickerFormField(
                              resetIcon: null,
                              editable: false,
                              focusNode: dateOfBirthFocusNode,
                              autocorrect: false,
                              initialDate: _dateOfBirth ?? DateTime(1900, 1, 1),
                              initialValue: _dateOfBirth,
                              inputType: InputType.date,
                              format: format,
                              lastDate:
                                  DateTimeHelper.toDateOnly(DateTime.now()),
                              style: YodelTheme.bodyDefault.copyWith(
                                color: YodelTheme.darkGreyBlue,
                              ),
                              onChanged: (d) => setState(() {
                                _dateOfBirth = d;
                              }),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(16),
                                labelStyle: dateOfBirthFocusNode.hasFocus
                                    ? YodelTheme.bodyActive.copyWith(
                                        color: YodelTheme.iris,
                                      )
                                    : YodelTheme.bodyInactive,
                                labelText: "Date of birth",
                                hintStyle: YodelTheme.bodyInactive,
                                hintText: "Date of birth",
                                alignLabelWithHint: true,
                              ),
                            ),
                          ),
                        SectionHeader(
                          padding: const EdgeInsets.only(top: 8),
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.all(16),
                          child: ProgressButton(
                            width: double.infinity,
                            height: 60,
                            color: YodelTheme.amber,
                            isLoading: state is ProfileUpdating,
                            onPressed: () {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              _submitForm(profile: profile);
                            },
                            child: Text(
                              widget.buttonText,
                              style: YodelTheme.bodyStrong,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        });
  }

  void _submitForm({UserData profile}) {
    if (formkey.currentState.validate()) {
      if (widget.onSubmit != null) {
        final _profile = UserData(
          dateOfBirth: _dateOfBirth != null
              ? DateFormat("yyyy-MM-dd").format(_dateOfBirth)
              : null,
          email: emailController.text,
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          phone: phoneNumberController.text,
        );
        widget.onSubmit(widget.isEdit ? _profile : profile);
      }
    }
  }
}
