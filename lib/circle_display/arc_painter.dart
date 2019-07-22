import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class ArcPainter extends CustomPainter {
  Rect _mCircleBox;
  double _mStartAngle;
  double _mPhase;
  double _mAngle;
  Paint _mArcPaint;

  ArcPainter(
      this._mCircleBox,
      this._mStartAngle,
      this._mAngle,
      this._mArcPaint,
      );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
        _mCircleBox,
        radians(_mStartAngle),
        radians(_mAngle),
        true,
        _mArcPaint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}