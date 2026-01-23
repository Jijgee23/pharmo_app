import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmo_app/application/application.dart';

double calculateBearing(LatLng last, LatLng current) {
  return Geolocator.bearingBetween(
    last.latitude,
    last.longitude,
    current.latitude,
    current.longitude,
  );
}

double calculateTotalDistanceKm(List<TrackData> points) {
  if (points.length < 2) return 0;

  double totalMeters = 0;

  for (int i = 0; i < points.length - 1; i++) {
    totalMeters += Geolocator.distanceBetween(
      points[i].latitude,
      points[i].longitude,
      points[i + 1].latitude,
      points[i + 1].longitude,
    );
  }

  return totalMeters / 1000;
}

double truncateToSixDigits(double value) {
  num mod = pow(10.0, 6);
  return ((value * mod).round().toDouble() / mod);
}
