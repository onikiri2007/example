import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardDismissable extends StatelessWidget {
  final Widget child;

  KeyboardDismissable({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: child,
    );
  }
}
