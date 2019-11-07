import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yodel/src/authentication/bloc/authentication_bloc.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/reset_password/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/theme/themes.dart';

class ResetPasswordScreen extends StatelessWidget with PostBuildActionMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => ResetPasswordBloc(
        authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
      ),
      child: WillPopScope(
        onWillPop: () async {
          await sl<AppService>().minimise();
          return Future.value(false);
        },
        child: SafeArea(
          child: KeyboardDismissable(
            child: Scaffold(
              backgroundColor: YodelTheme.darkGreyBlue,
              body: BlocListener<ResetPasswordBloc, ResetPasswordState>(
                listener: (context, state) {
                  if (state is ResetPasswordFailure) {
                    showErrorOnPostBuild(context, state.error);
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Positioned(
                      width: 90,
                      height: 160,
                      left: 0,
                      top: 25,
                      child: SvgPicture.asset(
                        YodelImages.bg_pattern_teal,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      width: 165,
                      height: 225,
                      right: 0,
                      bottom: 0,
                      child: SvgPicture.asset(
                        YodelImages.bg_pattern_iris,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Center(
                      child: ResetPasswordForm(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
