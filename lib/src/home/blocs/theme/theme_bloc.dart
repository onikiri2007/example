import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  @override
  ThemeState get initialState => ThemeState();

  @override
  Stream<ThemeState> mapEventToState(
    ThemeEvent event,
  ) async* {
    if (event is ChangeTheme) {
      yield this.state.copyWith(
            user: event.user,
          );
    }
  }
}
