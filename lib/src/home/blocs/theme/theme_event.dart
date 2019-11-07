import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class ThemeEvent {}

class ChangeTheme extends ThemeEvent {
  final UserData user;

  ChangeTheme({
    this.user,
  });

  @override
  String toString() => 'ChangeTheme';
}
