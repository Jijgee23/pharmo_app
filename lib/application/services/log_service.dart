import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmo_app/controller/a_controlller.dart';
import 'package:pharmo_app/application/services/a_services.dart';
import '../function/utilities/a_utils.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  LogService._internal();
  factory LogService() {
    return _instance;
  }
  late final Box<LogModel> logBox;

  Future<void> initialize() async {
    if (Hive.isBoxOpen('logbox')) return;
    logBox = await Hive.openBox('logbox');
  }

  Future createLog(String logType, String desc) async {
    // if (!await isOnline()) {
    //   await saveModel(LogModel(logType: logType, desc: desc));
    //   return;
    // }
    final user = Authenticator.security;
    if (user == null) return;
    if (user.isPharmacist) return;
    final String deviceToken = await Authenticator.getDeviceToken();
    var r = await api(
      Api.post,
      'mobile_activity_log/',
      body: {
        "device_id": deviceToken,
        "log_type": logType,
        "desc": desc,
      },
    );
    if (r == null) return;
    if (r.statusCode == 200 || r.statusCode == 201) {
      debugPrint("log created: $logType");
      final savedLogs = await getList();
      if (savedLogs.isEmpty) return;
      for (var log in savedLogs) {
        var k = await api(
          Api.post,
          'mobile_activity_log/',
          body: {
            "device_id": deviceToken,
            "log_type": log.logType,
            "desc": log.desc,
          },
        );
        if (k!.statusCode == 201 || k.statusCode == 200) {
          await deleteModel(log);
        }
      }
      return;
    } else {
      await saveModel(LogModel(logType: logType, desc: desc));
    }
  }

  Future<void> saveModel(LogModel log) async {
    await logBox.add(log);
  }

  static Future<void> deleteModel(LogModel log) async {
    await log.delete();
  }

  Future<List<LogModel>> getList() async {
    return logBox.values.toList();
  }

  Future<void> clearAll() async {
    await logBox.clear();
  }

  static const String login = 'Нэвтрэх';
  static const String logout = 'Системээс гарах';
  static const String disconnected = 'Холболт салсан';
  static const String connected = 'Сүлжээнд холбогдсон';
  static const String closeApp = 'Аппаас түр гарсан';
  static const String terminateApp = 'Аппыг хаасан';
  static const String reOpenApp = 'Аппыг буцааж нээсэн';
}

// LOG NAMES
