import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/temperature_log/log_widgets.dart';
import 'package:pharmo_app/roles/driver/temperature_log/reading_sheet.dart';
import 'package:pharmo_app/roles/driver/temperature_log/temperature_month_page.dart';
import 'package:pharmo_app/roles/driver/temperature_log/vehicle_picker_sheet.dart';

/// Today's row of the vehicle temperature/humidity journal: the vehicle,
/// and the leaving and returning readings to take.
class TemperatureLogPage extends StatefulWidget {
  const TemperatureLogPage({super.key});

  @override
  State<TemperatureLogPage> createState() => _TemperatureLogPageState();
}

class _TemperatureLogPageState extends State<TemperatureLogPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<TemperatureLogProvider>().loadToday());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemperatureLogProvider>(
      builder: (context, logs, child) => Scaffold(
        backgroundColor: grey50,
        appBar: SideAppBar(
          text: 'Температурын журнал',
          action: IconButton(
            tooltip: 'Сарын журнал',
            onPressed: () => goto(const TemperatureMonthPage()),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ),
        body: _body(logs),
      ),
    );
  }

  Widget _body(TemperatureLogProvider logs) {
    final today = logs.today;
    if (today == null) {
      if (!logs.todayLoaded) return const Center(child: CircularProgressIndicator());
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Журналыг ачаалж чадсангүй',
        message: 'Сүлжээгээ шалгаад дахин оролдоно уу.',
        actionLabel: 'Дахин оролдох',
        onAction: logs.loadToday,
        color: Colors.red,
      );
    }
    final writable = !today.closed;
    final log = today.log;
    return RefreshIndicator(
      onRefresh: logs.loadToday,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.of(context).padding.bottom),
        children: [
          Text(
            'Өнөөдөр · ${logDateLabel(today.date)}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: grey600),
          ),
          const SizedBox(height: 10),
          if (today.closed) ...[
            const LogClosedBanner(),
            const SizedBox(height: 12),
          ],
          _VehicleCard(
            today: today,
            onChange: writable && today.vehicles.isNotEmpty ? showVehiclePickerSheet : null,
          ),
          const SizedBox(height: 12),
          for (final slot in LogSlot.values) ...[
            _SlotCard(
              slot: slot,
              reading: log?.reading(slot),
              limits: today.limitsFor(null),
              onRecord: writable ? () => showReadingSheet(slot) : null,
            ),
            const SizedBox(height: 12),
          ],
          const SheetNote(
            Icons.info_outline_rounded,
            'Агуулахаас гарахдаа болон буцаж ирэхдээ машины доторх температур, чийгшлийг хэмжиж бүртгэнэ. Хэмжилтийн цагийг сервер тэмдэглэнэ.',
          ),
        ],
      ),
    );
  }
}

BoxDecoration _card({Color? border}) => BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: border ?? grey200),
    );

class _VehicleCard extends StatelessWidget {
  final TodayLog today;

  /// Null when the vehicle can't be picked: the month is closed, or the
  /// supplier has no vehicles.
  final VoidCallback? onChange;

  const _VehicleCard({required this.today, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final plate = today.log?.plate;
    final String title;
    final String subtitle;
    if (plate != null) {
      title = plate;
      subtitle = today.limitsFor(null).label;
    } else if (today.vehicles.isEmpty) {
      title = 'Машин бүртгэгдээгүй';
      subtitle = 'Танай байгууллагад машин бүртгэгдээгүй байна. Админд хандана уу.';
    } else {
      title = 'Машин сонгоогүй';
      subtitle = 'Түгээлтэд явах машинаа сонгоно уу';
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(),
      child: Row(
        spacing: 12,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: primary.withValues(alpha: 0.12),
            child: Icon(Icons.local_shipping_outlined, color: primary.shade700),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: plate == null ? grey600 : Colors.grey.shade900,
                  ),
                ),
                Text(subtitle, style: TextStyle(fontSize: 12.5, color: grey500)),
              ],
            ),
          ),
          if (onChange != null)
            TextButton(onPressed: onChange, child: Text(plate == null ? 'Сонгох' : 'Солих')),
        ],
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final LogSlot slot;
  final LogReading? reading;

  /// The day's, to mark which value is off.
  final LogLimits limits;

  /// Null once the month is closed.
  final VoidCallback? onRecord;

  const _SlotCard({
    required this.slot,
    required this.reading,
    required this.limits,
    required this.onRecord,
  });

  @override
  Widget build(BuildContext context) {
    final reading = this.reading;
    final off = reading?.outOfRange ?? false;
    final recordedAt = reading?.recordedAt;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(border: off ? Colors.red.shade200 : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 12,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: (reading == null ? grey400 : Colors.green).withValues(alpha: 0.12),
                child: Icon(
                  slot == LogSlot.start ? Icons.logout_rounded : Icons.login_rounded,
                  size: 18,
                  color: reading == null ? grey600 : Colors.green.shade700,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      slot.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    Text(
                      slot == LogSlot.start ? 'Агуулахаас гарахад' : 'Буцаж ирэхэд',
                      style: TextStyle(fontSize: 12, color: grey500),
                    ),
                  ],
                ),
              ),
              Text(
                reading == null
                    ? 'Бүртгээгүй'
                    : [
                        if (recordedAt != null) hourMinute(recordedAt),
                        if (reading.byAdmin) '*',
                      ].join(' '),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: reading == null ? grey400 : grey600,
                ),
              ),
            ],
          ),
          if (reading != null) ...[
            const SizedBox(height: 12),
            Row(
              spacing: 16,
              children: [
                _Value(
                  icon: Icons.thermostat_rounded,
                  text: '${logValue(reading.temperature)}°C',
                  off: limits.temperatureOff(reading.temperature),
                ),
                _Value(
                  icon: Icons.water_drop_outlined,
                  text: '${logValue(reading.humidity)}%',
                  off: limits.humidityOff(reading.humidity),
                ),
                const Spacer(),
                if (reading.photo != null) ReadingPhoto(url: reading.photo!, size: 52),
              ],
            ),
            if (off) ...[
              const SizedBox(height: 10),
              Text(
                'Хязгаараас гарсан${reading.correctiveNote == null ? '' : ' · ${reading.correctiveNote}'}',
                style: TextStyle(fontSize: 12.5, height: 1.4, color: Colors.red.shade700),
              ),
            ],
          ],
          if (onRecord != null) ...[
            const SizedBox(height: 12),
            reading == null
                ? FilledButton.icon(
                    onPressed: onRecord,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Бүртгэх'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: onRecord,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Дахин бүртгэх'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: grey200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool off;
  const _Value({required this.icon, required this.text, required this.off});

  @override
  Widget build(BuildContext context) {
    final color = off ? Colors.red.shade700 : Colors.grey.shade900;
    return Row(
      spacing: 4,
      children: [
        Icon(icon, size: 20, color: off ? Colors.red.shade400 : grey500),
        Text(text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}
