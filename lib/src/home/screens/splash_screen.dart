import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yodel/src/theme/themes.dart';

class SplashScreen extends StatelessWidget {
  final Widget child;

  SplashScreen({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: YodelTheme.darkGreyBlue,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
              width: 90,
              height: 160,
              left: 0,
              top: 25,
              child: SvgPicture.asset(
                YodelImages.bg_pattern_teal,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              width: 165,
              height: 225,
              right: 0,
              bottom: 0,
              child: SvgPicture.asset(
                YodelImages.bg_pattern_iris,
                fit: BoxFit.cover,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 300,
                  height: 100,
                  child: SvgPicture.asset(
                    YodelImages.logo,
                    fit: BoxFit.cover,
                    color: YodelTheme.tealish,
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
