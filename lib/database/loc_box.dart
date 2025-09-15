import 'package:hive/hive.dart';
import 'loc_model.dart';

class LocBox {
  static const String boxName = 'locBox';

  static const String hasTrack = 'track';

  static Future<bool> hasSellerTrack() async {
    final box = await Hive.openBox(hasTrack);
    int? value = box.get(hasTrack);
    return value != null && value != 0;
  }

  static Future saveHasSellerTrack(int id) async {
    final box = await Hive.openBox(hasTrack);
    if (box.isNotEmpty) {
      await box.clear();
    }
    await box.put(hasTrack, id);
    await box.flush();
  }

  static Future removeHasSellerTrack() async {
    final box = await Hive.openBox(hasTrack);
    await box.clear();
  }

  /// Box нээх
  static Future<Box<LocModel>> openBox() async {
    return await Hive.openBox<LocModel>(boxName);
  }

  /// List авах
  static Future<List<LocModel>> getList() async {
    final box = await openBox();
    return box.values.toList();
  }

  /// Шинэ model нэмэх
  static Future<void> addToList(LocModel loc) async {
    final box = await openBox();
    await box.add(loc);
  }

  /// Model хадгалах (update)
  static Future<void> saveModel(LocModel loc) async {
    await loc.save();
  }

  /// Model устгах
  static Future<void> deleteModel(LocModel loc) async {
    await loc.delete();
  }

  /// Бүх өгөгдлийг устгах
  static Future<void> clearAll() async {
    final box = await openBox();
    await box.clear();
  }
}
