import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:raygun/raygun.dart';

class FlutterBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print("event: $event");
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    if (kReleaseMode) {
      FlutterRaygun().logException(error, stacktrace);
    } else {
      print("bloc error: $error, stacktrace: $stacktrace");
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print("transition: $transition");
  }
}
