import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/authentication/bloc/authentication_bloc.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/reset_password/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/theme/themes.dart';

class ChangePasswordScreen extends StatelessWidget with PostBuildActionMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (context) => ResetPasswordBloc(
        authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
      ),
      child: SafeArea(
        child: KeyboardDismissable(
          child: Scaffold(
            backgroundColor: YodelTheme.darkGreyBlue,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0.0,
              leading: OverflowBox(
                maxWidth: 80.0,
                child: NavbarButton(
                  padding: const EdgeInsets.only(left: 16.0),
                  style: Theme.of(context).appBarTheme.textTheme.button,
                  highlightedStyle:
                      Theme.of(context).appBarTheme.textTheme.button.copyWith(
                            color: Theme.of(context)
                                .appBarTheme
                                .textTheme
                                .button
                                .color
                                .withOpacity(0.8),
                          ),
                  child: Text(
                    "Back",
                  ),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            body: BlocListener<ResetPasswordBloc, ResetPasswordState>(
              listener: (context, state) {
                if (state is ResetPasswordFailure) {
                  showErrorOnPostBuild(context, state.error);
                }

                if (state is ResetPasswordCompleted) {
                  showSuccessOnPostBuild(
                      context, "Password has been updated successfully",
                      callback: () {
                    Navigator.of(context).pop();
                  });
                }
              },
              child: Center(
                child: ResetPasswordForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
