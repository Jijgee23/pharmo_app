import 'package:hive/hive.dart';

part 'log_model.g.dart';

@HiveType(typeId: 3)
class LogModel extends HiveObject {
  @HiveField(0)
  final String logType;

  @HiveField(1)
  final String desc;

  LogModel({
    required this.logType,
    required this.desc,
  });

  Map<String, dynamic> toJson() => {
        'log_type': logType,
        'desc': desc,
      };
}
