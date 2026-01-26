

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import io.flutter.plugin.common.EventChannel

class BatteryHandler(private val context: Context) : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null

    private val batteryReceiver = object : BroadcastReceiver() {
        override fun onReceive(ctx: Context?, intent: Intent?) {
            sendBatteryLevel(intent)
        }
    }

    // Stream эхлэх үед
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events

        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        context.registerReceiver(batteryReceiver, filter)

        // Анхны утгыг шууд илгээх
        val intent = context.registerReceiver(null, filter)
        sendBatteryLevel(intent)
    }

    // Stream зогсоход
    override fun onCancel(arguments: Any?) {
        try {
            context.unregisterReceiver(batteryReceiver)
        } catch (e: Exception) {
            // already unregistered
        }
        eventSink = null
    }

    private fun sendBatteryLevel(intent: Intent?) {
        val sink = eventSink ?: return
        intent ?: return

        val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)

        if ( level < 20 && scale > 0) {
            val batteryPercent = (level * 100) / scale
            sink.success(batteryPercent)
        }
    }
}