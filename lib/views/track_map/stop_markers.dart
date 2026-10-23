import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/app_lite.dart';

/// One marker per stop of [delivery] that has coordinates: azure while
/// orders are left there, green once every one is handled. Built from the
/// delivery each time, so refreshes can't pile markers up.
Set<Marker> stopMarkers(Delivery? delivery, {void Function(DeliveryStop stop)? onTap}) {
  if (delivery == null) return {};
  return {
    for (final stop in delivery.stops)
      if (stop.coordinates case final c?)
        Marker(
          markerId: MarkerId('stop-${stop.key}'),
          position: LatLng(c.$1, c.$2),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            stop.isDone ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: stop.name,
            snippet: '${stop.handledCount} / ${stop.orders.length} хүргэсэн',
            onTap: onTap == null ? null : () => onTap(stop),
          ),
        ),
  };
}
