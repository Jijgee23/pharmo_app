import 'package:hive/hive.dart';
import 'package:pharmo_app/controller/providers/jagger_provider.dart';
part 'track_data.g.dart';

@HiveType(typeId: 1)
class TrackData extends HiveObject {
  @HiveField(0)
  final double latitude;
  @HiveField(1)
  final double longitude;
  @HiveField(2)
  final int? id;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  bool sended;

  TrackData({
    required this.latitude,
    required this.longitude,
    required this.date,
    this.id,
    this.sended = false,
  });

  Map<String, dynamic> toJson() {
    if (id != null) {
      return ({
        'delivery_id': id,
        'locs': [
          {
            'lat': truncateToDigits(latitude, 6),
            'lng': truncateToDigits(longitude, 6),
            "created": date.toIso8601String(),
          }
        ]
      });
    }
    return {
      'lat': truncateToDigits(latitude, 6),
      'lng': truncateToDigits(longitude, 6),
      "created": date.toIso8601String(),
    };
  }

  void updateSended() {}
}
