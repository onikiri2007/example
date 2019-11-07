import 'package:flutter/material.dart';

class BorderButton extends StatelessWidget {
  BorderButton({
    this.child,
    this.onPressed,
    this.hasBorder = false,
    this.borderColor = Colors.transparent,
    this.borderWidth = 1.0,
    this.height,
  });

  final VoidCallback onPressed;
  final Widget child;
  final bool hasBorder;
  final Color borderColor;
  final double borderWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? Theme.of(context).buttonTheme.height,
      child: FlatButton(
        padding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: hasBorder
                ? BorderSide(
                    width: borderWidth,
                    style: BorderStyle.solid,
                    color: borderColor)
                : BorderSide.none),
        child: child,
        onPressed: onPressed,
      ),
    );
  }
}
