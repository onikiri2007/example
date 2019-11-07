import 'package:flutter/material.dart';
import 'package:yodel/src/theme/themes.dart';

enum SeparatorAxis { horizontal, vertical }

class Separator extends StatelessWidget {
  final SeparatorAxis axis;
  Separator({this.axis = SeparatorAxis.horizontal});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: axis == SeparatorAxis.horizontal ? double.infinity : 1,
      height: axis == SeparatorAxis.horizontal ? 1 : double.infinity,
      color: YodelTheme.separatorColor,
    );
  }
}
