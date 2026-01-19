package mn.infosystems.pharmo

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private lateinit var locationStreamHandler: LocationStreamHandler
  // private val CHANNEL = "mn.infosystems.pharmo/permissions"
 private val METHOD_CHANNEL = "mn.infosystems.pharmo/methods"
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    locationStreamHandler = LocationStreamHandler(this)

    EventChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_CHANNEL)
            .setStreamHandler(locationStreamHandler)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
              when (call.method) {
                "requestLocationPermissions" -> {
                 locationStreamHandler.checkAndRequestFullLocationPermissions()
                    result.success(true)
                }
                else -> result.notImplemented()
              }
            }
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
  }
}
