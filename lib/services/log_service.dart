import 'package:hive_flutter/hive_flutter.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/database/log_model.dart';
import 'package:pharmo_app/services/a_services.dart';

import '../utilities/a_utils.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  LogService._internal();
  factory LogService() {
    return _instance;
  }
  late final Box<LogModel> logBox;

  Future<void> initialize() async {
    // Зөвхөн нэг удаа дуудагдах ёстой
    if (!Hive.isBoxOpen('logbox')) {
      logBox = await Hive.openBox('logbox');
    } else {
      // Хэрэв нээлттэй бол, одоо байгаа Box-ийг авч ашиглах
      logBox = Hive.box('logbox');
    }
  }
  // static String logBox = 'logbox';

  // static Box localDb = Hive.box<LogModel>(logBox);
  Future createLog(String logType, String desc) async {
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
          deleteModel(log);
        }
      }
    }
  }

  /// Model хадгалах (update)
  Future<void> saveModel(LogModel log) async {
    // await openBox();
    await logBox.add(log);
  }

  /// Model устгах
  static Future<void> deleteModel(LogModel log) async {
    await log.delete();
  }

  Future<List<LogModel>> getList() async {
    return logBox.values.toList();
  }

  /// Бүх өгөгдлийг устгах
  Future<void> clearAll() async {
    await logBox.clear();
  }

  Future saveLastNotif(DateTime date) async {
    bool alreadyOpened = Hive.isBoxOpen(lastNotifDate);
    if (!alreadyOpened) {
      Hive.openBox(lastNotifDate);
    }

    var notifBox = await Hive.openBox(lastNotifDate);
    await notifBox.put('lastNotifTime', date);

    await notifBox.flush();
  }

  Future<DateTime?> getLastNotifDate() async {
    bool alreadyOpened = Hive.isBoxOpen(lastNotifDate);
    if (!alreadyOpened) {
      Hive.openBox(lastNotifDate);
    }
    var notifBox = await Hive.openBox(lastNotifDate);
    return await notifBox.get('lastNotifTime');
  }

  final String lastNotifDate = 'lastNotifDate';
  static const String login = 'Нэвтрэх';
  static const String logout = 'Системээс гарах';
  static const String disconnected = 'Холболт салсан';
  static const String connected = 'Сүлжээнд холбогдсон';
  static const String closeApp = 'Аппаас түр гарсан';
  static const String terminateApp = 'Аппыг хаасан';
  static const String reOpenApp = 'Аппыг буцааж нээсэн';
}

// LOG NAMES
