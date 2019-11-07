import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class BottomTabsBloc
    extends Bloc<BottomTabControllerEvent, BottomTabControllerState> {
  @override
  BottomTabControllerState get initialState =>
      BottomTabControllerState.initialial();

  @override
  Stream<BottomTabControllerState> mapEventToState(
    BottomTabControllerEvent event,
  ) async* {
    if (event is ChangeTab) {
      yield this.state.copyWith(currentTab: event.tab);
    }

    // if (event is ChangeVisibilityTab) {
    //   yield this.currentState.copyWith(isVisible: event.isVisible);
    // }
  }
}
