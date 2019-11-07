import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
class ThemeState {
  final UserData user;

  ThemeState({
    this.user,
  });

  bool get isSiteManager => user?.isSiteManager ?? false;
  bool get isManager => user?.isManager ?? false || isSiteManager;
  bool get isWorker => user?.isWorker ?? false;
  bool get isUnknown => !isManager && isWorker;

  ThemeState copyWith({
    UserData user,
  }) =>
      ThemeState(
        user: user ?? this.user,
      );
}
