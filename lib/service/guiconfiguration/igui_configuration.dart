import 'package:circle_demo/service/utilities/enums/side.dart';
import 'package:circle_demo/service/utilities/enums/tl_color.dart';
import 'package:circle_demo/service/utilities/serverdata/update/IUpdatedData.dart';

abstract class IGUIConfiguration {
  void restart(Map<Side, Map<TLColor, double>> totalTimes);
//    void update(double total, IUpdatedData updatedData, String side);
  void update(IUpdatedData updatedData, Side side);
  void stop();
}
