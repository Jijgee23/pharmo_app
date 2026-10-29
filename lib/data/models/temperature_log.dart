import 'package:pharmo_app/application/app_lite.dart';

// The vehicle temperature/humidity journal (GDP) a D or VS keeps: per day,
// the vehicle driven and two readings, leaving and returning.

/// When in the day a reading is taken.
enum LogSlot {
  start('S', 'Гарах'),
  end('E', 'Буцах');

  final String code;
  final String label;
  const LogSlot(this.code, this.label);
}

/// «18.5», «15»: a reading or limit as the printed sheet shows it.
String logValue(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

// Limits arrive as numbers or decimal strings, and null where unset.
double? _number(dynamic v) => v == null ? null : double.tryParse(v.toString());

/// What a vehicle must keep to: °C within [tempMin]…[tempMax], humidity at
/// most [humidityMax] %.
class LogLimits {
  final double tempMin;
  final double tempMax;
  final double humidityMax;

  const LogLimits({required this.tempMin, required this.tempMax, required this.humidityMax});

  /// The supplier defaults out of the box.
  static const standard = LogLimits(tempMin: 15, tempMax: 25, humidityMax: 60);

  factory LogLimits.fromJson(Map<String, dynamic>? json) {
    return LogLimits(
      tempMin: _number(json?['temp_min']) ?? standard.tempMin,
      tempMax: _number(json?['temp_max']) ?? standard.tempMax,
      humidityMax: _number(json?['humidity_max']) ?? standard.humidityMax,
    );
  }

  bool temperatureOff(double temperature) => temperature < tempMin || temperature > tempMax;
  bool humidityOff(double humidity) => humidity > humidityMax;

  /// A reading the server will flag, and refuse without a corrective note.
  bool isOutOfRange(double temperature, double humidity) =>
      temperatureOff(temperature) || humidityOff(humidity);

  /// «15…25°C · ≤60%».
  String get label => '${logValue(tempMin)}…${logValue(tempMax)}°C · ≤${logValue(humidityMax)}%';
}

/// A vehicle of the supplier's, to pick as today's.
class LogVehicle {
  final int id;
  final String plate;

  /// Its own limits where set, the supplier defaults otherwise.
  final LogLimits limits;
  final bool isActive;

  const LogVehicle({
    required this.id,
    required this.plate,
    required this.limits,
    required this.isActive,
  });

  factory LogVehicle.fromJson(Map<String, dynamic> json) {
    return LogVehicle(
      id: parseInt(json['id']),
      plate: json['plate']?.toString() ?? '',
      limits: LogLimits.fromJson(json['limits']),
      isActive: json['is_active'] ?? true,
    );
  }
}

/// One reading: what the meter showed, and when the server took it.
class LogReading {
  final int id;
  final double temperature;
  final double humidity;
  final String? recordedOn;

  /// Outside the day's limits (red on the sheet).
  final bool outOfRange;

  /// What was done about it; there whenever [outOfRange].
  final String? correctiveNote;

  /// The meter display's photo, a full URL.
  final String? photo;

  /// Entered or corrected by the supplier (* on the sheet).
  final bool byAdmin;

  const LogReading({
    required this.id,
    required this.temperature,
    required this.humidity,
    this.recordedOn,
    this.outOfRange = false,
    this.correctiveNote,
    this.photo,
    this.byAdmin = false,
  });

  factory LogReading.fromJson(Map<String, dynamic> json) {
    return LogReading(
      id: parseInt(json['id']),
      temperature: _number(json['temperature']) ?? 0,
      humidity: _number(json['humidity']) ?? 0,
      recordedOn: json['recorded_at'],
      outOfRange: json['out_of_range'] ?? false,
      correctiveNote: json['corrective_note'],
      photo: json['photo'],
      byAdmin: json['by_admin'] ?? false,
    );
  }

  DateTime? get recordedAt => parseDateTime(recordedOn);

  /// «18.5°C · 45%».
  String get label => '${logValue(temperature)}°C · ${logValue(humidity)}%';
}

/// A day of the journal: the vehicle with the limits copied from it when
/// picked, and the leaving and returning readings, either still missing.
class DayLog {
  final int id;
  final String date;
  final int? vehicleId;
  final String? plate;
  final LogLimits limits;
  final String? note;
  final LogReading? start;
  final LogReading? end;

  const DayLog({
    required this.id,
    required this.date,
    this.vehicleId,
    this.plate,
    required this.limits,
    this.note,
    this.start,
    this.end,
  });

  factory DayLog.fromJson(Map<String, dynamic> json) {
    return DayLog(
      id: parseInt(json['id']),
      date: json['date'].toString(),
      vehicleId: json['vehicle_id'] == null ? null : parseInt(json['vehicle_id']),
      plate: json['plate'],
      limits: LogLimits.fromJson(json),
      note: json['note'],
      start: json['start'] is Map ? LogReading.fromJson(json['start']) : null,
      end: json['end'] is Map ? LogReading.fromJson(json['end']) : null,
    );
  }

  LogReading? reading(LogSlot slot) => slot == LogSlot.start ? start : end;
}

/// Today's journal (GET delivery/log/today/): the row so far, the vehicles
/// to pick from and the supplier's default limits.
class TodayLog {
  final String date;

  /// Null until a vehicle is picked or a reading taken.
  final DayLog? log;

  /// Active ones only.
  final List<LogVehicle> vehicles;
  final LogLimits defaults;

  /// The supplier closed the month after printing it: nothing can be written.
  final bool closed;

  const TodayLog({
    required this.date,
    this.log,
    required this.vehicles,
    required this.defaults,
    this.closed = false,
  });

  factory TodayLog.fromJson(Map<String, dynamic> json) {
    return TodayLog(
      date: json['date'].toString(),
      log: json['log'] is Map ? DayLog.fromJson(json['log']) : null,
      vehicles: (json['vehicles'] as List? ?? []).map((e) => LogVehicle.fromJson(e)).toList(),
      defaults: LogLimits.fromJson(json['defaults']),
      closed: json['closed'] == true,
    );
  }

  bool get hasVehicle => log?.vehicleId != null;

  LogVehicle? vehicle(int? id) => vehicles.where((v) => v.id == id).firstOrNull;

  /// What a reading taken now is checked against: the day's limits once it
  /// has a vehicle, else those of [vehicleId] about to be picked with it,
  /// else the supplier defaults.
  LogLimits limitsFor(int? vehicleId) {
    final day = log;
    if (day != null && day.vehicleId != null && (vehicleId == null || vehicleId == day.vehicleId)) {
      return day.limits;
    }
    return vehicle(vehicleId)?.limits ?? defaults;
  }

  TodayLog withLog(DayLog log) =>
      TodayLog(date: date, log: log, vehicles: vehicles, defaults: defaults, closed: closed);
}

/// When and by whom the supplier closed a month.
class LogClosed {
  final String? closedOn;
  final String? closedBy;

  const LogClosed({this.closedOn, this.closedBy});

  /// Null while the month is open.
  static LogClosed? fromJson(dynamic json) {
    if (json is! Map) return null;
    return LogClosed(closedOn: json['closed_at'], closedBy: json['closed_by']?.toString());
  }

  DateTime? get closedAt => parseDateTime(closedOn);
}

/// A calendar day of a [MonthLog]; [log] is null when nothing was recorded.
class MonthLogRow {
  final String date;
  final DayLog? log;

  const MonthLogRow({required this.date, this.log});

  factory MonthLogRow.fromJson(Map<String, dynamic> json) {
    return MonthLogRow(
      date: json['date'].toString(),
      log: json['log'] is Map ? DayLog.fromJson(json['log']) : null,
    );
  }

  DateTime? get day => DateTime.tryParse(date);
}

/// The caller's journal for a month (GET delivery/log/my/), a row per
/// calendar day: what the printed sheet shows.
class MonthLog {
  /// «2026-10».
  final String month;
  final LogClosed? closed;
  final LogLimits defaults;
  final List<MonthLogRow> rows;

  const MonthLog({required this.month, this.closed, required this.defaults, required this.rows});

  factory MonthLog.fromJson(Map<String, dynamic> json) {
    return MonthLog(
      month: json['month'].toString(),
      closed: LogClosed.fromJson(json['closed']),
      defaults: LogLimits.fromJson(json['defaults']),
      rows: (json['rows'] as List? ?? []).map((e) => MonthLogRow.fromJson(e)).toList(),
    );
  }
}
