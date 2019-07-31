import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'animation_status_action.dart';
import 'arc_painter.dart';
import 'circle_display_part.dart';
import 'circle_painter.dart';

typedef CircleDisplayAnimationStatusListener = void Function(
    AnimationStatusActions actions);

class CircleDisplay extends StatefulWidget {
  _CircleDisplayState state;

  @override
  State<StatefulWidget> createState() => state;

  CircleDisplay({
    String unit = "%",
    double startAngle = 270,
    double valueWidthPercent = 50,
    NumberFormat formatValue,
    List<String> customText = const [],
    double textFontSize = 24,
    Duration animationDuration = const Duration(milliseconds: 6000),
    Map<AnimationStatus, CircleDisplayAnimationStatusListener>
        animationStatusListener,
    bool drawBackCircle = true,
    bool drawInnerCircle = true,
    bool drawArc = true,
    bool drawText = true,
    Color backCircleColor = const Color.fromRGBO(0, 255, 0, 1),
    Color innerCircleColor = Colors.white,
    Color arcColor = const Color.fromRGBO(255, 0, 0, 1),
    Color textColor = Colors.black,
    int backCircleAlpha = 80,
    int innerCircleAlpha = 80,
    int arcAlpha = 80,
    int textAlpha = 80,
  }) {
    AnimationStatus.values.forEach((AnimationStatus status) {
      if (!animationStatusListener.containsKey(status)) {
        animationStatusListener[status] =
            (AnimationStatusActions animationStatusActions) {};
      }
    });
    formatValue ??= NumberFormat("###,###,###,##0.0");

    Map<CircleDisplayPart, Paint> paints = {
      CircleDisplayPart.BACK_CIRCLE: new Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..color = backCircleColor
        ..color.withAlpha(backCircleAlpha),
      CircleDisplayPart.ARC: new Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..color = arcColor
        ..color.withAlpha(arcAlpha),
      CircleDisplayPart.INNER_CIRCLE: new Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill
        ..color = innerCircleColor
        ..color.withAlpha(innerCircleAlpha),
      CircleDisplayPart.TEXT: new Paint()
        ..color = textColor
        ..color.withAlpha(textAlpha)
    };
    Map<CircleDisplayPart, bool> drawPart = {
      CircleDisplayPart.BACK_CIRCLE: drawBackCircle,
      CircleDisplayPart.INNER_CIRCLE: drawInnerCircle,
      CircleDisplayPart.ARC: drawArc,
      CircleDisplayPart.TEXT: drawText
    };
    state = _CircleDisplayState(
        unit,
        startAngle,
        valueWidthPercent,
        formatValue,
        customText,
        textFontSize,
        animationDuration,
        animationStatusListener,
        drawPart,
        paints);
  }
}

class _CircleDisplayState extends State<CircleDisplay>
    with SingleTickerProviderStateMixin {
  /// the unit that is represented by the circle-display
  String _unit;

  /// start angle of the view
  double _startAngle;

  /// angle that represents the displayed value
  double _angle = 0;

  /// percent of the maximum width the arc takes
  double _valueWidthPercent;

  /// the decimalformat responsible for formatting the values in the view
  NumberFormat _formatValue = NumberFormat("###,###,###,##0.0");

  /// array that contains values for the custom-text
  List<String> _customText;

  /// the arc drawing animations
  Animation<double> _animation;

  /// a controller for the animation
  AnimationController _animationController;

  /// boolean flag that indicates if the box has been setup
  bool _boxSetup = false;

  /// the size of the text in the inner circle
  double _textFontSize;

  /// the duration of the animation
  Duration _animationDuration;

  /// the listener for the animation status
  Map<AnimationStatus, CircleDisplayAnimationStatusListener>
      _animationStatusListener;

  /// represent if each part is drawn
  Map<CircleDisplayPart, bool> _drawParts = {
    CircleDisplayPart.BACK_CIRCLE: true,
    CircleDisplayPart.INNER_CIRCLE: true,
    CircleDisplayPart.ARC: true,
    CircleDisplayPart.TEXT: true,
  };

  /// represents the paint used for each part
  Map<CircleDisplayPart, Paint> _paints = {
    CircleDisplayPart.BACK_CIRCLE: null,
    CircleDisplayPart.INNER_CIRCLE: null,
    CircleDisplayPart.ARC: null,
    CircleDisplayPart.TEXT: null,
  };

  _CircleDisplayState(
      this._unit,
      this._startAngle,
      this._valueWidthPercent,
      this._formatValue,
      this._customText,
      this._textFontSize,
      this._animationDuration,
      this._animationStatusListener,
      this._drawParts,
      this._paints);

  @override
  void initState() {
    _animation = Tween(begin: 0.0, end: 360.0).animate(
        _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    ))
      ..addListener(() {
        setState(() {
          _angle = _animation.value;
        });
      })
      ..addStatusListener((AnimationStatus status) {
        _animationStatusListener[status](
            AnimationStatusActions(this.restartAnimation, this.stopAnimation));
      });
    _animationController.forward();
    super.initState();
  }

  void restartAnimation(
      {Direction direction = Direction.FORWARD,
      Map<CircleDisplayPart, Color> colors}) {
    setState(() {
      colors ??= Map.fromIterable(CircleDisplayPart.values,
          value: (part) => part, key: (part) => null);
      colors.forEach((CircleDisplayPart part, Color color) {
        if (color != null) {
          _paints[part].color = color;
        }
      });
      switch (direction) {
        case Direction.FORWARD:
          _animationController.reset();
          _animationController.forward();
          return;
        case Direction.BACKWARD:
          _animationController.animateBack(_startAngle);
          return;
      }
    });
  }

  void stopAnimation() {
    _animationController.stop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_boxSetup) {
      _boxSetup = true;
      _setupBox();
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Center(
        child: Stack(
          children: <Widget>[
            !isDrawPartEnabled(CircleDisplayPart.ARC)
                ? null
                : Center(
                    child: CustomPaint(
                      foregroundPainter: CirclePainter(
                          getRadius(_boxConstraintsToSize(constraints)),
                          _paints[CircleDisplayPart.BACK_CIRCLE]),
                    ),
                  ),
            !isDrawPartEnabled(CircleDisplayPart.ARC)
                ? null
                : CustomPaint(
                    foregroundPainter: ArcPainter(
                        _getCircleBox(_boxConstraintsToSize(constraints)),
                        _startAngle,
                        _angle,
                        _paints[CircleDisplayPart.ARC]),
                  ),
            !isDrawPartEnabled(CircleDisplayPart.INNER_CIRCLE)
                ? null
                : Center(
                    child: CustomPaint(
                      foregroundPainter: CirclePainter(
                          getRadius(_boxConstraintsToSize(constraints)) /
                              100 *
                              (100 - _valueWidthPercent),
                          _paints[CircleDisplayPart.INNER_CIRCLE]),
                    ),
                  ),
            !isDrawPartEnabled(CircleDisplayPart.TEXT)
                ? null
                : Center(
                    child: _getTextWidget(),
                  ),
          ],
        ),
      );
    });
  }

  /// sets up the bounds of the view
  void _setupBox() {}

  ///draws the text in the center of the view
  Widget _getTextWidget() {
    return Text(
      _getText(),
      style: TextStyle(
        color: getColor(CircleDisplayPart.TEXT)
            .withAlpha(getAlpha(CircleDisplayPart.TEXT)),
        fontSize: _textFontSize,
      ),
    );
  }

  /// draws the custom text in the center of the view
  String _getText() {
    if (_customText.length == 0)
      return _formatValue.format(getAngle()) + " " + _unit;
    return _customText[
        (getAngle() * _customText.length / 360).floor() % _customText.length];
  }

  Rect _getCircleBox(Size size) {
    double diameter = getDiameter(size);
    return Rect.fromLTWH(
      size.width / 2 - diameter / 2,
      size.height / 2 - diameter / 2,
      diameter,
      diameter,
    );
  }

  /// returns the diameter of the drawn circle/arc
  double getDiameter(Size size) {
    return min(size.width, size.height);
  }

  /// returns the radius of the drawn circle
  double getRadius(Size size) {
    return getDiameter(size) / 2;
  }

  /// get size from BoxConstraints
  Size _boxConstraintsToSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  /// Returns the currently displayed value from the view. Depending on the
  /// used method to show the value, this value can be percent or actual value.
  double getAngle() {
    return _angle;
  }

  /// returns true if drawing the given part is enabled, false if not
  bool isDrawPartEnabled(CircleDisplayPart part) {
    return _drawParts[part];
  }

  /// returns the color of the given part
  Color getColor(CircleDisplayPart part) {
    return _paints[part].color;
  }

  /// returns the color of the given part
  int getAlpha(CircleDisplayPart part) {
    return _paints[part].color.alpha;
  }

  /// returns the center point of the view in pixels
  Point getCenter() {
    return Point(_getWidth() / 2, _getHeight() / 2);
  }

  /// returns the width of the CircleDisplay
  double _getWidth() {
    return _getWidgetSize(context).width;
  }

  /// returns the height of the CircleDisplay
  double _getHeight() {
    return _getWidgetSize(context).height;
  }

  /// returns the size of the given context widget
  Size _getWidgetSize(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject();
    Offset offset = renderBox.localToGlobal(Offset.zero);
    return Size(offset.dx, offset.dy);
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }
}
