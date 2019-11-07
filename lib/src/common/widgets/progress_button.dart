import 'package:flutter/material.dart';
import 'package:yodel/src/theme/themes.dart';

class ProgressButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool isLoading;
  final double width;
  final double height;
  final Color color;

  ProgressButton({
    Key key,
    this.child,
    this.color,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
        duration: Duration(milliseconds: 250),
        firstChild: Container(
          width: width,
          height: height,
          child: FlatButton(
            key: key,
            color: color,
            child: child,
            disabledColor: YodelTheme.lightGreyBlue,
            disabledTextColor: Colors.white,
            onPressed: onPressed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        secondChild: Container(
          width: width,
          height: height,
          child: Center(
            child: Container(
              width: 30.0,
              height: 30.0,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        crossFadeState:
            isLoading ? CrossFadeState.showSecond : CrossFadeState.showFirst);
  }
}
