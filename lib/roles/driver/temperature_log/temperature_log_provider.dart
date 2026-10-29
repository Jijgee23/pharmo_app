import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:pharmo_app/application/application.dart' hide Response, FormData, MultipartFile;

/// The deliveryman's vehicle temperature/humidity journal (D and VS): today's
/// row, where the vehicle is picked and the leaving and returning readings
/// are taken, and a month of it to read.
///
/// The journal is a GDP record: only today can be written, the server stamps
/// the time, and a month the supplier has closed answers every write with a
/// `visible_error`.
class TemperatureLogProvider extends ChangeNotifier {
  void reset() {
    today = null;
    todayLoaded = false;
    todayFailed = false;
    month = null;
    monthLoading = false;
    selectedMonth = _thisMonth();
    _monthRequest++;
    notifyListeners();
  }

  TodayLog? today;

  /// The first fetch of [today] has come back (either way).
  bool todayLoaded = false;

  /// The last fetch failed, so [today] may be out of date or missing.
  bool todayFailed = false;

  /// Today's row, the vehicles to pick from and the default limits
  /// (GET delivery/log/today/). True once known.
  Future<bool> loadToday() async {
    try {
      final r = await api(Api.get, 'delivery/log/today/');
      if (r == null || r.statusCode != 200) {
        todayFailed = true;
        return false;
      }
      today = TodayLog.fromJson(convertData(r));
      todayFailed = false;
      return true;
    } catch (e) {
      debugPrint('loadToday: $e');
      todayFailed = true;
      return false;
    } finally {
      todayLoaded = true;
      notifyListeners();
    }
  }

  /// Sets today's vehicle (POST delivery/log/today/); readings already taken
  /// are re-checked against its limits. True once set.
  Future<bool> pickVehicle(int vehicleId) async {
    try {
      final r = await api(Api.post, 'delivery/log/today/', body: {'vehicle_id': vehicleId});
      if (r == null) {
        messageWarning('Сервертэй холбогдож чадсангүй!');
        return false;
      }
      if (r.statusCode == 200 || r.statusCode == 201) {
        await _setDay(convertData(r));
        return true;
      }
      messageWarning(errorMessage(apiBody(r)));
      return false;
    } catch (e) {
      debugPrint('pickVehicle: $e');
      messageWarning(wait);
      return false;
    }
  }

  /// Records today's [slot] reading (POST delivery/log/today/reading/,
  /// multipart); sent again, it replaces the earlier one. [vehicleId] picks
  /// the vehicle in the same call when the day has none; without a [photo]
  /// an earlier one is kept. True once recorded.
  Future<bool> saveReading({
    required LogSlot slot,
    required double temperature,
    required double humidity,
    String? correctiveNote,
    File? photo,
    int? vehicleId,
  }) async {
    try {
      // Through ApiService.dio, which adds the Bearer token and refreshes
      // it; only the client header is set so Dio gives FormData its
      // multipart Content-Type.
      final r = await ApiService.dio.post(
        ApiService.buildUrl('delivery/log/today/reading/').toString(),
        data: FormData.fromMap({
          'slot': slot.code,
          'temperature': temperature.toStringAsFixed(1),
          'humidity': humidity.toStringAsFixed(1),
          if (correctiveNote != null && correctiveNote.isNotEmpty) 'corrective_note': correctiveNote,
          if (vehicleId != null) 'vehicle_id': '$vehicleId',
          if (photo != null) 'photo': await ApiService.imagePart(photo),
        }),
        options: Options(headers: ApiService.clientHeader),
      );
      if (r.statusCode == 200 || r.statusCode == 201) {
        await _setDay(convertData(r));
        return true;
      }
      messageWarning(errorMessage(apiBody(r)));
      return false;
    } catch (e) {
      debugPrint('delivery/log/today/reading/ failed: $e');
      messageWarning('Сервертэй холбогдож чадсангүй!');
      return false;
    }
  }

  // A write answers with today's row: put it in place, or fetch everything
  // if today was never loaded.
  Future<void> _setDay(dynamic data) async {
    final day = DayLog.fromJson(data);
    if (today == null) {
      await loadToday();
      return;
    }
    today = today!.withLog(day);
    notifyListeners();
  }

  /// What to tell the deliveryman when a write is refused with [body]: the
  /// server's own `visible_error` as is, its field codes in Mongolian.
  static String errorMessage(Object? body) {
    if (body is Map && body['visible_error'] is String) return body['visible_error'];
    final text = apiErrorMessage(body) ?? '';
    return switch (text) {
      'vehicle_required' => 'Машинаа сонгоно уу!',
      'vehicle_not_found!' => 'Машин олдсонгүй эсвэл идэвхгүй болсон байна!',
      'required_when_out_of_range' =>
        'Хэмжилт зөвшөөрөгдөх хязгаараас гарсан тул авсан арга хэмжээгээ бичнэ үү!',
      '' => wait,
      _ => text,
    };
  }

  // The month view (GET delivery/log/my/).

  /// The month shown; its first day.
  DateTime selectedMonth = _thisMonth();
  MonthLog? month;
  bool monthLoading = false;

  // Bumped per load: a month arriving after another was picked is dropped.
  int _monthRequest = 0;

  static DateTime _thisMonth() => DateTime(DateTime.now().year, DateTime.now().month);

  /// «2026-10», as month= takes it.
  static String monthParam(DateTime m) => '${m.year}-${'${m.month}'.padLeft(2, '0')}';

  /// Loads [m] (or [selectedMonth] again); [month] is null if it can't be had.
  Future<void> loadMonth([DateTime? m]) async {
    if (m != null) selectedMonth = DateTime(m.year, m.month);
    final request = ++_monthRequest;
    monthLoading = true;
    notifyListeners();
    MonthLog? loaded;
    try {
      final endpoint = Uri(
        path: 'delivery/log/my/',
        queryParameters: {'month': monthParam(selectedMonth)},
      ).toString();
      final r = await api(Api.get, endpoint);
      if (r != null && r.statusCode == 200) loaded = MonthLog.fromJson(convertData(r));
    } catch (e) {
      debugPrint('loadMonth: $e');
    }
    if (request != _monthRequest) return;
    month = loaded;
    monthLoading = false;
    notifyListeners();
  }
}
