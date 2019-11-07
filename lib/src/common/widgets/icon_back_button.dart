import 'package:flutter/material.dart';

class IconBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  IconBackButton({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: const BackButtonIcon(),
        color: Colors.black,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () {
          if (onPressed != null) {
            onPressed();
          }
          Navigator.maybePop(context);
        });
  }
}
