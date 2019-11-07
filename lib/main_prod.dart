import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/config.dart';
import 'package:yodel/src/routes.dart';
import 'package:yodel/src/theme/themes.dart';

void main() {
  Config.appFlavour = Flavour.Production;
  setupStatusBarColour(
    color: YodelTheme.darkGreyBlue,
  );
  setupRoutes();
  run();
}
