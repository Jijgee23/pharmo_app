package mn.infosystems.pharmo
import mn.infosystems.pharmo.LocationStreamHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.Manifest
import androidx.core.app.ActivityCompat
import com.google.errorprone.annotations.InlineMe

class MainActivity : FlutterActivity() {
  private lateinit var locationStreamHandler: LocationStreamHandler
  private val CHANNEL = "mn.infosystems.pharmo/permissions"
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
   
    locationStreamHandler = LocationStreamHandler(this)
  
    EventChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      LOCATION_CHANNEL
    ).setStreamHandler(locationStreamHandler)
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    locationStreamHandler.handlePermissionResult(requestCode, grantResults)
  }

  companion object {
    private const val LOCATION_CHANNEL = "bg_location_stream"
  }
}
