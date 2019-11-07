import 'package:meta/meta.dart';

@immutable
abstract class BottomTabControllerEvent {}

class ChangeTab extends BottomTabControllerEvent {
  final int tab;
  ChangeTab({
    @required this.tab,
  });
}

class ChangeVisibilityTab extends BottomTabControllerEvent {
  final bool isVisible;
  ChangeVisibilityTab({
    @required this.isVisible,
  });
}
