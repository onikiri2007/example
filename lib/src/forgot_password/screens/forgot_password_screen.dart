import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/forgot_password/index.dart';
import 'package:yodel/src/theme/themes.dart';

class ForgotPasswordScreen extends StatelessWidget with PostBuildActionMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordBloc>(
      builder: (context) => ForgotPasswordBloc(),
      child: SafeArea(
        child: KeyboardDismissable(
          child: Scaffold(
            backgroundColor: YodelTheme.darkGreyBlue,
            appBar: AppBar(
              centerTitle: true,
              elevation: 0.0,
              automaticallyImplyLeading: false,
              leading: OverflowBox(
                maxWidth: 90.0,
                child: NavbarButton(
                    padding: const EdgeInsets.only(left: 16.0),
                    style: YodelTheme.bodyDefault.copyWith(
                      color: YodelTheme.tealish,
                    ),
                    highlightedStyle: YodelTheme.bodyDefault.copyWith(
                      color: YodelTheme.tealish.withOpacity(0.8),
                    ),
                    child: Text(
                      "Back",
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              title: Text("Forgot password"),
            ),
            body: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
              listener: (context, state) {
                if (state is ForgotPasswordFailed) {
                  showErrorOnPostBuild(context, state.error);
                }

                if (state is ForgotPasswordRequestSent) {
                  showSuccessOnPostBuild(context,
                      "Forgot password request successfully sent. Please check your inbox to reset your password.",
                      callback: () {
                    Navigator.pop(context);
                  });
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
                    child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                      builder: (BuildContext context, state) {
                        return ForgotPasswordForm();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
