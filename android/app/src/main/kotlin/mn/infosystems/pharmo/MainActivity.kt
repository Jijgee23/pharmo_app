package mn.infosystems.pharmo

import BatteryHandler
import android.content.Intent
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private lateinit var locationStreamHandler: LocationStreamHandler
  private lateinit var batteryHandler: BatteryHandler

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    locationStreamHandler = LocationStreamHandler(this)
    batteryHandler = BatteryHandler(this)

    EventChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_EVENT_CHANNEL)
            .setStreamHandler(locationStreamHandler)

    EventChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_EVENT_CHANNEL)
            .setStreamHandler(batteryHandler)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_CONTROL_CHANNEL)
            .setMethodCallHandler { call, result ->
              when (call.method) {
                "start" -> {
                  val started = startLocationService()
                  result.success(started)
                }
                "stop" -> {
                  val stopped = stopLocationService()
                  result.success(stopped)
                }
                "isRunning" -> {
                  val isRunning = isLocationServiceRunning()
                  result.success(isRunning)
                }
                else -> {
                  result.notImplemented()
                }
              }
            }
  }

  private fun startLocationService(): Boolean {
    return try {
      val intent = Intent(this, LocationService::class.java)
      ContextCompat.startForegroundService(this, intent)
      true
    } catch (e: Exception) {
      android.util.Log.e("MainActivity", "Failed to start service", e)
      false
    }
  }

  private fun stopLocationService(): Boolean {
    return try {
      val intent = Intent(this, LocationService::class.java)
      stopService(intent)
      LocationService.setEventSink(null)
      true
    } catch (e: Exception) {
      android.util.Log.e("MainActivity", "Failed to stop service", e)
      false
    }
  }

  private fun isLocationServiceRunning(): Boolean {
    // You can implement actual check here
    return LocationService.isRunning()
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
    private val LOCATION_CONTROL_CHANNEL = "location_control"
    private val LOCATION_EVENT_CHANNEL = "bg_location_stream"
    private val BATTERY_EVENT_CHANNEL = "batteryStream"
  }
}
