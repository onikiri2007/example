import 'package:flutter/material.dart';
import 'package:yodel/src/theme/yodel_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final Color backgroundColor;
  LoadingIndicator({
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? YodelTheme.lightPaleGrey,
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
}
