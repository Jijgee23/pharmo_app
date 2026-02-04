// package mn.infosystems.pharmo

// import android.content.BroadcastReceiver
// import android.content.Context
// import android.content.Intent
// import android.util.Log
// import androidx.core.content.ContextCompat

// class BootReceiver : BroadcastReceiver() {

//     companion object {
//         private const val TAG = "BootReceiver"
//     }

//     override fun onReceive(context: Context, intent: Intent?) {
//         if (intent?.action == Intent.ACTION_BOOT_COMPLETED) {
//             Log.d(TAG, "Boot completed - checking if location tracking should resume")

//             val prefs = context.getSharedPreferences("app_settings", Context.MODE_PRIVATE)
//             val trackingEnabled = prefs.getBoolean("tracking_enabled", false)

//             if (trackingEnabled) {
//                 Log.d(TAG, "Tracking was enabled - restarting LocationService")
//                 val serviceIntent = Intent(context, LocationService::class.java)
//                 ContextCompat.startForegroundService(context, serviceIntent)
//             } else {
//                 Log.d(TAG, "Tracking was not enabled - not starting service")
//             }
//         }
//     }
// }
