import 'package:flutter/material.dart';

class MiniLoadingIndicator extends StatelessWidget {
  final double width;
  final double height;
  final EdgeInsets padding;

  const MiniLoadingIndicator({
    Key key,
    this.width = 25,
    this.height = 25,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: width,
        height: height,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
