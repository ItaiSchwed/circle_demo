import 'package:circle_demo/service/utilities/enums/tl_color.dart';

/// Created by iati1 on 07 מרץ 2018.

abstract class IUpdatedData {
  /// getter of the current color of the traffic light
  /// @return the current color of the traffic light
  TLColor getTLColor();

  /// getter of the updated time to switch, according to the timestamp
  /// @return the updated time to switch, according to the timestamp
  /// @throws LightChangedException indicating about a switching of the light in the traffic light/ late displaying of time to switch
  int getRealTimeSecondsToSwitch();
}
