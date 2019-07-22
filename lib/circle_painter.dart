import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  Paint _mCirclePaint;
  double _radius;

  CirclePainter(this._radius, this._mCirclePaint);

  /// draws the background circle with less alpha
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        _radius,
        _mCirclePaint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}