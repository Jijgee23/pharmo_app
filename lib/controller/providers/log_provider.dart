import 'package:pharmo_app/controller/a_controlller.dart';
import 'package:pharmo_app/application/function/utilities/a_utils.dart';

class LogProvider extends ChangeNotifier {
  List<Log> logs = <Log>[];
  Future getLogs() async {
    var r = await api(Api.get, 'mobile_activity_log/');
    if (r == null) return;
    if (r != null && r.statusCode == 200) {
      Map<String, dynamic> data = convertData(r);
      print(data);
      logs = (data['results'] as List).map((e) => Log.fromJson(e)).toList();
      notifyListeners();
    }
  }

  void reset() {
    logs.clear();
    notifyListeners();
  }
}

class Log {
  final int id;
  final int? userId;
  final String deviceId;
  final String type;
  final String description;
  final DateTime createdAt;

  Log({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.description,
    required this.createdAt,
    this.userId,
  });

  String get desc => description;
  String get createdString => createdAt.toIso8601String();
  String get date => createdString;

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: _parseInt(json['id']),
      userId: _parseIntNullable(json['user_id']),
      deviceId: '${json['device_id'] ?? ''}',
      type: '${json['log_type'] ?? ''}',
      description: '${json['desc'] ?? ''}',
      createdAt: _parseDateTime(json['created']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 0;
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse('$value');
  }

  static DateTime _parseDateTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    final normalised = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
    return DateTime.tryParse(normalised) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}
