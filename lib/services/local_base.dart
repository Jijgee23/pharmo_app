import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pharmo_app/models/security.dart';

class LocalBase {
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
  static const String _dmTrackKey = 'delmantrack';

  static Future initLocalBase() async {
    localDb = await Hive.openBox(_boxKey);
    security = await getSecurity();
    hasSpashed = await hasSplashed();
    remember = await getRemember();
    print(
        'local base inited, has user: ${security != null}, splashed: $hasSpashed');
  }

  static Future saveModel(Map<String, dynamic> res) async {
    localDb = await Hive.openBox(_boxKey);
    if (localDb.isNotEmpty) {
      await localDb.clear();
    }
    print(res);
    final decodedToken = JwtDecoder.decode(res['access_token']);
    print(decodedToken);
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
    if (security != null) {
      await saveSplashed(true);
    }
  }

  static Future updateAccess(String access) async {
    localDb = await Hive.openBox(_boxKey);
    await localDb.put('access', access);
    await initLocalBase();
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
        access: localDb.get(_accessKey),
        refresh: localDb.get(_refreshKey),
      );
    }
    return result;
  }

  // static int sellerTrackId = -1;

  static Future saveSellerTrackId() async {
    localDb = await Hive.openBox(_boxKey);
    await localDb.delete('seller_track_id');
    await localDb.put('seller_track_id', 1);
  }

  static Future<bool> hasSellerTrack() async {
    localDb = await Hive.openBox(_boxKey);
    if (localDb.get('seller_track_id') == -1) {
      return false;
    } else {
      return true;
    }
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

  static Future clearLocalBase() async {
    localDb = await Hive.openBox(_boxKey);
    localDb.clear();
    await localDb.flush();
  }

  static Future saveDelmanTrack(int id) async {
    localDb = await Hive.openBox(_boxKey);
    localDb.put(_dmTrackKey, id);
    await localDb.flush();
  }

  static Future<int> getDelmanTrackId() async {
    localDb = await Hive.openBox(_boxKey);
    int id = await localDb.get(_dmTrackKey, defaultValue: 0);
    return id;
  }

  static Future<bool> hasDelmanTrack() async {
    localDb = await Hive.openBox(_boxKey);
    int trackId = await localDb.get(_dmTrackKey, defaultValue: 0);
    return trackId != 0;
  }

  static Future clearDelmanTrack() async {
    localDb = await Hive.openBox(_boxKey);
    await localDb.delete(_dmTrackKey);
  }
}
