import 'package:flutter/material.dart';

class FocusableIcon extends StatefulWidget {
  const FocusableIcon({
    Key key,
    this.icon,
    this.iconColor,
    this.focusedColor,
    @required this.focusNode,
  })  : assert(focusNode != null),
        super(key: key);

  @override
  _FocusableIconState createState() => _FocusableIconState();

  final IconData icon;
  final FocusNode focusNode;
  final Color iconColor;
  final Color focusedColor;
}

class _FocusableIconState extends State<FocusableIcon> {
  @override
  void initState() {
    widget.focusNode.addListener(onFocusChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(onFocusChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(FocusableIcon oldWidget) {
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode .removeListener(onFocusChanged);
      widget.focusNode.addListener(onFocusChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  void onFocusChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Icon(widget.icon,
        color: widget.focusNode.hasFocus
            ? widget.focusedColor ?? Colors.black
            : widget.iconColor ?? Colors.white);
  }
}
