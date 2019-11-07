import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/forgot_password/index.dart';
import 'package:yodel/src/theme/themes.dart';

class ForgotPasswordForm extends StatefulWidget {
  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final formkey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  bool _isFormDirty = false;
  ForgotPasswordBloc _bloc;
  FocusNode emailFocusNode = FocusNode();

  @override
  void initState() {
    _bloc = BlocProvider.of<ForgotPasswordBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SvgPicture.asset(
              YodelImages.logo,
              fit: BoxFit.cover,
              color: YodelTheme.tealish,
              width: 120,
              height: 120,
            ),
            SizedBox(
              height: 20.0,
            ),
            Center(
              child: Text(
                "Request to reset your password",
                style: YodelTheme.bodyWhite,
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            _buildForm()
          ],
        ),
      ),
    );
  }

  _buildForm() {
    return Form(
      key: formkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildEmailField(),
          SizedBox(
            height: 20.0,
          ),
          BlocBuilder(
              bloc: _bloc,
              builder: (context, ForgotPasswordState state) {
                return ProgressButton(
                  width: double.infinity,
                  height: 60,
                  isLoading: state is ForgotPasswordLoading,
                  color: YodelTheme.amber,
                  onPressed: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _submitForm();
                  },
                  child: Text(
                    "Submit",
                    style: YodelTheme.bodyStrong,
                  ),
                );
              }),
        ],
      ),
    );
  }

  _buildEmailField() {
    return TextFormField(
      key: ValueKey("email"),
      controller: emailController,
      autocorrect: false,
      autovalidate: _isFormDirty,
      focusNode: emailFocusNode,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return "Email is required";
        }

        if (!EmailValidator.validate(val)) {
          return "Please enter correct email address";
        }

        return null;
      },
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onEditingComplete: () {
        _submitForm();
      },
      cursorColor: Colors.white,
      style: YodelTheme.bodyWhite,
      decoration: InputDecoration(
        contentPadding:
            EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
        labelText: "Email address",
        hintText: "Email address",
        prefixIcon: FocusableIcon(
          icon: YodelIcons.profile,
          focusNode: emailFocusNode,
          focusedColor: Colors.white,
          iconColor: YodelTheme.lightGreyBlue,
        ),
      ),
    );
  }

  void _submitForm() {
    if (formkey.currentState.validate()) {
      _bloc.add(RequestForgotPassword(
        email: emailController.text,
      ));
    } else if (!_isFormDirty) {
      setState(() {
        _isFormDirty = true;
      });
    }
  }
}
