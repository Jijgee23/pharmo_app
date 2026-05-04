import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/data/database/security.dart';

class Authenticator {
  static final Authenticator _instance = Authenticator._internal();
  Authenticator._internal();
  factory Authenticator() {
    return _instance;
  }

  static Box localDb = Hive.box('local');
  static Security? security;
  static bool hasSpashed = false;
  static bool remember = false;
  static const String _boxKey = 'local';
  static const String _idKey = 'id';
  static const String _nameKey = 'name';
  static const String _emailKey = 'email';
  static const String _roleKey = 'role';
  static const String _supplierIdKey = 'supplier_id';
  static const String _stockIdKey = 'stock_id';
  static const String _stocksKey = 'stocks';
  static const String _customerIdKey = 'customer_id';
  static const String _companyNameKey = 'company_name';
  static const String _accessKey = 'access';
  static const String _refreshKey = 'refresh';
  static const String _rememberKey = 'remember';
  static const String _splashedKey = 'splashed';
  static const String _dmTrackKey = 'track_id';
  static const String _deviceToken = 'deviceToken';
  static const String _byId = 'by_id';

  static Future initAuthenticator() async {
    localDb = await Hive.openBox(_boxKey);
    security = await getSecurity();
    hasSpashed = await hasSplashed();
    remember = await getRemember();
  }

  static Future removeTokens() async {
    localDb = await Hive.openBox(_boxKey);
    await localDb.delete(_accessKey);
    await localDb.delete(_refreshKey);
    await localDb.flush();
  }

  static Future saveModel(Map<String, dynamic> res) async {
    localDb = await Hive.openBox(_boxKey);
    var r = await getSecurity();
    if (r != null) {
      await clearSecurity();
    }

    final decodedToken = JwtDecoder.decode(res['access_token']);
    var security = Security.fromJson(
      decodedToken,
      res['access_token'],
      res['refresh_token'],
    );

    await localDb.put(_idKey, security.id);
    await localDb.put(_nameKey, security.name);
    await localDb.put(_emailKey, security.email);
    await localDb.put(_roleKey, security.role);
    await localDb.put(_supplierIdKey, security.supplierId);
    await localDb.put(_stockIdKey, security.stockId);
    await localDb.put(_stocksKey, security.stocks);
    await localDb.put(_customerIdKey, security.customerId);
    await localDb.put(_companyNameKey, security.companyName);
    await localDb.put(_accessKey, security.access);
    await localDb.put(_refreshKey, security.refresh);
    await localDb.put(_byId, security.byId);
    if (security != null) {
      await saveSplashed(true);
    }
  }

  static Future clearSecurity() async {
    localDb = await Hive.openBox(_boxKey);
    await localDb.delete(_idKey);
    await localDb.delete(_nameKey);
    await localDb.delete(_emailKey);
    await localDb.delete(_roleKey);
    await localDb.delete(_supplierIdKey);
    await localDb.delete(_stockIdKey);
    await localDb.delete(_stocksKey);
    await localDb.delete(_customerIdKey);
    await localDb.delete(_companyNameKey);
    await localDb.delete(_accessKey);
    await localDb.delete(_refreshKey);
    await localDb.delete(_byId);
    await localDb.flush();
    await initAuthenticator();
  }

  static Future updateAccess(String access, {String? refresh}) async {
    localDb = await Hive.openBox(_boxKey);
    await localDb.put('access', access);
    if (refresh != null) await localDb.put('refresh', refresh);
    await localDb.flush();
    await initAuthenticator();
  }

  static Future getAccess() async {
    localDb = await Hive.openBox(_boxKey);
    final access = await localDb.get('access', defaultValue: 'empty');
    return access;
  }

  static Future updateStock(int supplierId, int stockId) async {
    localDb = await Hive.openBox(_boxKey);
    await localDb.put(_supplierIdKey, supplierId);
    await localDb.put(_stockIdKey, stockId);
    await localDb.flush();
    await initAuthenticator();
  }

  static Future<Security?> getSecurity() async {
    Security? result;
    localDb = await Hive.openBox(_boxKey);
    int? id = localDb.get(_idKey);
    if (localDb.isNotEmpty && id != null) {
      result = Security(
        id: localDb.get(_idKey),
        name: localDb.get(_nameKey),
        email: localDb.get(_emailKey),
        role: localDb.get(_roleKey),
        supplierId: localDb.get(_supplierIdKey),
        stockId: localDb.get(_stockIdKey),
        stocks: localDb.get(_stocksKey),
        customerId: localDb.get(_customerIdKey),
        companyName: localDb.get(_companyNameKey),
        access: localDb.get(_accessKey, defaultValue: ''),
        refresh: localDb.get(_refreshKey, defaultValue: ''),
        byId: localDb.get(_byId, defaultValue: null),
      );
    }
    return result;
  }

  static Future saveSplashed(bool value) async {
    localDb = await Hive.openBox(_boxKey);
    await localDb.put(_splashedKey, value);
    await localDb.flush();
  }

  static Future<bool> hasSplashed() async {
    localDb = await Hive.openBox(_boxKey);
    bool splashed = await localDb.get(_splashedKey, defaultValue: false);
    hasSpashed = splashed;
    return splashed;
  }

  static Future initSplashed() async {
    localDb = await Hive.openBox(_boxKey);
    int splashed = await localDb.get(_splashedKey, defaultValue: 0);
    hasSpashed = splashed == 1;
    print("splashed: $splashed  ");
  }

  static Future saveRemember() async {
    localDb = await Hive.openBox(_boxKey);
    await localDb.put(_rememberKey, true);
    await localDb.flush();
  }

  static Future<bool> getRemember() async {
    localDb = await Hive.openBox(_boxKey);
    return localDb.get(_rememberKey, defaultValue: false);
  }

  static Future clearAuthenticator() async {
    localDb = await Hive.openBox(_boxKey);
    localDb.clear();
    await localDb.flush();
  }

  static Future saveTrackId(int id) async {
    localDb = await Hive.openBox(_boxKey);
    localDb.put(_dmTrackKey, id);
    await getTrackId();
    await localDb.flush();
  }

  static Future<int> getTrackId() async {
    localDb = await Hive.openBox(_boxKey);
    int id = await localDb.get(_dmTrackKey, defaultValue: 0);
    return id;
  }

  static Future<bool> hasTrack() async {
    localDb = await Hive.openBox(_boxKey);
    int trackId = await localDb.get(_dmTrackKey, defaultValue: 0);
    return trackId != 0;
  }

  static Future clearTrackId() async {
    localDb = await Hive.openBox(_boxKey);
    await localDb.delete(_dmTrackKey);
  }

  static const String lastLoggedIn = "last_logged";

  static Future saveLastLoggedIn(bool isLogin) async {
    localDb = await Hive.openBox(_boxKey);
    await localDb.put(lastLoggedIn, isLogin ? "loggedIn" : "signedOut");
    await localDb.flush();
  }

  static Future<bool> isLoggedIn() async {
    localDb = await Hive.openBox(_boxKey);
    String value = await localDb.get(lastLoggedIn, defaultValue: "signedOut");
    if (value == "signedOut") return false;
    return true;
  }

  static Future saveDeviceToken(String token) async {
    localDb = await Hive.openBox(_boxKey);
    await localDb.put(_deviceToken, token);
    await localDb.flush();
  }

  static Future<String> getDeviceToken() async {
    localDb = await Hive.openBox(_boxKey);
    String res = await localDb.get(_deviceToken, defaultValue: '');
    return res;
  }

  static const String _loginHistoryKey = 'login_history';

  static Future saveLoginHistory(String identifier, String name) async {
    localDb = await Hive.openBox(_boxKey);
    List<Map<String, String>> history = await getLoginHistory();
    history.removeWhere((e) => e['identifier'] == identifier);
    history.insert(0, {'identifier': identifier, 'name': name});
    if (history.length > 5) history = history.sublist(0, 5);
    await localDb.put(_loginHistoryKey, jsonEncode(history));
    await localDb.flush();
  }

  static Future<List<Map<String, String>>> getLoginHistory() async {
    localDb = await Hive.openBox(_boxKey);
    final raw = localDb.get(_loginHistoryKey, defaultValue: '[]');
    try {
      final decoded = jsonDecode(raw as String) as List;
      return decoded.map((e) => Map<String, String>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future removeFromHistory(String identifier) async {
    localDb = await Hive.openBox(_boxKey);
    List<Map<String, String>> history = await getLoginHistory();
    history.removeWhere((e) => e['identifier'] == identifier);
    await localDb.put(_loginHistoryKey, jsonEncode(history));
    await localDb.flush();
  }

  static Future saveIdentifierAndPassword(String email, String password) async {
    await initAuthenticator();
    await localDb.put('identifier', email);
    await localDb.put('password', password);
  }

  static Future<Map<String, String>> readIdentifierAndPassword() async {
    await initAuthenticator();
    final identifier = await localDb.get('identifier', defaultValue: '');
    final password = await localDb.get('password', defaultValue: '');
    return {"identifier": identifier, "password": password};
  }
}
