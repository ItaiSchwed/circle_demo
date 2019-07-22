import 'package:flutter/material.dart';

class ArcPainter extends CustomPainter {
  Rect _mCircleBox;
  double _mStartAngle;
  double _mPhase;
  double _mAngle;
  Paint _mArcPaint;

  ArcPainter(
      this._mCircleBox,
      this._mStartAngle,
      this._mPhase,
      this._mAngle,
      this._mArcPaint,
      );

  @override
  void paint(Canvas canvas, Size size) {
    double angle = _mAngle * _mPhase;
    canvas.drawArc(
        _mCircleBox,
        _mStartAngle,
        angle,
        true,
        _mArcPaint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}