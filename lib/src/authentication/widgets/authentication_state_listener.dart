import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/routes.dart';

class AuthenticationStateListener extends StatelessWidget {
  final AuthenticationBloc bloc;
  final BlocWidgetBuilder<AuthenticationState> builder;

  AuthenticationStateListener({
    Key key,
    this.bloc,
    this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocRouteListener(
      bloc: bloc,
      child: BlocBuilder(
        bloc: bloc,
        builder: builder,
      ),
      listener: (context, AuthenticationState state) {
        if (state is AuthenticationUnauthenticated) {
          router.navigateTo(context, "/login",
              replace: true, transition: TransitionType.native);
        }

        if (state is AuthenticationAuthenticated) {
          router.navigateTo(context, "/home",
              replace: true, transition: TransitionType.native);
        }

        if (state is AuthenticationAuthenticatedFromAppLink) {
          router.navigateTo(context, "/confirm-profile",
              replace: true, transition: TransitionType.native);
        }

        if (state is AuthenticationAppLinkOpened) {
          router.navigateTo(context, "/reset-password",
              replace: true, transition: TransitionType.native);
        }
      },
    );
  }
}
