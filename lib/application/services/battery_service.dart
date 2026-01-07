import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmo_app/application/services/firebase_sevice.dart';
import 'package:pharmo_app/application/services/local_base.dart';
import 'package:pharmo_app/application/services/log_service.dart';

class BatteryService {
  static final Battery _battery = Battery();
  static StreamSubscription<BatteryState>? _subscription;
  static int? _lastBatteryLevel;
  static BatteryState? _lastBatteryState;

  /// Stream controller for broadcasting changes
  static final StreamController<int> _batteryLevelController =
      StreamController<int>.broadcast();
  static final StreamController<BatteryState> _batteryStateController =
      StreamController<BatteryState>.broadcast();

  static Stream<int> get batteryLevelStream => _batteryLevelController.stream;
  static Stream<BatteryState> get batteryStateStream =>
      _batteryStateController.stream;

  /// Initialize listener
  static Future<void> startListenBattery() async {
    if (kDebugMode) return;

    // prevent duplicate listener
    if (_subscription != null) return;

    try {
      // initial values
      _lastBatteryLevel = await _battery.batteryLevel;
      _lastBatteryState = await _battery.batteryState;
      _batteryLevelController.add(_lastBatteryLevel!);
      _batteryStateController.add(_lastBatteryState!);
    } catch (e) {
      debugPrint('⚠️ Battery init error: $e');
    }

    // subscribe to battery state changes
    _subscription = _battery.onBatteryStateChanged.listen(
      (BatteryState state) async {
        final currentLevel = await _battery.batteryLevel;
        final hasDelmanTrack = await LocalBase.hasDelmanTrack();
        final hasSellerTrack = await LocalBase.hasSellerTrack();

        /// only trigger event when state or level changes
        if (_lastBatteryLevel != currentLevel || _lastBatteryState != state) {
          _lastBatteryLevel = currentLevel;
          _lastBatteryState = state;
          _batteryLevelController.add(currentLevel);
          _batteryStateController.add(state);

          debugPrint('🔋 Battery: $currentLevel% | State: $state');

          /// OPTIONAL: send warning when battery too low
          if (currentLevel <= 20 &&
              (hasDelmanTrack || hasSellerTrack) &&
              (state != BatteryState.charging)) {
            await LogService().createLog(
              'tracking log',
              'Таны төхөөрөмжийн баттерей $currentLevel% байна.',
            );
            await FirebaseApi.local(
              'Баттерей сул байна',
              'Таны төхөөрөмжийн баттерей $currentLevel% байна. '
                  'Цэнэглэнэ үү, байршил дамжуулалт зогсох магадлалтай.',
            );
          }
        }
      },
      onError: (e) => debugPrint('Battery listener error: $e'),
    );
  }

  static Future<void> stopListenBattery() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  static void dispose() {
    _batteryLevelController.close();
    _batteryStateController.close();
  }

  static Future<int> getCurrentLevel() async {
    return await _battery.batteryLevel;
  }

  static Future<BatteryState> getCurrentState() async {
    return await _battery.batteryState;
  }
}
