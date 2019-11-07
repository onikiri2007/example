import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum TooltipDirection { up, down, left, right }
enum ClipAreaShape { oval, rectangle }
typedef OutSideTapHandler = void Function();

class BubbleTooltip extends StatefulWidget {
  ///
  /// The content of the Tooltip
  final Widget content;

  ///
  /// The direcion in which the tooltip should open
  final TooltipDirection popupDirection;

  ///
  /// [minWidth], [minHeight], [maxWidth], [maxHeight] optional size constraints.
  /// If a constraint is not set the size will ajust to the content
  final double minWidth, minHeight, maxWidth, maxHeight;

  ///
  /// The minium padding from the Tooltip to the screen limits
  final double minimumOutSidePadding;

  /// [top], [right], [bottom], [left] position the Tooltip absolute relative to the whole screen
  final double top, right, bottom, left;

  ///
  /// the stroke width of the border
  final double borderWidth;

  ///
  /// The corder radii of the border
  final double borderRadius;

  ///
  /// The color of the border
  final Color borderColor;

  ///
  /// The length of the Arrow
  final double arrowLength;

  ///
  /// The width of the arrow at its base
  final double arrowBaseWidth;

  ///
  /// The distance of the tip of the arrow's tip to the center of the target
  final double arrowTipDistance;

  ///
  /// The backgroundcolor of the Tooltip
  final Color backgroundColor;

  /// The color of the rest of the overlay surrounding the Tooltip.
  /// typically a translucent color.
  final Color outsideBackgroundColor;

  ///
  /// By default touching the surrounding of the Tooltip closes the tooltip.
  /// you can define a rectangle area where the background is completely transparent
  /// and the widgets below react to touch
  final Rect touchThrougArea;

  ///
  /// The shape of the [touchThrougArea].
  final ClipAreaShape touchThroughAreaShape;

  ///
  /// If [touchThroughAreaShape] is [ClipAreaShape.rectangle] you can define a border radius
  final double touchThroughAreaCornerRadius;

  ///
  /// key to the Tooltips container for UI Testing
  final Key tooltipContainerKey;

  /// whether to show tooltip or not
  final bool showTooltip;

  /// child widget to show below tooltop
  final Widget child;

  /// shadow settings
  final Iterable<BoxShadow> shadows;

  /// offset the center
  final Offset targetCentreOffset;

  final OutSideTapHandler onClose;

  BubbleTooltip({
    this.tooltipContainerKey,
    @required this.content, // The contents of the tooltip.
    @required this.child,
    @required this.popupDirection,
    this.showTooltip = false,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.minimumOutSidePadding = 20.0,
    this.shadows,
    this.borderWidth = 2.0,
    this.borderRadius = 10.0,
    this.borderColor = Colors.black,
    this.arrowLength = 20.0,
    this.arrowBaseWidth = 20.0,
    this.arrowTipDistance = 2.0,
    this.backgroundColor = Colors.white,
    this.outsideBackgroundColor = const Color.fromARGB(50, 255, 255, 255),
    this.touchThroughAreaShape = ClipAreaShape.oval,
    this.touchThroughAreaCornerRadius = 5.0,
    this.touchThrougArea,
    this.targetCentreOffset = const Offset(0.0, 0.0),
    this.onClose,
  })  : assert(popupDirection != null),
        assert(content != null),
        assert((maxWidth ?? double.infinity) >= (minWidth ?? 0.0)),
        assert((maxHeight ?? double.infinity) >= (minHeight ?? 0.0));

  _BubbleTooltipState createState() => _BubbleTooltipState();
}

class _BubbleTooltipState extends State<BubbleTooltip> {
  @override
  Widget build(BuildContext context) {
    return _TooltipAnchoredOverlay(
      showOverlay: widget.showTooltip,
      targetCentreOffset: widget.targetCentreOffset,
      backgroundOverlayBuilder:
          (BuildContext context, Rect rect, Offset anchored) {
        return GestureDetector(
          onTap: () {
            if (widget.onClose != null) {
              widget.onClose();
            }
          },
          child: _AnimationWrapper(builder: (context, opacity) {
            return AnimatedOpacity(
              duration: Duration(milliseconds: 250),
              opacity: opacity,
              child: Container(
                decoration: ShapeDecoration(
                    shape: _ShapeOverlay(
                        widget.touchThrougArea ?? rect,
                        widget.touchThroughAreaShape,
                        widget.touchThroughAreaCornerRadius,
                        widget.outsideBackgroundColor)),
              ),
            );
          }),
        );
      },
      overlayBuilder: (BuildContext context, Rect rect, Offset anchored) {
        return _AnimationWrapper(builder: (context, opacity) {
          return AnimatedOpacity(
            duration: Duration(milliseconds: 250),
            opacity: opacity,
            child: Center(
              child: CustomSingleChildLayout(
                  delegate: _PopupBallonLayoutDelegate(
                    popupDirection: widget.popupDirection,
                    targetCenter: anchored,
                    minWidth: widget.minWidth,
                    maxWidth: widget.maxWidth,
                    minHeight: widget.minHeight,
                    maxHeight: widget.maxHeight,
                    outSidePadding: widget.minimumOutSidePadding,
                    top: widget.top,
                    bottom: widget.bottom,
                    left: widget.left,
                    right: widget.right,
                  ),
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [_buildPopUp(anchored)],
                  )),
            ),
          );
        });
      },
      child: widget.child,
    );
  }

  Widget _buildPopUp(Offset anchor) {
    return Positioned(
      child: Container(
        key: widget.tooltipContainerKey,
        decoration: ShapeDecoration(
            color: widget.backgroundColor,
            shadows: widget.shadows,
            shape: _BubbleShape(
                widget.popupDirection,
                anchor,
                widget.borderRadius,
                widget.arrowBaseWidth,
                widget.arrowTipDistance,
                widget.borderColor,
                widget.borderWidth,
                widget.left,
                widget.top,
                widget.right,
                widget.bottom)),
        margin: _getBallonContainerMargin(),
        child: widget.content,
      ),
    );
  }

  EdgeInsets _getBallonContainerMargin() {
    var top = 0.0;

    switch (widget.popupDirection) {
      //
      case TooltipDirection.down:
        return EdgeInsets.only(
          top: widget.arrowTipDistance + widget.arrowLength,
        );

      case TooltipDirection.up:
        return EdgeInsets.only(
            bottom: widget.arrowTipDistance + widget.arrowLength, top: top);

      case TooltipDirection.left:
        return EdgeInsets.only(
            right: widget.arrowTipDistance + widget.arrowLength, top: top);

      case TooltipDirection.right:
        return EdgeInsets.only(
            left: widget.arrowTipDistance + widget.arrowLength, top: top);

      default:
        throw AssertionError(widget.popupDirection);
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _PopupBallonLayoutDelegate extends SingleChildLayoutDelegate {
  TooltipDirection _popupDirection;
  Offset _targetCenter;
  final double _minWidth;
  final double _maxWidth;
  final double _minHeight;
  final double _maxHeight;
  final double _top;
  final double _bottom;
  final double _left;
  final double _right;
  final double _outSidePadding;

  _PopupBallonLayoutDelegate({
    TooltipDirection popupDirection,
    Offset targetCenter,
    double minWidth,
    double maxWidth,
    double minHeight,
    double maxHeight,
    double outSidePadding,
    double top,
    double bottom,
    double left,
    double right,
  })  : _targetCenter = targetCenter,
        _popupDirection = popupDirection,
        _minWidth = minWidth,
        _maxWidth = maxWidth,
        _minHeight = minHeight,
        _maxHeight = maxHeight,
        _top = top,
        _bottom = bottom,
        _left = left,
        _right = right,
        _outSidePadding = outSidePadding;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double calcLeftMostXtoTarget() {
      double leftMostXtoTarget;
      if (_left != null) {
        leftMostXtoTarget = _left;
      } else if (_right != null) {
        leftMostXtoTarget = max(
            size.topLeft(Offset.zero).dx + _outSidePadding,
            size.topRight(Offset.zero).dx -
                _outSidePadding -
                childSize.width -
                _right);
      } else {
        leftMostXtoTarget = max(
            _outSidePadding,
            min(
                _targetCenter.dx - childSize.width / 2,
                size.topRight(Offset.zero).dx -
                    _outSidePadding -
                    childSize.width));
      }
      return leftMostXtoTarget;
    }

    double calcTopMostYtoTarget() {
      double topmostYtoTarget;
      if (_top != null) {
        topmostYtoTarget = _top;
      } else if (_bottom != null) {
        topmostYtoTarget = max(
            size.topLeft(Offset.zero).dy + _outSidePadding,
            size.bottomRight(Offset.zero).dy -
                _outSidePadding -
                childSize.height -
                _bottom);
      } else {
        topmostYtoTarget = max(
            _outSidePadding,
            min(
                _targetCenter.dy - childSize.height / 2,
                size.bottomRight(Offset.zero).dy -
                    _outSidePadding -
                    childSize.height));
      }
      return topmostYtoTarget;
    }

    switch (_popupDirection) {
      //
      case TooltipDirection.down:
        return new Offset(calcLeftMostXtoTarget(), _targetCenter.dy);

      case TooltipDirection.up:
        var top = _top ?? _targetCenter.dy - childSize.height;
        return new Offset(calcLeftMostXtoTarget(), top);

      case TooltipDirection.left:
        var left = _left ?? _targetCenter.dx - childSize.width;
        return new Offset(left, calcTopMostYtoTarget());

      case TooltipDirection.right:
        return new Offset(
          _targetCenter.dx,
          calcTopMostYtoTarget(),
        );

      default:
        throw AssertionError(_popupDirection);
    }
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    var calcMinWidth = _minWidth ?? 0.0;
    var calcMaxWidth = _maxWidth ?? double.infinity;
    var calcMinHeight = _minHeight ?? 0.0;
    var calcMaxHeight = _maxHeight ?? double.infinity;

    void calcMinMaxWidth() {
      if (_left != null && _right != null) {
        calcMaxWidth = constraints.maxWidth - (_left + _right);
      } else if ((_left != null && _right == null) ||
          (_left == null && _right != null)) {
        // make sure that the sum of left, right + maxwidth isn't bigger than the screen width.
        var sideDelta = (_left ?? 0.0) + (_right ?? 0.0) + _outSidePadding;
        if (calcMaxWidth > constraints.maxWidth - sideDelta) {
          calcMaxWidth = constraints.maxWidth - sideDelta;
        }
      } else {
        if (calcMaxWidth > constraints.maxWidth - 2 * _outSidePadding) {
          calcMaxWidth = constraints.maxWidth - 2 * _outSidePadding;
        }
      }
    }

    void calcMinMaxHeight() {
      if (_top != null && _bottom != null) {
        calcMaxHeight = constraints.maxHeight - (_top + _bottom);
      } else if ((_top != null && _bottom == null) ||
          (_top == null && _bottom != null)) {
        // make sure that the sum of top, bottom + maxHeight isn't bigger than the screen Height.
        var sideDelta = (_top ?? 0.0) + (_bottom ?? 0.0) + _outSidePadding;
        if (calcMaxHeight > constraints.maxHeight - sideDelta) {
          calcMaxHeight = constraints.maxHeight - sideDelta;
        }
      } else {
        if (calcMaxHeight > constraints.maxHeight - 2 * _outSidePadding) {
          calcMaxHeight = constraints.maxHeight - 2 * _outSidePadding;
        }
      }
    }

    switch (_popupDirection) {
      //
      case TooltipDirection.down:
        calcMinMaxWidth();
        if (_bottom != null) {
          calcMinHeight = calcMaxHeight =
              constraints.maxHeight - _bottom - _targetCenter.dy;
        } else {
          calcMaxHeight = min((_maxHeight ?? constraints.maxHeight),
                  constraints.maxHeight - _targetCenter.dy) -
              _outSidePadding;
        }
        break;

      case TooltipDirection.up:
        calcMinMaxWidth();

        if (_top != null) {
          calcMinHeight = calcMaxHeight = _targetCenter.dy - _top;
        } else {
          calcMaxHeight =
              min((_maxHeight ?? constraints.maxHeight), _targetCenter.dy) -
                  _outSidePadding;
        }
        break;

      case TooltipDirection.right:
        calcMinMaxHeight();
        if (_right != null) {
          calcMinWidth =
              calcMaxWidth = constraints.maxWidth - _right - _targetCenter.dx;
        } else {
          calcMaxWidth = min((_maxWidth ?? constraints.maxWidth),
                  constraints.maxWidth - _targetCenter.dx) -
              _outSidePadding;
        }
        break;

      case TooltipDirection.left:
        calcMinMaxHeight();
        if (_left != null) {
          calcMinWidth = calcMaxWidth = _targetCenter.dx - _left;
        } else {
          calcMaxWidth =
              min((_maxWidth ?? constraints.maxWidth), _targetCenter.dx) -
                  _outSidePadding;
        }
        break;

      default:
        throw AssertionError(_popupDirection);
    }

    var childConstraints = new BoxConstraints(
        minWidth: calcMinWidth > calcMaxWidth ? calcMaxWidth : calcMinWidth,
        maxWidth: calcMaxWidth,
        minHeight:
            calcMinHeight > calcMaxHeight ? calcMaxHeight : calcMinHeight,
        maxHeight: calcMaxHeight);

    return childConstraints;
  }

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) {
    return false;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _BubbleShape extends ShapeBorder {
  final Offset targetCenter;
  final double arrowBaseWidth;
  final double arrowTipDistance;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final double left, top, right, bottom;
  final TooltipDirection popupDirection;

  _BubbleShape(
      this.popupDirection,
      this.targetCenter,
      this.borderRadius,
      this.arrowBaseWidth,
      this.arrowTipDistance,
      this.borderColor,
      this.borderWidth,
      this.left,
      this.top,
      this.right,
      this.bottom);

  @override
  EdgeInsetsGeometry get dimensions => new EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return new Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    //
    double topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius;

    Path _getLeftTopPath(Rect rect) {
      return new Path()
        ..moveTo(rect.left, rect.bottom - bottomLeftRadius)
        ..lineTo(rect.left, rect.top + topLeftRadius)
        ..arcToPoint(Offset(rect.left + topLeftRadius, rect.top),
            radius: new Radius.circular(topLeftRadius))
        ..lineTo(rect.right - topRightRadius, rect.top)
        ..arcToPoint(Offset(rect.right, rect.top + topRightRadius),
            radius: new Radius.circular(topRightRadius), clockwise: true);
    }

    Path _getBottomRightPath(Rect rect) {
      return new Path()
        ..moveTo(rect.left + bottomLeftRadius, rect.bottom)
        ..lineTo(rect.right - bottomRightRadius, rect.bottom)
        ..arcToPoint(Offset(rect.right, rect.bottom - bottomRightRadius),
            radius: new Radius.circular(bottomRightRadius), clockwise: false)
        ..lineTo(rect.right, rect.top + topRightRadius)
        ..arcToPoint(Offset(rect.right - topRightRadius, rect.top),
            radius: new Radius.circular(topRightRadius), clockwise: false);
    }

    topLeftRadius = (left == 0 || top == 0) ? 0.0 : borderRadius;
    topRightRadius = (right == 0 || top == 0) ? 0.0 : borderRadius;
    bottomLeftRadius = (left == 0 || bottom == 0) ? 0.0 : borderRadius;
    bottomRightRadius = (right == 0 || bottom == 0) ? 0.0 : borderRadius;

    switch (popupDirection) {
      //

      case TooltipDirection.down:
        return _getBottomRightPath(rect)
          ..lineTo(
              min(
                  max(targetCenter.dx + arrowBaseWidth / 2,
                      rect.left + borderRadius + arrowBaseWidth),
                  rect.right - topRightRadius),
              rect.top)
          ..lineTo(targetCenter.dx,
              targetCenter.dy + arrowTipDistance) // up to arrow tip   \
          ..lineTo(
              max(
                  min(targetCenter.dx - arrowBaseWidth / 2,
                      rect.right - topLeftRadius - arrowBaseWidth),
                  rect.left + topLeftRadius),
              rect.top) //  down /

          ..lineTo(rect.left + topLeftRadius, rect.top)
          ..arcToPoint(Offset(rect.left, rect.top + topLeftRadius),
              radius: new Radius.circular(topLeftRadius), clockwise: false)
          ..lineTo(rect.left, rect.bottom - bottomLeftRadius)
          ..arcToPoint(Offset(rect.left + bottomLeftRadius, rect.bottom),
              radius: new Radius.circular(bottomLeftRadius), clockwise: false);

      case TooltipDirection.up:
        return _getLeftTopPath(rect)
          ..lineTo(rect.right, rect.bottom - bottomRightRadius)
          ..arcToPoint(Offset(rect.right - bottomRightRadius, rect.bottom),
              radius: new Radius.circular(bottomRightRadius), clockwise: true)
          ..lineTo(
              min(
                  max(targetCenter.dx + arrowBaseWidth / 2,
                      rect.left + bottomLeftRadius + arrowBaseWidth),
                  rect.right - bottomRightRadius),
              rect.bottom)

          // up to arrow tip   \
          ..lineTo(targetCenter.dx, targetCenter.dy - arrowTipDistance)

          //  down /
          ..lineTo(
              max(
                  min(targetCenter.dx - arrowBaseWidth / 2,
                      rect.right - bottomRightRadius - arrowBaseWidth),
                  rect.left + bottomLeftRadius),
              rect.bottom)
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          ..arcToPoint(Offset(rect.left, rect.bottom - bottomLeftRadius),
              radius: new Radius.circular(bottomLeftRadius), clockwise: true)
          ..lineTo(rect.left, rect.top + topLeftRadius)
          ..arcToPoint(Offset(rect.left + topLeftRadius, rect.top),
              radius: new Radius.circular(topLeftRadius), clockwise: true);

      case TooltipDirection.left:
        return _getLeftTopPath(rect)
          ..lineTo(
              rect.right,
              max(
                  min(targetCenter.dy - arrowBaseWidth / 2,
                      rect.bottom - bottomRightRadius - arrowBaseWidth),
                  rect.top + topRightRadius))
          ..lineTo(targetCenter.dx - arrowTipDistance,
              targetCenter.dy) // right to arrow tip   \
          //  left /
          ..lineTo(
              rect.right,
              min(targetCenter.dy + arrowBaseWidth / 2,
                  rect.bottom - bottomRightRadius))
          ..lineTo(rect.right, rect.bottom - borderRadius)
          ..arcToPoint(Offset(rect.right - bottomRightRadius, rect.bottom),
              radius: new Radius.circular(bottomRightRadius), clockwise: true)
          ..lineTo(rect.left + bottomLeftRadius, rect.bottom)
          ..arcToPoint(Offset(rect.left, rect.bottom - bottomLeftRadius),
              radius: new Radius.circular(bottomLeftRadius), clockwise: true);

      case TooltipDirection.right:
        return _getBottomRightPath(rect)
          ..lineTo(rect.left + topLeftRadius, rect.top)
          ..arcToPoint(Offset(rect.left, rect.top + topLeftRadius),
              radius: new Radius.circular(topLeftRadius), clockwise: false)
          ..lineTo(
              rect.left,
              max(
                  min(targetCenter.dy - arrowBaseWidth / 2,
                      rect.bottom - bottomLeftRadius - arrowBaseWidth),
                  rect.top + topLeftRadius))

          //left to arrow tip   /
          ..lineTo(targetCenter.dx + arrowTipDistance, targetCenter.dy)

          //  right \
          ..lineTo(
              rect.left,
              min(targetCenter.dy + arrowBaseWidth / 2,
                  rect.bottom - bottomLeftRadius))
          ..lineTo(rect.left, rect.bottom - bottomLeftRadius)
          ..arcToPoint(Offset(rect.left + bottomLeftRadius, rect.bottom),
              radius: new Radius.circular(bottomLeftRadius), clockwise: false);

      default:
        throw AssertionError(popupDirection);
    }
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    Paint paint = new Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(getOuterPath(rect), paint);
    paint = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    if (right == 0.0) {
      if (top == 0.0 && bottom == 0.0) {
        canvas.drawPath(
            new Path()
              ..moveTo(rect.right, rect.top)
              ..lineTo(rect.right, rect.bottom),
            paint);
      } else {
        canvas.drawPath(
            new Path()
              ..moveTo(rect.right, rect.top + borderWidth / 2)
              ..lineTo(rect.right, rect.bottom - borderWidth / 2),
            paint);
      }
    }
    if (left == 0.0) {
      if (top == 0.0 && bottom == 0.0) {
        canvas.drawPath(
            new Path()
              ..moveTo(rect.left, rect.top)
              ..lineTo(rect.left, rect.bottom),
            paint);
      } else {
        canvas.drawPath(
            new Path()
              ..moveTo(rect.left, rect.top + borderWidth / 2)
              ..lineTo(rect.left, rect.bottom - borderWidth / 2),
            paint);
      }
    }
    if (top == 0.0) {
      if (left == 0.0 && right == 0.0) {
        canvas.drawPath(
            new Path()
              ..moveTo(rect.right, rect.top)
              ..lineTo(rect.left, rect.top),
            paint);
      } else {
        canvas.drawPath(
            new Path()
              ..moveTo(rect.right - borderWidth / 2, rect.top)
              ..lineTo(rect.left + borderWidth / 2, rect.top),
            paint);
      }
    }
    if (bottom == 0.0) {
      if (left == 0.0 && right == 0.0) {
        canvas.drawPath(
            new Path()
              ..moveTo(rect.right, rect.bottom)
              ..lineTo(rect.left, rect.bottom),
            paint);
      } else {
        canvas.drawPath(
            new Path()
              ..moveTo(rect.right - borderWidth / 2, rect.bottom)
              ..lineTo(rect.left + borderWidth / 2, rect.bottom),
            paint);
      }
    }
  }

  @override
  ShapeBorder scale(double t) {
    return new _BubbleShape(
        popupDirection,
        targetCenter,
        borderRadius,
        arrowBaseWidth,
        arrowTipDistance,
        borderColor,
        borderWidth,
        left,
        top,
        right,
        bottom);
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _ShapeOverlay extends ShapeBorder {
  final Rect clipRect;
  final Color outsideBackgroundColor;
  final ClipAreaShape clipAreaShape;
  final double clipAreaCornerRadius;

  _ShapeOverlay(this.clipRect, this.clipAreaShape, this.clipAreaCornerRadius,
      this.outsideBackgroundColor);

  @override
  EdgeInsetsGeometry get dimensions => new EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return new Path()..addOval(clipRect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    Path outer = new Path()..addRect(rect);

    if (clipRect == null) {
      return outer;
    }
    Path exclusion;
    if (clipAreaShape == ClipAreaShape.oval) {
      exclusion = new Path()..addOval(clipRect);
    } else {
      exclusion = new Path()
        ..moveTo(clipRect.left + clipAreaCornerRadius, clipRect.top)
        ..lineTo(clipRect.right - clipAreaCornerRadius, clipRect.top)
        ..arcToPoint(
            Offset(clipRect.right, clipRect.top + clipAreaCornerRadius),
            radius: new Radius.circular(clipAreaCornerRadius))
        ..lineTo(clipRect.right, clipRect.bottom - clipAreaCornerRadius)
        ..arcToPoint(
            Offset(clipRect.right - clipAreaCornerRadius, clipRect.bottom),
            radius: new Radius.circular(clipAreaCornerRadius))
        ..lineTo(clipRect.left + clipAreaCornerRadius, clipRect.bottom)
        ..arcToPoint(
            Offset(clipRect.left, clipRect.bottom - clipAreaCornerRadius),
            radius: new Radius.circular(clipAreaCornerRadius))
        ..lineTo(clipRect.left, clipRect.top + clipAreaCornerRadius)
        ..arcToPoint(Offset(clipRect.left + clipAreaCornerRadius, clipRect.top),
            radius: new Radius.circular(clipAreaCornerRadius))
        ..close();
    }

    return Path.combine(ui.PathOperation.difference, outer, exclusion);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    canvas.drawPath(
        getOuterPath(rect), new Paint()..color = outsideBackgroundColor);
  }

  @override
  ShapeBorder scale(double t) {
    return new _ShapeOverlay(
        clipRect, clipAreaShape, clipAreaCornerRadius, outsideBackgroundColor);
  }
}

typedef TooltipBuilder = Widget Function(
    BuildContext, Rect anchorBounds, Offset anchor);

/// Displays an overlay Widget anchored directly above the center of this
/// [AnchoredOverlay].
///
/// The overlay Widget is created by invoking the provided [overlayBuilder].
///
/// The [anchor] position is provided to the [overlayBuilder], but the builder
/// does not have to respect it. In other words, the [overlayBuilder] can
/// interpret the meaning of "anchor" however it wants - the overlay will not
/// be forced to be centered about the [anchor].
///
/// The overlay built by this [AnchoredOverlay] can be conditionally shown
/// and hidden by settings the [showOverlay] property to true or false.
///
/// The [overlayBuilder] is invoked every time this Widget is rebuilt.
class _TooltipAnchoredOverlay extends StatelessWidget {
  final bool showOverlay;
  final TooltipBuilder overlayBuilder;
  final TooltipBuilder backgroundOverlayBuilder;
  final Widget child;
  final Offset targetCentreOffset;

  _TooltipAnchoredOverlay(
      {key,
      this.showOverlay,
      this.backgroundOverlayBuilder,
      this.overlayBuilder,
      this.child,
      this.targetCentreOffset})
      : super(key: key);

  Widget _buildOverlay(BuildContext targetContext, BuildContext overlayContext,
      TooltipBuilder builder) {
    RenderBox box = targetContext.findRenderObject() as RenderBox;
    final topLeft = box.size.topLeft(box.localToGlobal(const Offset(0.0, 0.0)));
    final bottomRight =
        box.size.bottomRight(box.localToGlobal(const Offset(0.0, 0.0)));
    final Rect anchorBounds = new Rect.fromLTRB(
      topLeft.dx,
      topLeft.dy,
      bottomRight.dx,
      bottomRight.dy,
    );

    final anchorCenter = box.size.center(topLeft);

    return builder(
        overlayContext,
        anchorBounds,
        Offset(anchorCenter.dx + targetCentreOffset.dx,
            anchorCenter.dy + targetCentreOffset.dy));
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      // This LayoutBuilder gives us the opportunity to measure the above
      // Container to calculate the "anchor" point at its center.
      child: new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return new TooltipOverlayBuilder(
            showOverlay: showOverlay,
            backgroundOverlayBuilder: (BuildContext overlayContext) {
              return _buildOverlay(
                  context, overlayContext, backgroundOverlayBuilder);
            },
            overlayBuilder: (BuildContext overlayContext) {
              return _buildOverlay(context, overlayContext, overlayBuilder);
            },
            child: child,
          );
        },
      ),
    );
  }
}

/// Displays an overlay Widget as constructed by the given [overlayBuilder].
///
/// The overlay built by the [overlayBuilder] can be conditionally shown
/// and hidden by settings the [showOverlay] property to true or false.
///
/// The [overlayBuilder] is invoked every time this Widget is rebuilt.
///
/// Implementation note: the reason we rebuild the overlay every time our
/// state changes is because there doesn't seem to be any better way to
/// invalidate the overlay itself than to invalidate this Widget. Remember,
/// overlay Widgets exist in [OverlayEntry]s which are inaccessible to
/// outside Widgets. But if a better approach is found then feel free to use it.
class TooltipOverlayBuilder extends StatefulWidget {
  final bool showOverlay;
  final Widget Function(BuildContext) overlayBuilder;
  final Widget Function(BuildContext) backgroundOverlayBuilder;
  final Widget child;

  TooltipOverlayBuilder({
    key,
    this.showOverlay,
    this.backgroundOverlayBuilder,
    this.overlayBuilder,
    this.child,
  }) : super(key: key);

  @override
  _TooltipOverlayBuilderState createState() =>
      new _TooltipOverlayBuilderState();
}

class _TooltipOverlayBuilderState extends State<TooltipOverlayBuilder> {
  OverlayEntry overlayEntry;
  OverlayEntry backgroundEntry;

  @override
  void initState() {
    if (widget.showOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showOverlay());
    }

    super.initState();
  }

  @override
  void didUpdateWidget(TooltipOverlayBuilder oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
    super.didUpdateWidget(oldWidget);
  }

  @override
  void reassemble() {
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
    super.reassemble();
  }

  @override
  void dispose() {
    if (isShowingOverlay()) {
      hideOverlay();
    }

    super.dispose();
  }

  bool isShowingOverlay() => overlayEntry != null && backgroundEntry != null;

  void showOverlay() {
    if (overlayEntry == null || backgroundEntry == null) {
      if (backgroundEntry == null) {
        backgroundEntry = new OverlayEntry(
          builder: widget.backgroundOverlayBuilder,
        );
      }

      if (overlayEntry == null) {
        overlayEntry = new OverlayEntry(
          builder: widget.overlayBuilder,
        );
      }

      addToOverlays(<OverlayEntry>[backgroundEntry, overlayEntry]);
    } else {
      buildOverlay();
    }
  }

  void addToOverlays(Iterable<OverlayEntry> overlayEntries) async {
    Overlay.of(context).insertAll(overlayEntries);
  }

  void addToOverlay(OverlayEntry overlay) async {
    Overlay.of(context).insert(overlay);
  }

  void hideOverlay() {
    if (backgroundEntry != null) {
      backgroundEntry.remove();
      backgroundEntry = null;
    }

    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }

  void syncWidgetAndOverlay() {
    if (isShowingOverlay() && !widget.showOverlay) {
      hideOverlay();
    } else if (!isShowingOverlay() && widget.showOverlay) {
      showOverlay();
    }
  }

  void buildOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      backgroundEntry?.markNeedsBuild();
      overlayEntry?.markNeedsBuild();
    });
  }

  @override
  Widget build(BuildContext context) {
    buildOverlay();
    return widget.child;
  }
}

typedef FadeBuilder = Widget Function(BuildContext, double);

////////////////////////////////////////////////////////////////////////////////////////////////////

class _AnimationWrapper extends StatefulWidget {
  final FadeBuilder builder;

  _AnimationWrapper({this.builder});

  @override
  _AnimationWrapperState createState() => new _AnimationWrapperState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _AnimationWrapperState extends State<_AnimationWrapper> {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          opacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, opacity);
  }
}
