import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeChannel {
  static EventChannel bgLocationChannel = EventChannel('bg_location_stream');
  static EventChannel batteryChannel = EventChannel('batteryStream');
  static const MethodChannel locationControl =
      MethodChannel('location_control');

  static Future<bool> startLocationService() async {
    try {
      final result = await locationControl.invokeMethod('start');
      return result == true;
    } catch (e) {
      debugPrint('Failed to start location service: $e');
      return false;
    }
  }

  /// Stop location service
  static Future<bool> stopLocationService() async {
    try {
      final result = await locationControl.invokeMethod('stop');
      return result == true;
    } catch (e) {
      debugPrint('Failed to stop location service: $e');
      return false;
    }
  }

  static Future<bool> isServiceRunning() async {
    try {
      final result = await locationControl.invokeMethod('isRunning');
      return result == true;
    } catch (e) {
      debugPrint('Failed to check service status: $e');
      return false;
    }
  }
}
