import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/home/index.dart';
import 'package:yodel/src/login/index.dart';
import 'package:yodel/src/profile/index.dart';
import 'package:yodel/src/reset_password/index.dart';
import 'package:yodel/src/shift/index.dart';

import 'contact/index.dart';
import 'forgot_password/index.dart';

final router = Router();

final noAccountRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return NoAccountScreen();
});

final forgotpasswordRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return ForgotPasswordScreen();
});

///route handler
final resetPasswordRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return AuthenticationStateListener(
    bloc: BlocProvider.of<AuthenticationBloc>(context),
    builder: (context, state) => ResetPasswordScreen(),
  );
});

final loginRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return AuthenticationStateListener(
    bloc: BlocProvider.of<AuthenticationBloc>(context),
    builder: (context, state) => LoginScreen(),
  );
});

final welcomeRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return AuthenticationStateListener(
    bloc: BlocProvider.of<AuthenticationBloc>(context),
    builder: (context, state) => WelcomeScreen(),
  );
});

///route handler
final confirmProfileRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return AuthenticationStateListener(
    bloc: BlocProvider.of<AuthenticationBloc>(context),
    builder: (context, state) => ConfirmProfileScreen(),
  );
});

///route handler
final createShiftRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return CreateShiftScreen();
});

//router handlers
final shiftsRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return ShiftListScreen();
});

//router handlers
final shiftRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return ShiftDetailsScreen(
    shiftId: params["id"][0],
  );
});

var rootHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return SplashScreen();
});

///route handler
final homePageRoutedHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return AuthenticationStateListener(
    bloc: BlocProvider.of<AuthenticationBloc>(context),
    builder: (context, state) => HomeScreen(),
  );
});

final contactRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  final String idString = params["id"][0];

  if (idString == null) {
    throw FlutterError(
      "You need to pass an user id",
    );
  }

  final int id = int.tryParse(idString);
  return ContactDetailsScreen(
    id: id,
  );
});

final sitesRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return SitesScreen();
});

final contactsRouteHandler =
    Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return ContactsScreen();
});

void setupRoutes() {
  router.define("/", handler: rootHandler);
  router.define("/home", handler: homePageRoutedHandler);
  router.define("/reset-password", handler: resetPasswordRouteHandler);
  router.define("/welcome", handler: welcomeRouteHandler);
  router.define("/login", handler: loginRouteHandler);
  router.define("/no-account", handler: noAccountRouteHandler);
  router.define("/confirm-profile", handler: confirmProfileRouteHandler);
  router.define("/welcome", handler: welcomeRouteHandler);
  router.define("/create-shift", handler: createShiftRouteHandler);
  router.define("/forgot-password", handler: forgotpasswordRouteHandler);
  router.define("/shifts", handler: shiftsRouteHandler);
  router.define("/shifts/:id", handler: shiftRouteHandler);
  router.define("/contact/:id", handler: contactRouteHandler);
  router.define("/sites", handler: sitesRouteHandler);
  router.define("/contacts", handler: contactsRouteHandler);
}
