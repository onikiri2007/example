import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/reset_password/index.dart';
import 'package:yodel/src/theme/themes.dart';

class ResetPasswordForm extends StatefulWidget {
  ResetPasswordForm({
    Key key,
  }) : super(key: key);

  _ResetPasswordFormState createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm>
    with PostBuildActionMixin {
  ResetPasswordBloc _bloc;
  final formkey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  TextEditingController emailController;
  var _isFormDirty = false;
  final confirmPasswordFocusNode = FocusNode();
  final currentPasswordFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  AuthenticationBloc _authBloc;

  @override
  void initState() {
    _authBloc = BlocProvider.of<AuthenticationBloc>(context);
    _bloc = BlocProvider.of<ResetPasswordBloc>(context);

    emailController = TextEditingController(
        text: _bloc.request.email ??
            _authBloc?.sessionTracker?.currentSession?.userData?.email);

    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    passwordFocusNode.dispose();
    currentPasswordController.dispose();
    currentPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResetPasswordBloc, ResetPasswordState>(
      listener: (context, state) {
        if (state is ResetPasswordFailure) {
          showErrorOnPostBuild(context, state.error);
        }
      },
      child: BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
        bloc: _bloc,
        builder: (context, state) {
          var header = "Reset your password";
          final data = _bloc.request;
          if (data.type == AuthenticationAppLinkType.CreatePassword) {
            header = "Create your password";
          } else {
            header = "Reset your password";
          }

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
                  Container(
                    height: 16.0,
                  ),
                  Center(
                    child: Text(
                      header,
                      style: YodelTheme.bodyWhite,
                    ),
                  ),
                  Container(
                    height: 32.0,
                  ),
                  _buildResetPasswordForm(data: data, state: state)
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _buildResetPasswordForm({
    ResetPasswordRequestData data,
    ResetPasswordState state,
  }) {
    final isAuthenticated = _authBloc?.sessionTracker?.isAuthenticated ?? false;

    return Form(
      key: formkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildEmailField(),
          SizedBox(
            height: 20.0,
          ),
          if (!isAuthenticated) _buildPasswordField(),
          if (isAuthenticated) _buildCurrentPasswordField(),
          SizedBox(
            height: 20.0,
          ),
          if (!isAuthenticated) _buildConfirmPasswordField(data: data),
          if (isAuthenticated) _buildPasswordField(),
          SizedBox(
            height: 20.0,
          ),
          _buildButton(data: data, state: state),
          SizedBox(
            height: 24.0,
          ),
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
      textInputAction: TextInputAction.next,
      focusNode: emailFocusNode,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(passwordFocusNode);
      },
      cursorColor: Colors.white,
      style: YodelTheme.bodyInactive,
      enabled: false,
      decoration: InputDecoration(
        contentPadding:
            EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
        labelText: "Email address",
        hintText: "Email address",
        enabled: false,
        prefixIcon: Icon(
          YodelIcons.profile,
          color:
              emailFocusNode.hasFocus ? Colors.white : YodelTheme.lightGreyBlue,
        ),
      ),
    );
  }

  _buildPasswordField() {
    final isAuthenticated = _authBloc?.sessionTracker?.isAuthenticated ?? false;

    return TextFormField(
      key: ValueKey("password"),
      controller: passwordController,
      autocorrect: false,
      onEditingComplete: () {
        if (isAuthenticated) {
          FocusScope.of(context).requestFocus(new FocusNode());
          _submitForm();
        } else {
          FocusScope.of(context).requestFocus(confirmPasswordFocusNode);
        }
      },
      autovalidate: _isFormDirty,
      validator: (val) => val == null || val.isEmpty
          ? isAuthenticated
              ? "New Password is required"
              : "Password is required"
          : null,
      obscureText: true,
      focusNode: passwordFocusNode,
      textInputAction:
          isAuthenticated ? TextInputAction.go : TextInputAction.next,
      cursorColor: Colors.white,
      style: YodelTheme.bodyWhite,
      decoration: InputDecoration(
        contentPadding:
            EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
        labelText: isAuthenticated ? "New Password" : "Password",
        hintText: isAuthenticated ? "New Password" : "Password",
        prefixIcon: FocusableIcon(
          icon: YodelIcons.password_lock,
          focusNode: passwordFocusNode,
          focusedColor: Colors.white,
          iconColor: YodelTheme.lightGreyBlue,
        ),
      ),
    );
  }

  _buildCurrentPasswordField({ResetPasswordRequestData data}) {
    return TextFormField(
      key: ValueKey("currentPassword"),
      controller: currentPasswordController,
      autocorrect: false,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(passwordFocusNode);
      },
      autovalidate: _isFormDirty,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return "Current password is required";
        }
        return null;
      },
      obscureText: true,
      focusNode: currentPasswordFocusNode,
      textInputAction: TextInputAction.next,
      cursorColor: Colors.white,
      style: YodelTheme.bodyWhite,
      decoration: InputDecoration(
        contentPadding:
            EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
        labelText: "Current Password",
        hintText: "Current Password",
        prefixIcon: FocusableIcon(
          icon: YodelIcons.password_lock,
          focusNode: confirmPasswordFocusNode,
          focusedColor: Colors.white,
          iconColor: YodelTheme.lightGreyBlue,
        ),
      ),
    );
  }

  _buildConfirmPasswordField({ResetPasswordRequestData data}) {
    return TextFormField(
      key: ValueKey("confirmPassword"),
      controller: confirmPasswordController,
      autocorrect: false,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _submitForm();
      },
      autovalidate: _isFormDirty,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return "Confirm password is required";
        }

        if (val != passwordController.text) {
          return "Confirm password does not match with password";
        }

        return null;
      },
      obscureText: true,
      focusNode: confirmPasswordFocusNode,
      textInputAction: TextInputAction.go,
      cursorColor: Colors.white,
      style: YodelTheme.bodyWhite,
      decoration: InputDecoration(
        contentPadding:
            EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
        labelText: "Confirm Password",
        hintText: "Confirm Password",
        prefixIcon: FocusableIcon(
          icon: YodelIcons.password_lock,
          focusNode: confirmPasswordFocusNode,
          focusedColor: Colors.white,
          iconColor: YodelTheme.lightGreyBlue,
        ),
      ),
    );
  }

  _buildButton({ResetPasswordRequestData data, ResetPasswordState state}) {
    return ProgressButton(
      width: double.infinity,
      height: 60,
      isLoading: state is ResetPasswordLoading,
      color: YodelTheme.amber,
      onPressed: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _submitForm();
      },
      child: Text(data.type == AuthenticationAppLinkType.CreatePassword
          ? "Create account"
          : "Reset password"),
    );
  }

  void _submitForm() {
    final request = _bloc.request;
    if (formkey.currentState.validate()) {
      _bloc.add(ResetPasswordButtonPressed(
        email: emailController.text,
        password: passwordController.text,
        token: request.token,
        currentPassword: currentPasswordController.text,
        type: request.type,
      ));
    } else if (!_isFormDirty) {
      setState(() {
        _isFormDirty = true;
      });
    }
  }
}
