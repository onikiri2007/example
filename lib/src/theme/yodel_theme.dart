import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double kIconSize = 150.0;
const double kButtonHeight = 60.0;

class YodelTheme {
  static String _kFontFamily = "Roboto";

  static const Color iris = const Color.fromRGBO(105, 112, 181, 1.0);
  static const Color lightIris = const Color.fromRGBO(105, 112, 181, 0.08);

  static const Color darkGreyBlue = const Color.fromRGBO(44, 62, 80, 1.0);
  static const Color tealish = const Color.fromRGBO(37, 186, 162, 1.0);
  static const Color paleGrey = const Color.fromRGBO(238, 239, 249, 1.0);
  static const Color lightGreyBlue = const Color.fromRGBO(170, 177, 185, 1.0);
  static const Color amber = const Color.fromRGBO(255, 186, 8, 1.0);
  static const Color lightPaleGrey = const Color.fromRGBO(250, 250, 255, 1.0);
  static const Color shadow = const Color.fromRGBO(44, 62, 80, 0.08);
  static const Color scarlet15 = const Color.fromRGBO(208, 2, 227, 0.15);
  static const Color destructionColor = const Color.fromRGBO(255, 0, 0, 1.0);
  static const Color separatorColor = const Color.fromRGBO(105, 112, 181, 0.24);

  static TextStyle mainTitle = TextStyle(
    fontSize: 28.0,
    color: Colors.white,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyStrong = TextStyle(
    fontSize: 17.0,
    color: darkGreyBlue,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyWhite = TextStyle(
    fontSize: 17,
    color: Colors.white,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyInactive = TextStyle(
    fontSize: 17.0,
    color: lightGreyBlue,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyActive = TextStyle(
    fontSize: 17.0,
    color: iris,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle toggleButtonTextNotSelected = TextStyle(
    fontSize: 17.0,
    color: iris,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyDefault = TextStyle(
    fontSize: 17.0,
    color: darkGreyBlue,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodyHyperText = TextStyle(
      fontSize: 17.0,
      color: lightGreyBlue,
      fontFamily: _kFontFamily,
      fontWeight: FontWeight.w300);

  static TextStyle tabFilterDefault =
      TextStyle(fontSize: 16.0, color: lightGreyBlue, fontFamily: _kFontFamily);

  static TextStyle bodyManage = TextStyle(
    fontSize: 17.0,
    color: amber,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle tabFilterActive = TextStyle(
    fontSize: 16.0,
    color: Colors.white,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle metaStrong = TextStyle(
    fontSize: 13.0,
    color: darkGreyBlue,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.bold,
  );

  static TextStyle metaRegularInactive = TextStyle(
    fontSize: 13.0,
    color: lightGreyBlue,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle metaRegular = TextStyle(
    fontSize: 13.0,
    color: darkGreyBlue,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle metaRegularActive = TextStyle(
    fontSize: 13.0,
    color: iris,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle metaRegularActiveWhite = TextStyle(
    fontSize: 13.0,
    color: Colors.white,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle metaRegularHighlighted = TextStyle(
    fontSize: 13.0,
    color: darkGreyBlue,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle metaDefault = TextStyle(
      fontSize: 13.0,
      color: darkGreyBlue,
      fontFamily: _kFontFamily,
      fontWeight: FontWeight.w300);

  static TextStyle metaWhite = TextStyle(
    fontSize: 13.0,
    color: Colors.white,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.w300,
  );
  static TextStyle metaAmber = TextStyle(
    fontSize: 13.0,
    color: amber,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.w300,
  );

  static TextStyle caption = TextStyle(
    fontSize: 13.0,
    color: Colors.white,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle metaDefaultInactive = TextStyle(
      fontSize: 13.0,
      color: lightGreyBlue,
      fontFamily: _kFontFamily,
      fontWeight: FontWeight.w300);

  static TextStyle metaRegularManage = TextStyle(
    fontSize: 13.0,
    color: amber,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle errorText = TextStyle(
    fontSize: 11.0,
    color: Colors.redAccent,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.normal,
  );

  static TextStyle titleWhite = TextStyle(
    fontSize: 17,
    color: Colors.white,
    fontFamily: _kFontFamily,
    fontWeight: FontWeight.w500,
  );
}
