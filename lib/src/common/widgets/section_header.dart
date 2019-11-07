import 'package:flutter/material.dart';
import 'package:yodel/src/theme/themes.dart';

class SectionHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  SectionHeader({
    Key key,
    this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: YodelTheme.paleGrey,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 0,
            color: YodelTheme.shadow,
          ),
        ],
      ),
      child: child,
    );
  }
}
