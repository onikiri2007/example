import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/login/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/theme/themes.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      builder: (context) => LoginBloc(
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
              body: Stack(
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
                    child: LoginForm(),
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
