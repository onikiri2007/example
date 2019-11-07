// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/theme/themes.dart';

const TextStyle _kStepStyle = TextStyle(
  fontSize: 12.0,
  color: Colors.white,
);
const Color _kErrorLight = Colors.red;
final Color _kErrorDark = Colors.red.shade400;
const Color _kCircleActiveLight = Colors.white;
const Color _kCircleActiveDark = Colors.black87;
const double _kStepSize = 24.0;
const double _kTriangleHeight =
    _kStepSize * 0.866025; // Triangle height. sqrt(3.0) / 2.0

class YodelStepper extends StatefulWidget {
  /// Creates a stepper from a list of steps.
  ///
  /// This widget is not meant to be rebuilt with a different list of steps
  /// unless a key is provided in order to distinguish the old stepper from the
  /// new one.
  ///
  /// The [steps], [type], and [currentStep] arguments must not be null.
  YodelStepper({
    Key key,
    @required this.steps,
    this.physics,
    this.type = StepperType.vertical,
    this.currentStep = 0,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
    this.controlsBuilder,
    this.activeColor,
    this.disabledColor,
    this.lineHeight = 1.0,
    this.defaultColor,
    this.labelStyle,
    this.activeLabelStyle,
    this.iconColor,
  })  : assert(steps != null),
        assert(type != null),
        assert(currentStep != null),
        assert(0 <= currentStep && currentStep < steps.length),
        assert(activeColor != null),
        assert(disabledColor != null),
        assert(labelStyle != null),
        assert(defaultColor != null),
        assert(activeLabelStyle != null),
        super(key: key);

  /// The steps of the stepper whose titles, subtitles, icons always get shown.
  ///
  /// The length of [steps] must not change.
  final List<Step> steps;

  /// How the stepper's scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to
  /// animate after the user stops dragging the scroll view.
  ///
  /// If the stepper is contained within another scrollable it
  /// can be helpful to set this property to [ClampingScrollPhysics].
  final ScrollPhysics physics;

  /// The type of stepper that determines the layout. In the case of
  /// [StepperType.horizontal], the content of the current step is displayed
  /// underneath as opposed to the [StepperType.vertical] case where it is
  /// displayed in-between.
  final StepperType type;

  /// The index into [steps] of the current step whose content is displayed.
  final int currentStep;

  /// The callback called when a step is tapped, with its index passed as
  /// an argument.
  final ValueChanged<int> onStepTapped;

  /// The callback called when the 'continue' button is tapped.
  ///
  /// If null, the 'continue' button will be disabled.
  final VoidCallback onStepContinue;

  /// The callback called when the 'cancel' button is tapped.
  ///
  /// If null, the 'cancel' button will be disabled.
  final VoidCallback onStepCancel;

  /// The callback for creating custom controls.
  ///
  /// If null, the default controls from the current theme will be used.
  ///
  /// This callback which takes in a context and two functions,[onStepContinue]
  /// and [onStepCancel]. These can be used to control the stepper.
  ///
  /// {@tool snippet --template=stateless_widget_scaffold}
  /// Creates a stepper control with custom buttons.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return Stepper(
  ///     controlsBuilder:
  ///       (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
  ///          return Row(
  ///            children: <Widget>[
  ///              FlatButton(
  ///                onPressed: onStepContinue,
  ///                child: const Text('CONTINUE'),
  ///              ),
  ///              FlatButton(
  ///                onPressed: onStepCancel,
  ///                child: const Text('CANCEL'),
  ///              ),
  ///            ],
  ///          );
  ///       },
  ///     steps: const <Step>[
  ///       Step(
  ///         title: Text('A'),
  ///         content: SizedBox(
  ///           width: 100.0,
  ///           height: 100.0,
  ///         ),
  ///       ),
  ///       Step(
  ///         title: Text('B'),
  ///         content: SizedBox(
  ///           width: 100.0,
  ///           height: 100.0,
  ///         ),
  ///       ),
  ///     ],
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  final ControlsWidgetBuilder controlsBuilder;

  final Color activeColor;
  final Color defaultColor;
  final double lineHeight;
  final Color disabledColor;
  final TextStyle labelStyle;
  final TextStyle activeLabelStyle;
  final Color iconColor;

  @override
  _YodelStepperState createState() => _YodelStepperState();
}

class _YodelStepperState extends State<YodelStepper>
    with TickerProviderStateMixin, PostBuildActionMixin {
  List<GlobalKey> _keys;
  final Map<int, StepState> _oldStates = <int, StepState>{};
  var hasCalculatedSize = false;
  @override
  void initState() {
    super.initState();
    _keys = List<GlobalKey>.generate(
      widget.steps.length,
      (int i) => GlobalKey(),
    );

    for (int i = 0; i < widget.steps.length; i += 1) {
      _oldStates[i] = widget.steps[i].state;
    }

    onWidgetDidBuild(() {
      if (!hasCalculatedSize) {
        setState(() {
          final size = _getSize(0);
          hasCalculatedSize = size != null;
        });
      }
    });
  }

  @override
  void didUpdateWidget(YodelStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.steps.length == oldWidget.steps.length);

    for (int i = 0; i < oldWidget.steps.length; i += 1)
      _oldStates[i] = oldWidget.steps[i].state;
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.steps.length - 1 == index;
  }

  bool _isCurrent(int index) {
    return widget.currentStep == index;
  }

  bool _isDark() {
    return Theme.of(context).brightness == Brightness.dark;
  }

  double _circleSize() {
    return widget.lineHeight + _kStepSize;
  }

  Widget _buildLine(bool visible) {
    return Container(
      width: visible ? 1.0 : 0.0,
      height: 16.0,
      color: Colors.grey.shade400,
    );
  }

  Widget _buildCircleChild(int index, bool oldState) {
    final StepState state =
        oldState ? _oldStates[index] : widget.steps[index].state;
    final bool isDarkActive = _isDark() && widget.steps[index].isActive;
    assert(state != null);
    switch (state) {
      case StepState.indexed:
      case StepState.disabled:
        return Text(
          '',
          style: isDarkActive
              ? _kStepStyle.copyWith(color: Colors.black87)
              : _kStepStyle,
        );
      case StepState.editing:
        return Icon(
          Icons.edit,
          color: widget.iconColor ??
              (isDarkActive ? _kCircleActiveDark : _kCircleActiveLight),
          size: 18.0,
        );
      case StepState.complete:
        return Icon(
          YodelIcons.tick,
          color: widget.iconColor ??
              (isDarkActive ? _kCircleActiveDark : _kCircleActiveLight),
          size: 8.0,
        );
      case StepState.error:
        return const Text('!', style: _kStepStyle);
    }
    return null;
  }

  Color _circleColor(int index) {
    assert(widget.steps[index].state != null);

    if (widget.steps[index].isActive) {
      switch (widget.steps[index].state) {
        case StepState.complete:
          return widget.activeColor;
        case StepState.indexed:
        case StepState.editing:
        case StepState.disabled:
        case StepState.error:
          return Colors.transparent;
      }
    }

    return Colors.transparent;
  }

  Color _circleBorderColor(int index) {
    assert(widget.steps[index].state != null);
    if (widget.steps[index].isActive) {
      switch (widget.steps[index].state) {
        case StepState.complete:
          return widget.activeColor;
        case StepState.indexed:
        case StepState.editing:
          return widget.activeColor;
        case StepState.disabled:
          return widget.disabledColor;
        case StepState.error:
          return _isDark() ? _kErrorDark : _kErrorLight;
      }
    }

    return widget.disabledColor ?? Colors.grey.shade400;
  }

  Color _lineColor(int index) {
    assert(widget.steps[index].state != null);
    if (widget.steps[index].isActive) {
      switch (widget.steps[index].state) {
        case StepState.complete:
          return widget.activeColor;
        case StepState.indexed:
        case StepState.editing:
          return widget.disabledColor;
        case StepState.disabled:
          return widget.disabledColor;
        case StepState.error:
          return widget.disabledColor;
      }
    }

    return widget.disabledColor ?? Colors.grey.shade400;
  }

  Widget _buildCircle(int index, bool oldState) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 4),
      width: _circleSize(),
      height: _circleSize(),
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: kThemeAnimationDuration,
        decoration: BoxDecoration(
          color: _circleColor(index),
          border: Border.all(
            width: widget.lineHeight,
            color: _circleBorderColor(index),
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: _buildCircleChild(
              index, oldState && widget.steps[index].state == StepState.error),
        ),
      ),
    );
  }

  Widget _buildTriangle(int index, bool oldState) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: _kStepSize,
      height: _kStepSize,
      child: Center(
        child: SizedBox(
          width: _kStepSize,
          height:
              _kTriangleHeight, // Height of 24dp-long-sided equilateral triangle.
          child: CustomPaint(
            painter: _TrianglePainter(
              color: _isDark() ? _kErrorDark : _kErrorLight,
            ),
            child: Align(
              alignment: const Alignment(
                  0.0, 0.8), // 0.8 looks better than the geometrical 0.33.
              child: _buildCircleChild(index,
                  oldState && widget.steps[index].state != StepState.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(int index) {
    if (widget.steps[index].state != _oldStates[index]) {
      return AnimatedCrossFade(
        firstChild: _buildCircle(index, true),
        secondChild: _buildTriangle(index, true),
        firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.fastOutSlowIn,
        crossFadeState: widget.steps[index].state == StepState.error
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: kThemeAnimationDuration,
      );
    } else {
      if (widget.steps[index].state != StepState.error)
        return _buildCircle(index, false);
      else
        return _buildTriangle(index, false);
    }
  }

  Widget _buildVerticalControls() {
    if (widget.controlsBuilder != null)
      return widget.controlsBuilder(context,
          onStepContinue: widget.onStepContinue,
          onStepCancel: widget.onStepCancel);

    Color cancelColor;

    switch (Theme.of(context).brightness) {
      case Brightness.light:
        cancelColor = Colors.black54;
        break;
      case Brightness.dark:
        cancelColor = Colors.white70;
        break;
    }

    assert(cancelColor != null);

    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: 48.0),
        child: Row(
          children: <Widget>[
            FlatButton(
              onPressed: widget.onStepContinue,
              color: _isDark()
                  ? themeData.backgroundColor
                  : themeData.primaryColor,
              textColor: Colors.white,
              textTheme: ButtonTextTheme.normal,
              child: Text(localizations.continueButtonLabel),
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 8.0),
              child: FlatButton(
                onPressed: widget.onStepCancel,
                textColor: cancelColor,
                textTheme: ButtonTextTheme.normal,
                child: Text(localizations.cancelButtonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _titleStyle(int index) {
    assert(widget.steps[index].state != null);
    switch (widget.steps[index].state) {
      case StepState.indexed:
        return widget.steps[index].isActive
            ? widget.activeLabelStyle
            : widget.labelStyle;
      case StepState.editing:
      case StepState.complete:
      case StepState.disabled:
        return widget.labelStyle.copyWith(color: widget.disabledColor);
      case StepState.error:
        return widget.labelStyle
            .copyWith(color: _isDark() ? _kErrorDark : _kErrorLight);
    }
    return null;
  }

  TextStyle _subtitleStyle(int index) {
    assert(widget.steps[index].state != null);
    switch (widget.steps[index].state) {
      case StepState.indexed:
        return widget.steps[index].isActive
            ? widget.activeLabelStyle
            : widget.labelStyle;
      case StepState.editing:
      case StepState.complete:
      case StepState.disabled:
        return widget.labelStyle.copyWith(color: widget.disabledColor);
      case StepState.error:
        return widget.labelStyle
            .copyWith(color: _isDark() ? _kErrorDark : _kErrorLight);
    }
    return null;
  }

  Widget _buildHeaderText(int index) {
    final List<Widget> children = <Widget>[
      AnimatedDefaultTextStyle(
        style: _titleStyle(index),
        duration: kThemeAnimationDuration,
        curve: Curves.fastOutSlowIn,
        child: widget.steps[index].title,
      ),
    ];

    if (widget.steps[index].subtitle != null)
      children.add(
        Container(
          margin: const EdgeInsets.only(top: 2.0),
          child: AnimatedDefaultTextStyle(
            style: _subtitleStyle(index),
            duration: kThemeAnimationDuration,
            curve: Curves.fastOutSlowIn,
            child: widget.steps[index].subtitle,
          ),
        ),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildVerticalHeader(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              // Line parts are always added in order for the ink splash to
              // flood the tips of the connector lines.
              _buildLine(!_isFirst(index)),
              _buildIcon(index),
              _buildLine(!_isLast(index)),
            ],
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(start: 12.0),
            child: _buildHeaderText(index),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBody(int index) {
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          start: 24.0,
          top: 0.0,
          bottom: 0.0,
          child: SizedBox(
            width: 24.0,
            child: Center(
              child: SizedBox(
                width: _isLast(index) ? 0.0 : 1.0,
                child: Container(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(height: 0.0),
          secondChild: Container(
            margin: const EdgeInsetsDirectional.only(
              start: 60.0,
              end: 24.0,
              bottom: 24.0,
            ),
            child: Column(
              children: <Widget>[
                widget.steps[index].content,
                _buildVerticalControls(),
              ],
            ),
          ),
          firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
          secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          sizeCurve: Curves.fastOutSlowIn,
          crossFadeState: _isCurrent(index)
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: kThemeAnimationDuration,
        ),
      ],
    );
  }

  Widget _buildVertical() {
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < widget.steps.length; i += 1) {
      children.add(Column(
        key: _keys[i],
        children: <Widget>[
          InkWell(
            onTap: widget.steps[i].state != StepState.disabled
                ? () {
                    // In the vertical case we need to scroll to the newly tapped
                    // step.
                    Scrollable.ensureVisible(
                      _keys[i].currentContext,
                      curve: Curves.fastOutSlowIn,
                      duration: kThemeAnimationDuration,
                    );

                    if (widget.onStepTapped != null) widget.onStepTapped(i);
                  }
                : null,
            child: _buildVerticalHeader(i),
          ),
          _buildVerticalBody(i),
        ],
      ));
    }

    return ListView(
      shrinkWrap: true,
      physics: widget.physics,
      children: children,
    );
  }

  Size _getSize(int i) {
    final renderedBox =
        _keys[i].currentContext?.findRenderObject() as RenderBox;
    return renderedBox?.size;
  }

  final double _kStepContainerSize = 80;
  Widget _buildHorizontal() {
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < widget.steps.length; i += 1) {
      children.add(
        InkResponse(
          onTap: widget.steps[i].state != StepState.disabled
              ? () {
                  if (widget.onStepTapped != null) widget.onStepTapped(i);
                }
              : null,
          child: Container(
            key: _keys[i],
            height: _kStepContainerSize,
            child: LayoutBuilder(
              builder: (context, constraints) {
                List<Widget> widgets = [];
                double width = 0;
                if (hasCalculatedSize) {
                  width = _getSize(i).width / 2;
                }

                if (_isFirst(i)) {
                  widgets.add(Positioned(
                    left: width + _circleSize() / 2,
                    bottom: _kStepContainerSize / 2 + 5,
                    child: Container(
                      width: width,
                      height: widget.lineHeight,
                      color: _lineColor(i),
                    ),
                  ));
                }

                if (_isLast(i)) {
                  widgets.add(Positioned(
                    right: width + _circleSize() / 2,
                    bottom: _kStepContainerSize / 2 + 5,
                    child: Container(
                      width: width,
                      height: widget.lineHeight,
                      color: _lineColor(i - 1),
                    ),
                  ));
                }

                if (!_isFirst(i) && !_isLast(i)) {
                  widgets.add(Positioned(
                    left: width + _circleSize() / 2,
                    bottom: _kStepContainerSize / 2 + 5,
                    child: Container(
                      width: width,
                      height: widget.lineHeight,
                      color: _lineColor(i),
                    ),
                  ));
                  widgets.add(Positioned(
                    right: width + _circleSize() / 2,
                    bottom: _kStepContainerSize / 2 + 5,
                    child: Container(
                      width: width,
                      height: widget.lineHeight,
                      color: _lineColor(i - 1),
                    ),
                  ));
                }

                widgets.add(Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: _buildIcon(i),
                    ),
                    Container(
                      child: _buildHeaderText(i),
                    ),
                  ],
                ));

                return Stack(children: widgets);
              },
            ),
          ),
        ),
      );

      if (!_isLast(i)) {
        children.add(
          Expanded(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                  bottom: (_kStepSize / 2) + widget.lineHeight - 2),
              height: widget.lineHeight,
              color: _lineColor(i),
            ),
          ),
        );
      }
    }

    return Column(
      children: <Widget>[
        Material(
          color: Colors.transparent,
          elevation: 0.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: children,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: <Widget>[
              AnimatedSize(
                curve: Curves.fastOutSlowIn,
                duration: kThemeAnimationDuration,
                vsync: this,
                child: widget.steps[widget.currentStep].content,
              ),
              _buildVerticalControls(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(() {
      if (context.ancestorWidgetOfExactType(Stepper) != null)
        throw FlutterError(
            'Steppers must not be nested. The material specification advises '
            'that one should avoid embedding steppers within steppers. '
            'https://material.io/archive/guidelines/components/steppers.html#steppers-usage\n');
      return true;
    }());
    assert(widget.type != null);
    switch (widget.type) {
      case StepperType.vertical:
        return _buildVertical();
      case StepperType.horizontal:
        return _buildHorizontal();
    }
    return null;
  }
}

// Paints a triangle whose base is the bottom of the bounding rectangle and its
// top vertex the middle of its top.
class _TrianglePainter extends CustomPainter {
  _TrianglePainter({
    this.color,
  });

  final Color color;

  @override
  bool hitTest(Offset point) => true; // Hitting the rectangle is fine enough.

  @override
  bool shouldRepaint(_TrianglePainter oldPainter) {
    return oldPainter.color != color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double base = size.width;
    final double halfBase = size.width / 2.0;
    final double height = size.height;
    final List<Offset> points = <Offset>[
      Offset(0.0, height),
      Offset(base, height),
      Offset(halfBase, 0.0),
    ];

    canvas.drawPath(
      Path()..addPolygon(points, true),
      Paint()..color = color,
    );
  }
}
