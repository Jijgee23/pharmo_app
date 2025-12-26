import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';

const EventChannel bgLocationChannel = EventChannel('bg_location_stream');

class TrackProvider extends ChangeNotifier {
  StreamSubscription? positionSubscription;
  Future start() async {}
}

@HiveType(typeId: 3)
class TrackData extends HiveObject {
  @HiveField(0)
  final double lat;
  @HiveField(1)
  final double lng;
  @HiveField(2)
  bool sended;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final int? deliveryId;
  TrackData({
    required this.lat,
    required this.lng,
    required this.sended,
    required this.date,
    this.deliveryId,
  });
}
