import 'package:flutter/material.dart';
import 'package:yodel/src/theme/themes.dart';

class NumberStepper extends StatefulWidget {
  final FocusNode focusNode;
  final Color iconColor;
  final Color buttonColor;
  final TextEditingController controller;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final Color highlightColor;
  final Color disabledColor;
  final Color splashColor;

  NumberStepper({
    FocusNode focusNode,
    this.iconColor,
    this.buttonColor,
    this.highlightColor,
    this.disabledColor,
    this.splashColor,
    this.controller,
    this.onChanged,
    this.min,
    this.max,
  })  : this.focusNode = focusNode ?? FocusNode(),
        assert(controller != null);

  @override
  _NumberStepperState createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  bool reachMax = false;
  bool reachMin = false;

  @override
  void initState() {
    reachMin = _isMin(_convertToInt(widget.controller.text));
    reachMax = _isMax(_convertToInt(widget.controller.text));
    widget.controller.addListener(_onChange);
    widget.focusNode.addListener(_onFocusChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(NumberStepper oldWidget) {
    if (oldWidget.controller != widget.controller) {
      widget.controller.removeListener(_onChange);
      widget.controller.addListener(_onChange);
    }

    if (oldWidget.focusNode != widget.focusNode) {
      widget.focusNode.removeListener(_onFocusChanged);
      widget.focusNode.addListener(_onFocusChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _IconButton(
          icon: YodelIcons.minus,
          buttonColor: widget.buttonColor,
          highlightColor: widget.highlightColor,
          splashColor: widget.splashColor,
          iconColor: widget.iconColor,
          disabledColor: widget.disabledColor,
          highlightedIconColor: Colors.white,
          onPressed: reachMin
              ? null
              : () {
                  _decrement();
                },
        ),
        Expanded(
          child: TextField(
            textAlign: TextAlign.center,
            controller: widget.controller,
            focusNode: widget.focusNode,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.numberWithOptions(),
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              alignLabelWithHint: true,
            ),
          ),
        ),
        _IconButton(
          icon: YodelIcons.add,
          buttonColor: widget.buttonColor,
          highlightColor: widget.highlightColor,
          splashColor: widget.splashColor,
          iconColor: widget.iconColor,
          disabledColor: widget.disabledColor,
          highlightedIconColor: Colors.white,
          onPressed: reachMax
              ? null
              : () {
                  _increment();
                },
        ),
      ],
    );
  }

  void _increment() {
    FocusScope.of(context).requestFocus(FocusNode());
    final val = _getValue();
    final r = val + 1;
    widget.controller.text = "$r";
  }

  void _decrement() {
    FocusScope.of(context).requestFocus(FocusNode());
    final val = _getValue();
    final r = val - 1;

    widget.controller.text = "$r";
  }

  int _getValue() {
    return _convertToInt(widget.controller.text);
  }

  int _convertToInt(String val) {
    if (val != null && val.isNotEmpty) {
      return int.tryParse(widget.controller.text) ?? widget.min ?? 0;
    }

    return widget.min ?? 0;
  }

  void _onChange() {
    final val = _getValue();

    if (widget.onChanged != null) {
      widget.onChanged(val);
    }

    setState(() {
      this.reachMax = _isMax(val);
      this.reachMin = _isMin(val);
    });
  }

  bool _isMin(int minus) => widget.min != null && minus <= widget.min;
  bool _isMax(int plus) => widget.max != null && plus >= widget.max;

  void _onFocusChanged() {
    if (!widget.focusNode.hasFocus) {
      if ((widget.controller.text == null || widget.controller.text.isEmpty) &&
          widget.min != null) {
        widget.controller.text = "${widget.min}";
      }
    }
  }
}

class _IconButton extends StatefulWidget {
  final Color buttonColor;
  final Color highlightColor;
  final Color disabledColor;
  final VoidCallback onPressed;
  final Color highlightedIconColor;
  final IconData icon;
  final Color iconColor;
  final Color splashColor;

  _IconButton(
      {@required this.icon,
      this.buttonColor,
      this.highlightColor,
      this.disabledColor,
      this.splashColor,
      this.highlightedIconColor = Colors.white,
      @required this.iconColor,
      this.onPressed});

  @override
  __IconButtonState createState() => __IconButtonState();
}

class __IconButtonState extends State<_IconButton> {
  bool _hasHighlighted = false;
  Color _iconColor;

  @override
  Widget build(BuildContext context) {
    if (_hasHighlighted) {
      _iconColor = widget.highlightedIconColor;
    } else if (widget.onPressed == null) {
      _iconColor = Colors.white;
    } else {
      _iconColor = widget.iconColor;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: widget.buttonColor ?? Theme.of(context).buttonColor,
      ),
      child: FlatButton(
        onHighlightChanged: (highlighted) {
          setState(() {
            _hasHighlighted = highlighted;
          });
        },
        padding: EdgeInsets.all(0),
        color: widget.buttonColor ?? Theme.of(context).buttonColor,
        highlightColor:
            widget.highlightColor ?? Theme.of(context).highlightColor,
        disabledColor: widget.buttonColor ?? Theme.of(context).buttonColor,
        splashColor: widget.splashColor ?? Theme.of(context).splashColor,
        onPressed: widget.onPressed,
        child: Icon(
          widget.icon,
          size: 18.0,
          color: _iconColor,
        ),
      ),
    );
  }
}
