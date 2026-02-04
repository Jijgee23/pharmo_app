import 'dart:ui';
// import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pharmo_app/controller/a_controlller.dart';

abstract class AppEvent {}

class LocationEvent extends AppEvent {
  final Map<Object?, Object?> location;
  LocationEvent(this.location);
}

class NetworkEvent extends AppEvent {
  final List<ConnectivityResult> results;
  NetworkEvent(this.results);
}

class BatteryEvent extends AppEvent {
  final int level;
  BatteryEvent(this.level);
}

// class BatteryLevelEvent extends AppEvent {
//   final Battery battery;
//   BatteryLevelEvent(this.battery);
// }

class LifeCycleEvent extends AppEvent {
  final AppLifecycleState state;
  LifeCycleEvent(this.state);
}

class HiveBoxEvent extends AppEvent {
  final String key;
  HiveBoxEvent(this.key);
}
