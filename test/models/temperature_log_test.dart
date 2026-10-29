import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/application/application.dart';

// Shapes from the API docs (v1.20.0), Delivery / Temperature log.
const _reading = {
  'id': 41,
  'slot': 'S',
  'temperature': 18.5,
  'humidity': 45.0,
  'recorded_at': '2026-10-29T08:42:10',
  'out_of_range': false,
  'corrective_note': null,
  'photo': 'https://pharmo.mn/media/delivery_log/12/202610/2026-10-29_88_S.jpg',
  'by_admin': false,
};

const _day = {
  'id': 305,
  'date': '2026-10-29',
  'vehicle_id': 3,
  'plate': '1234УБА',
  'temp_min': 15.0,
  'temp_max': 25.0,
  'humidity_max': 60.0,
  'note': null,
  'start': _reading,
  'end': null,
};

const _vehicles = [
  {
    'id': 3,
    'plate': '1234УБА',
    'temp_min': null,
    'temp_max': null,
    'humidity_max': null,
    'limits': {'temp_min': 15.0, 'temp_max': 25.0, 'humidity_max': 60.0},
    'is_active': true,
  },
  {
    'id': 4,
    'plate': '5678УНА',
    'temp_min': '2.0',
    'temp_max': '8.0',
    'humidity_max': null,
    'limits': {'temp_min': '2.0', 'temp_max': '8.0', 'humidity_max': '60.0'},
    'is_active': true,
  },
];

const _defaults = {'temp_min': 15.0, 'temp_max': 25.0, 'humidity_max': 60.0};

void main() {
  group('TodayLog.fromJson', () {
    test('reads a day with the leaving reading only', () {
      final today = TodayLog.fromJson({
        'date': '2026-10-29',
        'log': _day,
        'vehicles': _vehicles,
        'defaults': _defaults,
        'closed': false,
      });
      expect(today.closed, isFalse);
      expect(today.hasVehicle, isTrue);
      final log = today.log!;
      expect(log.plate, '1234УБА');
      expect(log.limits.tempMax, 25);
      expect(log.reading(LogSlot.start)!.temperature, 18.5);
      expect(log.reading(LogSlot.start)!.recordedAt, DateTime(2026, 10, 29, 8, 42, 10));
      expect(log.reading(LogSlot.end), isNull);
    });

    test('has no row before the first vehicle pick', () {
      final today = TodayLog.fromJson({
        'date': '2026-10-29',
        'log': null,
        'vehicles': _vehicles,
        'defaults': _defaults,
        'closed': true,
      });
      expect(today.log, isNull);
      expect(today.hasVehicle, isFalse);
      expect(today.closed, isTrue);
    });

    test('reads vehicle limits sent as numbers or decimal strings', () {
      final today = TodayLog.fromJson(
          {'date': '2026-10-29', 'log': null, 'vehicles': _vehicles, 'defaults': _defaults});
      expect(today.vehicle(4)!.limits.tempMin, 2);
      expect(today.vehicle(4)!.limits.tempMax, 8);
      expect(today.vehicle(4)!.limits.humidityMax, 60);
    });
  });

  group('TodayLog.limitsFor', () {
    test('takes the day\'s limits once it has a vehicle', () {
      final today = TodayLog.fromJson(
          {'date': '2026-10-29', 'log': _day, 'vehicles': _vehicles, 'defaults': _defaults});
      expect(today.limitsFor(null).tempMax, 25);
    });

    test('takes the vehicle about to be picked, else the defaults', () {
      final today = TodayLog.fromJson({
        'date': '2026-10-29',
        'log': null,
        'vehicles': _vehicles,
        'defaults': {'temp_min': 10, 'temp_max': 20, 'humidity_max': 50},
      });
      expect(today.limitsFor(4).tempMax, 8);
      expect(today.limitsFor(null).tempMax, 20);
      expect(today.limitsFor(99).tempMax, 20);
    });
  });

  group('LogLimits.isOutOfRange', () {
    const limits = LogLimits(tempMin: 15, tempMax: 25, humidityMax: 60);

    test('the limits themselves are within range', () {
      expect(limits.isOutOfRange(15, 60), isFalse);
      expect(limits.isOutOfRange(25, 0), isFalse);
    });

    test('anything past them is out', () {
      expect(limits.isOutOfRange(14.9, 45), isTrue);
      expect(limits.isOutOfRange(25.1, 45), isTrue);
      expect(limits.isOutOfRange(20, 60.1), isTrue);
    });

    test('labels as the sheet does', () {
      expect(limits.label, '15…25°C · ≤60%');
      expect(const LogLimits(tempMin: 2.5, tempMax: 8, humidityMax: 60).label, '2.5…8°C · ≤60%');
    });
  });

  group('MonthLog.fromJson', () {
    test('a day per row, null where nothing was recorded, and an open month', () {
      final month = MonthLog.fromJson({
        'delman': {'id': 88, 'name': 'Бат'},
        'month': '2026-10',
        'closed': null,
        'defaults': _defaults,
        'rows': [
          {'date': '2026-10-01', 'log': null},
          {'date': '2026-10-29', 'log': _day},
        ],
      });
      expect(month.closed, isNull);
      expect(month.rows, hasLength(2));
      expect(month.rows.first.log, isNull);
      expect(month.rows.first.day, DateTime(2026, 10, 1));
      expect(month.rows.last.log!.start!.humidity, 45);
    });

    test('a closed month says when and by whom', () {
      final month = MonthLog.fromJson({
        'month': '2026-10',
        'closed': {'closed_at': '2026-11-02T10:15:00.000', 'closed_by': 'Сараа'},
        'defaults': _defaults,
        'rows': [],
      });
      expect(month.closed!.closedBy, 'Сараа');
      expect(month.closed!.closedAt, DateTime(2026, 11, 2, 10, 15));
    });
  });

  group('TemperatureLogProvider.errorMessage', () {
    test('shows the server\'s visible_error as is', () {
      expect(
        TemperatureLogProvider.errorMessage(
            {'visible_error': 'Энэ сарын журнал хаагдсан тул өөрчлөх боломжгүй!'}),
        'Энэ сарын журнал хаагдсан тул өөрчлөх боломжгүй!',
      );
    });

    test('puts the field codes in Mongolian', () {
      expect(
        TemperatureLogProvider.errorMessage({
          'vehicle_id': ['vehicle_required'],
        }),
        'Машинаа сонгоно уу!',
      );
      expect(
        TemperatureLogProvider.errorMessage({
          'corrective_note': ['required_when_out_of_range'],
        }),
        contains('арга хэмжээ'),
      );
    });
  });
}
