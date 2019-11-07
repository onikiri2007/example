import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/home/index.dart';
import 'package:yodel/src/routes.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

import 'bootstrapper.dart';

class App extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App>
    with PostBuildActionMixin, WidgetsBindingObserver {
  AuthenticationBloc _authenticationBloc;
  CompanyBloc _companyBloc;
  ThemeBloc _themeBloc;
  ShiftsSyncBloc _shiftsRefresherBloc;

  @override
  void initState() {
    _companyBloc = CompanyBloc();
    _themeBloc = ThemeBloc();
    _shiftsRefresherBloc = ShiftsSyncBloc();

    _authenticationBloc = AuthenticationBloc(
      companyBloc: _companyBloc,
      themeBloc: _themeBloc,
    );

    _authenticationBloc.add(AppStarted());
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _companyBloc.close();
    _themeBloc.close();
    _shiftsRefresherBloc.close();
    _authenticationBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _authenticationBloc.add(SyncSession());
      _companyBloc.add(SyncCompany());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>.value(value: _authenticationBloc),
        BlocProvider<CompanyBloc>.value(value: _companyBloc),
        BlocProvider<ThemeBloc>.value(
          value: _themeBloc,
        ),
        BlocProvider<ShiftsSyncBloc>.value(
          value: _shiftsRefresherBloc,
        ),
      ],
      child: BlocBuilder(
          bloc: _themeBloc,
          builder: (context, ThemeState state) {
            final themeData = _getThemeData(state);

            return MaterialApp(
              theme: themeData,
              onGenerateRoute: router.generator,
              home: AuthenticationStateListener(
                  bloc: _authenticationBloc,
                  builder: (context, state) {
                    return SplashScreen();
                  }),
            );
          }),
    );
  }

  _getThemeData(ThemeState state) {
    final themeData = ThemeData(
      primaryColor: YodelTheme.darkGreyBlue,
      accentColor: YodelTheme.amber,
      highlightColor: YodelTheme.lightGreyBlue.withOpacity(0.32),
      splashColor: YodelTheme.lightGreyBlue.withOpacity(0.08),
      disabledColor: YodelTheme.lightGreyBlue,
      buttonColor: YodelTheme.amber,
      textTheme: TextTheme(
        body1: YodelTheme.bodyDefault,
        body2: YodelTheme.bodyActive,
        headline: YodelTheme.bodyStrong,
        caption: YodelTheme.metaDefault,
        title: YodelTheme.bodyWhite,
        subtitle: YodelTheme.metaRegular,
        subhead: YodelTheme.metaRegular,
        button: YodelTheme.bodyStrong,
      ),
      buttonTheme: ButtonThemeData(
        height: kButtonHeight,
      ),
      appBarTheme: AppBarTheme(
        actionsIconTheme: IconThemeData.fallback(),
        textTheme: TextTheme(
            button: YodelTheme.bodyManage,
            caption: YodelTheme.metaRegularInactive,
            display1: YodelTheme.bodyActive.copyWith(color: YodelTheme.amber),
            display2: YodelTheme.bodyActive.copyWith(
              color: YodelTheme.amber.withOpacity(0.32),
            ),
            display3: YodelTheme.bodyActive.copyWith(
              color: YodelTheme.lightGreyBlue,
            ),
            title: YodelTheme.bodyStrong.copyWith(
              color: Colors.white,
            )),
      ),
      inputDecorationTheme: InputDecorationTheme(
        alignLabelWithHint: true,
        hasFloatingPlaceholder: true,
        helperStyle: YodelTheme.metaRegular,
        fillColor: Colors.transparent,
        hintStyle: YodelTheme.bodyInactive,
        labelStyle: YodelTheme.bodyInactive,
        contentPadding: EdgeInsets.all(16),
        errorStyle: YodelTheme.errorText,
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.redAccent,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.white,
          ),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.redAccent,
          ),
        ),
      ),
    );

    if (state.isManager) {
      return themeData.copyWith(
        accentColor: YodelTheme.amber,
        appBarTheme: themeData.appBarTheme.copyWith(
          actionsIconTheme: themeData.appBarTheme.actionsIconTheme.copyWith(
            color: YodelTheme.amber,
          ),
          textTheme: themeData.appBarTheme.textTheme.copyWith(
            body1: YodelTheme.bodyActive.copyWith(color: YodelTheme.amber),
            body2: YodelTheme.bodyActive.copyWith(
              color: YodelTheme.amber.withOpacity(0.32),
            ),
          ),
        ),
      );
    }

    if (state.isWorker) {
      return themeData.copyWith(
        accentColor: YodelTheme.tealish,
        appBarTheme: themeData.appBarTheme.copyWith(
          actionsIconTheme: themeData.appBarTheme.actionsIconTheme.copyWith(
            color: YodelTheme.tealish,
          ),
        ),
        textTheme: themeData.appBarTheme.textTheme.copyWith(
          body1: YodelTheme.bodyActive.copyWith(color: YodelTheme.tealish),
          body2: YodelTheme.bodyActive.copyWith(
            color: YodelTheme.amber.withOpacity(0.32),
          ),
        ),
      );
    }

    return themeData;
  }
}
