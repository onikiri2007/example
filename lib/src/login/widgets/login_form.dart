import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/login/index.dart';
import 'package:yodel/src/routes.dart';
import 'package:yodel/src/theme/themes.dart';

class LoginForm extends StatefulWidget {
  LoginForm({
    Key key,
  }) : super(key: key);
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with PostBuildActionMixin {
  final formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var _isFormDirty = false;
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          showErrorOnPostBuild(context, state.error);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if (state is LoginCompleted) {
            return LoadingIndicator();
          }

          return Container(
            padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 20.0),
            child: SingleChildScrollView(
              child: LayoutBuilder(builder: (context, constraints) {
                final isPhone = constraints.maxWidth <= 400;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    LimitedBox(
                      maxHeight: isPhone ? 120 : 300,
                      child: SvgPicture.asset(
                        YodelImages.logo,
                        fit: BoxFit.cover,
                        color: YodelTheme.tealish,
                      ),
                    ),
                    Container(
                      height: 20.0,
                    ),
                    _buildLoginForm(state: state)
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }

  _buildLoginForm({LoginState state}) {
    return Form(
      key: formkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildEmailField(),
          SizedBox(
            height: 20.0,
          ),
          _buildPasswordField(),
          SizedBox(
            height: 20.0,
          ),
          Theme(
            data: Theme.of(context).copyWith(splashColor: Colors.transparent),
            child: LinkButton(
              alignment: Alignment.centerLeft,
              style: YodelTheme.metaRegular.copyWith(color: YodelTheme.tealish),
              disabledStyle: YodelTheme.metaRegularInactive,
              highlightStyle: YodelTheme.metaRegularActive.copyWith(
                color: YodelTheme.tealish.withOpacity(0.8),
              ),
              onPressed: () {
                router.navigateTo(context, "/forgot-password",
                    transition: TransitionType.native);
              },
              child: Container(
                alignment: Alignment.centerLeft,
                height: 32,
                child: Text("Forgot password?"),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          _buildButton(state: state),
          SizedBox(
            height: 32.0,
          ),
          Theme(
            data: Theme.of(context).copyWith(splashColor: Colors.transparent),
            child: LinkButton(
              alignment: Alignment.center,
              style: YodelTheme.metaRegular.copyWith(color: YodelTheme.tealish),
              disabledStyle: YodelTheme.metaRegularInactive,
              highlightStyle: YodelTheme.metaRegularActive.copyWith(
                color: YodelTheme.tealish.withOpacity(0.8),
              ),
              onPressed: () {
                router.navigateTo(context, "/no-account",
                    transition: TransitionType.native);
              },
              child: Container(
                alignment: Alignment.center,
                height: 50,
                child: Text("I don't have an account"),
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
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

  _buildPasswordField() {
    return TextFormField(
      key: ValueKey("password"),
      controller: passwordController,
      autocorrect: false,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _submitForm();
      },
      autovalidate: _isFormDirty,
      validator: (val) =>
          val == null || val.isEmpty ? "Password is required" : null,
      obscureText: true,
      focusNode: passwordFocusNode,
      textInputAction: TextInputAction.go,
      cursorColor: Colors.white,
      style: YodelTheme.bodyWhite,
      decoration: InputDecoration(
        contentPadding:
            EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
        labelText: "Password",
        hintText: "Password",
        prefixIcon: FocusableIcon(
          icon: YodelIcons.password_lock,
          focusNode: passwordFocusNode,
          focusedColor: Colors.white,
          iconColor: YodelTheme.lightGreyBlue,
        ),
      ),
    );
  }

  _buildButton({LoginState state}) {
    return ProgressButton(
      width: double.infinity,
      height: 60,
      isLoading: state is LoginLoading,
      color: YodelTheme.amber,
      onPressed: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _submitForm();
      },
      child: Text(
        "Login",
        style: YodelTheme.bodyStrong,
      ),
    );
  }

  void _submitForm() {
    final loginBloc = BlocProvider.of<LoginBloc>(context);
    if (formkey.currentState.validate()) {
      loginBloc.add(LoginButtonPressed(
        username: emailController.text,
        password: passwordController.text,
      ));
    } else if (!_isFormDirty) {
      setState(() {
        _isFormDirty = true;
      });
    }
  }
}
