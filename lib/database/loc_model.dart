import 'package:hive/hive.dart';
part 'loc_model.g.dart';

@HiveType(typeId: 0)
class LocModel extends HiveObject {
  @HiveField(0)
  double lat;

  @HiveField(1)
  double lng;

  @HiveField(2)
  bool success;

  LocModel({
    required this.lat,
    required this.lng,
    required this.success,
  });
}
