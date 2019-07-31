import 'dart:ui';

import 'circle_display_part.dart';

typedef RestartFunction = void Function(
    {Direction direction, Map<CircleDisplayPart, Color> colors});
typedef StopFunction = void Function();
enum Direction { FORWARD, BACKWARD }

class AnimationStatusActions {
  RestartFunction restart;
  StopFunction stop;

  AnimationStatusActions(this.restart, this.stop);
}
