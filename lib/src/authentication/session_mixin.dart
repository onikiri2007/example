import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';

mixin SessionProviderMixin {
  Session get session => sl<SessionTracker>().session.value;
}
