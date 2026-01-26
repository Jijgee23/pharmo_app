package mn.infosystems.pharmo

import BatteryHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
  private lateinit var locationStreamHandler: LocationStreamHandler
  private lateinit var batteryHandler: BatteryHandler
  // private val CHANNEL = "mn.infosystems.pharmo/permissions"
  // private val METHOD_CHANNEL = "mn.infosystems.pharmo/methods"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    locationStreamHandler = LocationStreamHandler(this)
    batteryHandler = BatteryHandler(this)

    EventChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_CHANNEL)
            .setStreamHandler(locationStreamHandler)

    EventChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL)
            .setStreamHandler(batteryHandler)
  }

  override fun onRequestPermissionsResult(
          requestCode: Int,
          permissions: Array<out String>,
          grantResults: IntArray
  ) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    locationStreamHandler.handlePermissionResult(requestCode, grantResults)
  }

  companion object {
    private const val LOCATION_CHANNEL = "bg_location_stream"
    private const val BATTERY_CHANNEL = "batteryStream"
  }
}
