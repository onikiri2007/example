import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class BottomTabControllerState extends Equatable {
  final int currentTab;
  final bool isVisible;

  BottomTabControllerState({this.currentTab = 0, this.isVisible = true});

  BottomTabControllerState copyWith({
    int currentTab,
    bool isVisible,
  }) =>
      BottomTabControllerState(
        currentTab: currentTab ?? this.currentTab,
        isVisible: isVisible ?? this.isVisible,
      );

  factory BottomTabControllerState.initialial() =>
      BottomTabControllerState(currentTab: 0, isVisible: true);

  @override
  // TODO: implement props
  List<Object> get props => [currentTab, isVisible];
}
