package mn.infosystems.pharmo

import android.location.Location
import kotlin.math.sqrt
import android.location.LocationListener
import android.location.LocationManager

// class KalmanLocationFilter {
//     private var lat = 0.0
//     private var lng = 0.0
//     private var variance = -1.0

//     companion object {
//         private const val PROCESS_NOISE = 0.1 // 0.5 baisan
//     }

//     fun filter(measurement: Location): Location {
//         if (variance < 0) {
//             // First measurement
//             lat = measurement.latitude
//             lng = measurement.longitude
//             variance = (measurement.accuracy * measurement.accuracy).toDouble()
//         } else {
//             // Predict
//             val predictionVariance = variance + PROCESS_NOISE

//             // Update
//             val measurementVariance = (measurement.accuracy * measurement.accuracy).toDouble()
//             val kalmanGain = predictionVariance / (predictionVariance + measurementVariance)

//             lat += kalmanGain * (measurement.latitude - lat)
//             lng += kalmanGain * (measurement.longitude - lng)
//             variance = (1 - kalmanGain) * predictionVariance
//         }

//         // Create filtered location
//         return Location(measurement).apply {
//             latitude = lat
//             longitude = lng
//             accuracy = sqrt(variance).toFloat()
//         }
//     }

//     fun reset() {
//         variance = -1.0
//     }
// }