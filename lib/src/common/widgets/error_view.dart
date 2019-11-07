import 'package:flutter/material.dart';
import 'package:yodel/src/theme/themes.dart';

class ErrorView extends StatelessWidget {
  final String error;

  const ErrorView({Key key, this.error}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Text(error,
          textAlign: TextAlign.center,
          style: YodelTheme.bodyDefault.copyWith(
            color: Colors.redAccent,
          )),
    );
  }
}
