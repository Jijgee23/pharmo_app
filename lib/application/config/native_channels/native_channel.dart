import 'package:flutter/services.dart';

class NativeChannel {
  static EventChannel bgLocationChannel = EventChannel('bg_location_stream');
  static EventChannel batteryChannel = EventChannel('batteryStream');
}
