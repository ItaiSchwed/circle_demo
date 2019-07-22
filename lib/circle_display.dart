import 'dart:core';
import 'dart:math';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'circle_display_part.dart';

import 'arc_painter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'circle_painter.dart';

class CircleDisplay extends StatefulWidget {
  static const _LOG_TAG = "CircleDisplay";
  _CircleDisplayState state;

  @override
  State<StatefulWidget> createState() => state;

  CircleDisplay({
    String unit = "%",
    double startAngle = 270,
    double phase = 0,
    double textFontSize = 24,
    double valueWidthPercent = 50,
    List<String> customText = const [],
    double stepSize = 1,
    Duration animationDuration = const Duration(milliseconds: 3000),
    VoidCallback animationListener,
    AnimationStatusListener animationStatusListener,
    int formatDigits = 0,
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
    animationListener ??= (){};
    animationStatusListener ??= (AnimationStatus status){};
    state = _CircleDisplayState(
      unit,
      startAngle,
      phase,
      textFontSize,
      valueWidthPercent,
      customText,
      stepSize,
      animationListener,
      animationStatusListener,
      animationDuration,
      formatDigits,
      drawBackCircle,
      drawInnerCircle,
      drawArc,
      drawText,
      backCircleColor,
      innerCircleColor,
      arcColor,
      textColor,
      backCircleAlpha,
      innerCircleAlpha,
      arcAlpha,
      textAlpha,
    );
  }

  ///SETTERS

  /// Sets the unit that is displayed next to the value in the center of the
  /// view. Default "%". Could be "€" or "$" or left blank or whatever it is
  /// you display.
  void setUnit(String unit) => state.setUnit(unit);

  /// set the duration of the drawing animation in milliseconds
  void setAnimationDuration(int durationMillis) =>
      state.setAnimationDuration(durationMillis);

  /// set the starting angle for the view
  void setStartAngle(double angle) => state.setStartAngle(angle);

  /// set the phase
  void setPhase(double phase) => state.setPhase(phase);

  /// set the size of the center text in dp
  void setTextSize(double size) => state.setTextSize(size);

  /// set the thickness of the value bar, default 50%
  void setValueWidthPercent(double percentFromTotalWidth) =>
      state.setValueWidthPercent(percentFromTotalWidth);

  /// Set an array of custom texts to be drawn instead of the value in the
  /// center of the CircleDisplay. If set to null, the custom text will be
  /// reset and the value will be drawn. Make sure the length of the array
  /// corresponds with the maximum number of steps (set with setStepSize(double stepSize).
  void setCustomText(List<String> custom) => state.setCustomText(custom);

  /// sets the number of digits used to format values
  void setFormatDigits(int digits) => state.setFormatDigits(digits);

  /// Sets the stepsize (minimum selection interval) of the circle display,
  /// default 1f. It is recommended to make this value not higher than 1/5 of
  /// the maximum selectable value, and not lower than 1/200 of the maximum
  /// selectable value. For a maximum value of 100 for example, a stepsize
  /// between 0.5 and 20 is recommended.
  void setStepSize(double stepSize) => state.setStepSize(stepSize);

  /// set the alpha value to be used for the given part, default 80
  /// (use value between 0 and 255)
  void setAlpha(CircleDisplayPart part, int alpha) =>
      state.setAlpha(part, alpha);

  /// sets the given paint object to be used instead of the original/default one
  void setPaint(CircleDisplayPart part, Paint paint) =>
      state.setPaint(part, paint);

  /// set the color of the given part
  void setColor(CircleDisplayPart part, Color color) =>
      state.setColor(part, color);

  /// set the color of the given part
  void setDrawPart(CircleDisplayPart part, bool enabled) =>
      state.setDrawPart(part, enabled);

  ///GETTERS

  /// returns the diameter of the drawn circle/arc
  double getDiameter(Size size) => state.getDiameter(size);

  /// returns the radius of the drawn circle
  double getRadius(Size size) => state.getRadius(size);

  /// Returns the currently displayed value from the view. Depending on the
  /// used method to show the value, this value can be percent or actual value.
  double getValue() => state.getValue();

  /// calculates the needed angle for a given value
  double calcAngle(double percent) => state.calcAngle(percent);

  /// returns the current animation status of the view
  double getPhase() => state.getPhase();

  /// returns true if drawing the given part is enabled, false if not
  bool isDrawPartEnabled(CircleDisplayPart part) =>
      state.isDrawPartEnabled(part);

  /// returns the current stepsize of the display, default 1
  double getStepSize() => state.getStepSize();

  /// returns the color of the given part
  Color getColor(CircleDisplayPart part) => state.getColor(part);
}

class _CircleDisplayState extends State<CircleDisplay>
    with SingleTickerProviderStateMixin {
  /// the unit that is represented by the circle-display
  String _mUnit;

  /// start angle of the view
  double _mStartAngle;

  /// field representing the minimum selectable value in the display - the
  /// minimum interval

  double _mStepSize;

  /// angle that represents the displayed value
  double _mAngle = 0;

  /// current state of the animation
  double _mPhase;

  /// the currently displayed value, can be percent or actual value
  double _mValue = 0;

  /// the maximum displayable value, depends on the set value
  double _mMaxValue = 0;

  /// percent of the maximum width the arc takes
  double _mValueWidthPercent;

  /// represent if each part is drawn
  Map<CircleDisplayPart, bool> drawPart = {
    CircleDisplayPart.BACK_CIRCLE: true,
    CircleDisplayPart.INNER_CIRCLE: true,
    CircleDisplayPart.ARC: true,
    CircleDisplayPart.TEXT: true,
  };

  /// represents the paint used for each part
  Map<CircleDisplayPart, Paint> paints = {
    CircleDisplayPart.BACK_CIRCLE: null,
    CircleDisplayPart.INNER_CIRCLE: null,
    CircleDisplayPart.ARC: null,
    CircleDisplayPart.TEXT: null,
  };

  /// the decimalformat responsible for formatting the values in the view
  NumberFormat _mFormatValue = NumberFormat("###,###,###,##0.0");

  /// array that contains values for the custom-text
  List<String> _mCustomText;

  /// object animator for doing the drawing animations
  Animation<double> _mDrawAnimator;
  AnimationController _mAnimationController;

  /// boolean flag that indicates if the box has been setup
  bool _mBoxSetup = false;

  /// the size of the text in the inner circle
  double _mTextFontSize;

  /// the listener for the animation
  VoidCallback _mAnimationListener;

  /// the listener for the animation status
  AnimationStatusListener _mAnimationStatusListener;

  _CircleDisplayState(
    this._mUnit,
    this._mStartAngle,
    this._mPhase,
    this._mTextFontSize,
    this._mValueWidthPercent,
    this._mCustomText,
    this._mStepSize,
    this._mAnimationListener,
    this._mAnimationStatusListener,
    Duration animationDuration,
    int formatDigits,
    bool drawBackCircle,
    bool drawInnerCircle,
    bool drawArc,
    bool drawText,
    Color backCircleColor,
    Color innerCircleColor,
    Color arcColor,
    Color textColor,
    int backCircleAlpha,
    int innerCircleAlpha,
    int arcAlpha,
    int textAlpha,
  ) {
    _formatDigits(formatDigits);
    _mAnimationController = AnimationController(
      vsync: this,
      duration: animationDuration,
    );
    _mBoxSetup = false;

    drawPart[CircleDisplayPart.BACK_CIRCLE] = drawBackCircle;
    drawPart[CircleDisplayPart.INNER_CIRCLE] = drawInnerCircle;
    drawPart[CircleDisplayPart.ARC] = drawArc;
    drawPart[CircleDisplayPart.TEXT] = drawText;

    paints[CircleDisplayPart.BACK_CIRCLE] = new Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = backCircleColor
    ..color.withAlpha(backCircleAlpha);

    paints[CircleDisplayPart.ARC] = new Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = arcColor
    ..color.withAlpha(arcAlpha);

    paints[CircleDisplayPart.INNER_CIRCLE] = new Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = innerCircleColor
    ..color.withAlpha(innerCircleAlpha);

    paints[CircleDisplayPart.TEXT] = new Paint()
    ..color = textColor
    ..color.withAlpha(textAlpha);
  }

  @override
  void initState() {
    _mDrawAnimator =
        Tween(begin: getPhase(), end: 1.0).animate(_mAnimationController)
    ..addListener(() {
      setState(() {
        _mValue = _mDrawAnimator.value;
//        todo: animationListener();
      });
    })
    ..addStatusListener(_mAnimationStatusListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_mBoxSetup) {
      _mBoxSetup = true;
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
                          paints[CircleDisplayPart.BACK_CIRCLE]),
                    ),
                  ),
            !isDrawPartEnabled(CircleDisplayPart.ARC)
                ? null
                : CustomPaint(
                    foregroundPainter: ArcPainter(
                        _getCircleBox(_boxConstraintsToSize(constraints)),
                        _mStartAngle,
                        getPhase(),
                        _mAngle,
                        paints[CircleDisplayPart.ARC]),
                  ),
            !isDrawPartEnabled(CircleDisplayPart.INNER_CIRCLE)
                ? null
                : Center(
                    child: CustomPaint(
                      foregroundPainter: CirclePainter(
                          getRadius(_boxConstraintsToSize(constraints)) /
                              100 *
                              (100 - _mValueWidthPercent),
                          paints[CircleDisplayPart.INNER_CIRCLE]),
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
        fontSize: _mTextFontSize,
      ),
    );
  }

  /// draws the custom text in the center of the view
  String _getText() {
    int index = ((getValue() * getPhase()) / getStepSize()).floor();
    if (_mCustomText.length == 0) {
      return _mFormatValue.format(getValue() * getPhase()) + " " + _mUnit;
    } else if (index < _mCustomText.length) {
      return _mCustomText[index];
    } else {
      print("${CircleDisplay._LOG_TAG}: Custom text array not long enough.");
      return "";
    }
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

  ///SETTERS

  /// Sets the unit that is displayed next to the value in the center of the
  /// view. Default "%". Could be "€" or "$" or left blank or whatever it is
  /// you display.
  void setUnit(String unit) {
    setState(() {
      _mUnit = unit;
    });
  }

  /// set the duration of the drawing animation in milliseconds
  void setAnimationDuration(int durationMillis) {
    setState(() {
      _mAnimationController.duration = Duration(milliseconds: durationMillis);
    });
  }

  /// set the starting angle for the view
  void setStartAngle(double angle) {
    setState(() {
      _mStartAngle = angle;
    });
  }

  /// set the phase
  void setPhase(double phase) {
    setState(() {
      _mPhase = phase;
    });
  }

  /// set this to true to draw the specific part, default: true
  void setDrawPart(CircleDisplayPart part, bool enabled) {
    setState(() {
      drawPart[part] = enabled;
    });
  }

  /// set the color of the given part
  void setColor(CircleDisplayPart part, Color color) {
    setState(() {
      paints[part].color = color;
    });
  }

  /// set the size of the center text in dp
  void setTextSize(double size) {
    setState(() {
      _mTextFontSize = size;
    });
  }

  /// set the thickness of the value bar, default 50%
  void setValueWidthPercent(double percentFromTotalWidth) {
    setState(() {
      _mValueWidthPercent = percentFromTotalWidth;
    });
  }

  /// Set an array of custom texts to be drawn instead of the value in the
  /// center of the CircleDisplay. If set to null, the custom text will be
  /// reset and the value will be drawn. Make sure the length of the array
  /// corresponds with the maximum number of steps (set with setStepSize(double stepsize).
  void setCustomText(List<String> custom) {
    setState(() {
      _mCustomText = custom;
    });
  }

  /// sets the number of digits used to format values
  void setFormatDigits(int digits) {
    setState(() {
      _formatDigits(digits);
    });
  }

  void _formatDigits(int digits) {
    StringBuffer buffer = new StringBuffer(".");
    buffer.writeln(List<String>.filled(digits, "0"));
    _mFormatValue = new NumberFormat("###,###,###,##0" + buffer.toString());
  }

  /// set the alpha value to be used for the given part, default 80
  /// (use value between 0 and 255)
  void setAlpha(CircleDisplayPart part, int alpha) {
    setState(() {
      paints[part].color.withAlpha(alpha);
    });
  }

  /// sets the given paint object to be used instead of the original/default one
  void setPaint(CircleDisplayPart part, Paint paint) {
    setState(() {
      paints[part] = paint;
    });
  }

  /// Sets the stepsize (minimum selection interval) of the circle display,
  /// default 1f. It is recommended to make this value not higher than 1/5 of
  /// the maximum selectable value, and not lower than 1/200 of the maximum
  /// selectable value. For a maximum value of 100 for example, a stepsize
  /// between 0.5 and 20 is recommended.
  void setStepSize(double stepSize) {
    setState(() {
      _mStepSize = stepSize;
    });
  }

  ///GETTERS

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
  double getValue() {
    return _mValue;
  }

  /// calculates the needed angle for a given value
  double calcAngle(double percent) {
    return percent / 100 * 360;
  }

  /// returns the current animation status of the view
  double getPhase() {
    return _mPhase;
  }

  /// returns true if drawing the given part is enabled, false if not
  bool isDrawPartEnabled(CircleDisplayPart part) {
    return drawPart[part];
  }

  /// returns the current stepsize of the display, default 1
  double getStepSize() {
    return _mStepSize;
  }

  /// returns the color of the given part
  Color getColor(CircleDisplayPart part) {
    return paints[part].color;
  }

  /// returns the color of the given part
  int getAlpha(CircleDisplayPart part) {
    return paints[part].color.alpha;
  }

  /// returns the angle relative to the view center for the given point on the
  /// chart in degrees. The angle is always between 0 and 360°, 0° is NORTH
  double getAngleForPoint(double x, double y) {
    Point center = getCenter();

    double tx = x - center.x;
    double ty = y - center.y;

    double length = sqrt(pow(tx, 2) + pow(ty, 2));

    double angle = degrees(acos(ty / length));

    if (x > center.x) angle = 360 - angle;

    angle = angle + 180;

    return _getPrincipalValueDegree(angle);
  }

  /// returns the principal value of the degrees in range [0, 360) ,
  /// for example:
  /// _getPrincipalValueDegree(-90) -> 270
  /// _getPrincipalValueDegree(370) -> 10
  /// _getPrincipalValueDegree(-4500) -> 180
  double _getPrincipalValueDegree(double angle) {
    // neutralize overflow
    while (angle > 360) angle -= 360;

    while (angle < 0) angle += 360;

    return angle;
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

  /// returns the angle representing the given value
  double getAngleForValue(double value) {
    return value / _mMaxValue * 360;
  }

  /// returns the value representing the given angle
  double getValueForAngle(double angle) {
    return angle / 360 * _mMaxValue;
  }

  /// returns the distance of a certain point on the view to the center of the view
  double distanceToCenter(double x, double y) {
    // pythagoras
    return sqrt(pow(getCenter().x - x, 2) + pow(getCenter().y - y, 2));
  }

//  TODO 1: void showValue(double percentToShow, double duration, Animator.AnimatorListener animatorListener) {
//
//    mAngle = calcAngle(percentToShow);
//    mValue = percentToShow;
//    mMaxValue = 100f;
//
//    startAnim(animatorListener, duration);
//  }

  void startAnim(VoidCallback animationListener,
      AnimationStatusListener animationStatusListener, int duration) {
    _mPhase = 0;
    _mDrawAnimator = Tween(begin: getPhase(), end: 1.0).animate(
      AnimationController(
        vsync: this,
        duration: Duration(seconds: duration),
      ),
    )
      ..addListener(() {
        setState(() {
          _mValue = _mDrawAnimator.value;
//        todo: animationListener();
         });
      })
      ..addStatusListener(animationStatusListener);
  }

//  TODO 3: public void stopAnim(){
//    if (mDrawAnimator != null)
//      mDrawAnimator.removeAllListeners();
//    mDrawAnimator.cancel();
//  }

  @override
  void dispose() {
    _mAnimationController.dispose();
    super.dispose();
  }
}
