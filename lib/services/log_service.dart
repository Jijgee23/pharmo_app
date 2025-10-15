import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/database/log_model.dart';
import 'package:pharmo_app/services/a_services.dart';

import '../utilities/a_utils.dart';

class LogService {
  static String logBox = 'logbox';
  static Box localDb = Hive.box(logBox);
  static Future createLog(String logType, String desc) async {
    final String deviceToken = await LocalBase.getDeviceToken();
    var r = await api(
      Api.post,
      'mobile_activity_log/',
      body: {
        "device_id": deviceToken,
        "log_type": logType,
        "desc": desc,
      },
    );
    if (r!.statusCode == 200 || r.statusCode == 201) {
      debugPrint("log created: $logType");
      final savedLogs = await openBox();
      if (savedLogs.isEmpty) return;
      for (var log in (savedLogs as List<LogModel>)) {
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
          deleteModel(log);
        }
      }
    }
  }

  static Future<Box<LogModel>> openBox() async {
    return await Hive.openBox<LogModel>(logBox);
  }

  /// Model хадгалах (update)
  static Future<void> saveModel(LogModel log) async {
    await log.save();
  }

  /// Model устгах
  static Future<void> deleteModel(LogModel log) async {
    await log.delete();
  }

  /// Бүх өгөгдлийг устгах
  static Future<void> clearAll() async {
    final box = await openBox();
    await box.clear();
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
