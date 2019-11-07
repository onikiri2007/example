import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/config.dart';
import 'package:yodel/src/routes.dart';
import 'package:yodel/src/theme/themes.dart';

void main() async {
  Config.appFlavour = Flavour.Staging;
  setupStatusBarColour(
    color: YodelTheme.darkGreyBlue,
  );
  setupRoutes();
  run();
}
