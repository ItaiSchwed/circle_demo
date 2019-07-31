import 'package:flutter/material.dart';

import 'service/circle_display/animation_status_action.dart';
import 'service/circle_display/circle_display.dart';
import 'service/circle_display/circle_display_part.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  bool fill = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CircleDisplay(
          animationDuration: Duration(seconds: 4),
          arcColor: Colors.green,
          backCircleColor: Colors.white,
          unit: '°',
          animationStatusListener:
              (AnimationStatusActions actions, AnimationStatus status) {
            switch (status) {
              case AnimationStatus.completed:
                actions.restart(direction: Direction.FORWARD, colors: {
                  CircleDisplayPart.BACK_CIRCLE:
                      fill ? Colors.green : Colors.white,
                  CircleDisplayPart.ARC: fill ? Colors.white : Colors.green
                });
                fill = !fill;
                break;
              case AnimationStatus.dismissed:
                break;
              case AnimationStatus.forward:
                break;
              case AnimationStatus.reverse:
                break;
            }
          },
        ),
      ),
    );
  }
}
