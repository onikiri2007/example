import 'package:flutter/material.dart';
import 'package:yodel/src/common/widgets/index.dart';

class NavbarButton extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback onPressed;
  final Alignment alignment;
  final TextStyle style;
  final TextStyle highlightedStyle;
  final TextStyle disabledStyle;

  const NavbarButton({
    Key key,
    @required this.child,
    this.padding,
    this.onPressed,
    this.alignment = Alignment.center,
    this.style,
    this.highlightedStyle,
    this.disabledStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      alignment: alignment,
      child: LinkButton(
        style: style ?? Theme.of(context).appBarTheme.textTheme.display1,
        highlightStyle: highlightedStyle ??
            Theme.of(context).appBarTheme.textTheme.display2,
        disabledStyle:
            disabledStyle ?? Theme.of(context).appBarTheme.textTheme.display3,
        child: child,
        onPressed: onPressed,
      ),
    );
  }
}
