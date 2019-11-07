import 'package:flutter/material.dart';
import 'dart:math' as math;

class LinkButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final TextStyle highlightStyle;
  final TextStyle style;
  final TextStyle disabledStyle;
  final Alignment alignment;

  LinkButton({
    Key key,
    @required this.child,
    this.onPressed,
    @required this.style,
    this.disabledStyle,
    this.highlightStyle,
    this.alignment = Alignment.bottomCenter,
  })  : assert(style != null),
        assert(child != null),
        super(key: key);

  @override
  _LinkButtonState createState() => _LinkButtonState();
}

class _LinkButtonState extends State<LinkButton> {
  bool _highlighted = false;

  @override
  Widget build(BuildContext context) {
    TextStyle currentStyle = widget.style;

    if (widget.onPressed == null) {
      currentStyle = widget.disabledStyle ??
          widget.style.copyWith(color: Theme.of(context).disabledColor);
    }

    if (_highlighted) {
      currentStyle = widget.highlightStyle ??
          widget.style.copyWith(color: Theme.of(context).highlightColor);
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onHighlightChanged: ((highlighted) {
          setState(() {
            this._highlighted = highlighted;
          });
        }),
        onTap: widget.onPressed,
        child: AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 200),
          curve: Curves.linear,
          style: currentStyle,
          child: widget.child,
        ),
      ),
    );
  }
}

const double _kMinButtonSize = 48.0;

class IconLinkButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final Color highlightColor;
  final Color disabledColor;
  final Color splashColor;
  final Color color;
  final double iconSize;
  final EdgeInsets padding;
  final AlignmentGeometry alignment;
  final String tooltip;

  IconLinkButton({
    Key key,
    @required this.icon,
    this.color,
    this.iconSize = 24.0,
    this.highlightColor,
    this.disabledColor,
    this.splashColor,
    this.padding = const EdgeInsets.all(8.0),
    this.alignment = Alignment.center,
    @required this.onPressed,
    this.tooltip,
  })  : assert(iconSize != null),
        assert(padding != null),
        assert(alignment != null),
        assert(icon != null),
        super(key: key);

  @override
  _IconLinkButtonState createState() => _IconLinkButtonState();
}

class _IconLinkButtonState extends State<IconLinkButton> {
  bool _isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    Color currentColor = widget.color;
    if (widget.onPressed == null) {
      currentColor = widget.disabledColor ?? Theme.of(context).disabledColor;
    }

    if (_isHighlighted) {
      currentColor = widget.highlightColor ?? Theme.of(context).highlightColor;
    }

    Widget result = Semantics(
      button: true,
      enabled: widget.onPressed != null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
            minWidth: _kMinButtonSize, minHeight: _kMinButtonSize),
        child: Padding(
          padding: widget.padding,
          child: SizedBox(
            height: widget.iconSize,
            width: widget.iconSize,
            child: Align(
              alignment: widget.alignment,
              child: IconTheme.merge(
                data: IconThemeData(
                  size: widget.iconSize,
                  color: currentColor,
                ),
                child: widget.icon,
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      result = Tooltip(
        message: widget.tooltip,
        child: result,
      );
    }
    return InkResponse(
      onTap: widget.onPressed,
      child: result,
      onHighlightChanged: (highlighted) {
        setState(() {
          _isHighlighted = highlighted;
        });
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      radius: math.max(
        Material.defaultSplashRadius,
        (widget.iconSize +
                math.min(widget.padding.horizontal, widget.padding.vertical)) *
            0.7,
        // x 0.5 for diameter -> radius and + 40% overflow derived from other Material apps.
      ),
    );
  }
}
