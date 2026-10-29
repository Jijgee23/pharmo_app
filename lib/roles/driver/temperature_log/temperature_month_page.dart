import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/temperature_log/log_widgets.dart';
import 'package:pharmo_app/roles/seller/report/month_picker.dart';
import 'package:pharmo_app/roles/seller/report/seller_report.dart' show MonthButton;

// Monday first, as DateTime.weekday counts.
const _weekdays = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];

/// The deliveryman's journal for a month, read-only: a row per calendar
/// day, as the printed sheet shows it.
class TemperatureMonthPage extends StatefulWidget {
  const TemperatureMonthPage({super.key});

  @override
  State<TemperatureMonthPage> createState() => _TemperatureMonthPageState();
}

class _TemperatureMonthPageState extends State<TemperatureMonthPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<TemperatureLogProvider>().loadMonth());
  }

  Future<void> _pickMonth(TemperatureLogProvider logs) async {
    final picked = await showMonthPicker(
      title: 'Сар сонгох',
      initial: logs.selectedMonth,
      // The journal started with API v1.20.0.
      first: DateTime(2026, 10),
      last: DateTime.now(),
    );
    if (picked != null) await logs.loadMonth(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemperatureLogProvider>(
      builder: (context, logs, child) => Scaffold(
        backgroundColor: grey50,
        appBar: const SideAppBar(text: 'Сарын журнал'),
        body: RefreshIndicator(
          onRefresh: logs.loadMonth,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.of(context).padding.bottom),
            children: [
              Row(
                children: [
                  MonthButton(
                    label: 'Сар',
                    month: logs.selectedMonth,
                    onTap: () => _pickMonth(logs),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._content(logs),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(TemperatureLogProvider logs) {
    final month = logs.month;
    if (month == null) {
      if (logs.monthLoading) {
        return const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
        ];
      }
      return [
        EmptyState(
          compact: true,
          icon: Icons.cloud_off_rounded,
          title: 'Журналыг ачаалж чадсангүй',
          message: 'Сүлжээгээ шалгаад дахин оролдоно уу.',
          actionLabel: 'Дахин оролдох',
          onAction: logs.loadMonth,
          color: Colors.red,
        ),
      ];
    }
    final closed = month.closed;
    final closedAt = closed?.closedAt;
    final today = TemperatureLogProvider.monthParam(DateTime.now()) == month.month
        ? DateTime.now().toIso8601String().substring(0, 10)
        : null;
    return [
      if (logs.monthLoading) const LinearProgressIndicator(minHeight: 2),
      if (closed != null) ...[
        LogClosedBanner(
          detail: [
            if (closedAt != null) friendlyDateTime(closedAt),
            if (closed.closedBy != null) closed.closedBy!,
          ].join(' · '),
        ),
        const SizedBox(height: 12),
      ],
      Wrap(
        spacing: 16,
        runSpacing: 4,
        children: [
          _legend(Text('18°', style: TextStyle(fontSize: 12, color: Colors.red.shade700)),
              'Хязгаараас гарсан'),
          _legend(Text('*', style: TextStyle(fontSize: 13, color: grey600)),
              'Админ оруулсан, зассан'),
        ],
      ),
      const SizedBox(height: 10),
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: grey200),
        ),
        child: Column(
          children: [
            const _HeaderRow(),
            for (final row in month.rows)
              _DayRow(
                row: row,
                isToday: row.date == today,
                onTap: row.log == null ? null : () => _showDay(row.log!),
              ),
          ],
        ),
      ),
    ];
  }

  Widget _legend(Widget mark, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [mark, Text(text, style: TextStyle(fontSize: 12, color: grey500))],
    );
  }

  void _showDay(DayLog log) {
    Get.bottomSheet(_DaySheet(log: log), isScrollControlled: true);
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: grey500);
    return Container(
      color: grey100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Өдөр', style: style)),
          Expanded(flex: 3, child: Text('Машин', style: style)),
          Expanded(flex: 3, child: Text(LogSlot.start.label, style: style)),
          Expanded(flex: 3, child: Text(LogSlot.end.label, style: style)),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final MonthLogRow row;
  final bool isToday;
  final VoidCallback? onTap;

  const _DayRow({required this.row, required this.isToday, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final day = row.day;
    final log = row.log;
    final muted = log == null;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isToday ? primary.withValues(alpha: 0.06) : null,
          border: Border(top: BorderSide(color: grey100)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                spacing: 4,
                children: [
                  Text(
                    day == null ? row.date : '${day.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: muted ? grey400 : Colors.grey.shade900,
                    ),
                  ),
                  if (day != null)
                    Text(_weekdays[day.weekday - 1], style: TextStyle(fontSize: 11, color: grey400)),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                log?.plate ?? '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: muted ? grey400 : grey600),
              ),
            ),
            Expanded(flex: 3, child: _ReadingCell(reading: log?.start, limits: log?.limits)),
            Expanded(flex: 3, child: _ReadingCell(reading: log?.end, limits: log?.limits)),
          ],
        ),
      ),
    );
  }
}

class _ReadingCell extends StatelessWidget {
  final LogReading? reading;
  final LogLimits? limits;
  const _ReadingCell({required this.reading, required this.limits});

  @override
  Widget build(BuildContext context) {
    final reading = this.reading;
    if (reading == null) return Text('—', style: TextStyle(fontSize: 13, color: grey400));
    final mark = reading.byAdmin ? '*' : '';
    TextStyle style(bool off, double size) => TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w600,
          color: off ? Colors.red.shade700 : Colors.grey.shade900,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${logValue(reading.temperature)}°$mark',
          style: style(limits?.temperatureOff(reading.temperature) ?? reading.outOfRange, 13.5),
        ),
        Text(
          '${logValue(reading.humidity)}%',
          style: style(limits?.humidityOff(reading.humidity) ?? false, 11.5),
        ),
      ],
    );
  }
}

/// A recorded day in full: both readings with their time, note and photo.
class _DaySheet extends StatelessWidget {
  final DayLog log;
  const _DaySheet({required this.log});

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: logDateLabel(log.date),
      subtitle: [if (log.plate != null) log.plate!, log.limits.label].join(' · '),
      children: [
        for (final slot in LogSlot.values) ...[
          _ReadingDetail(slot: slot, reading: log.reading(slot), limits: log.limits),
          const SizedBox(height: 16),
        ],
        if (log.note != null && log.note!.isNotEmpty) ...[
          SheetNote(Icons.notes_rounded, log.note!),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ReadingDetail extends StatelessWidget {
  final LogSlot slot;
  final LogReading? reading;
  final LogLimits limits;

  const _ReadingDetail({required this.slot, required this.reading, required this.limits});

  @override
  Widget build(BuildContext context) {
    final reading = this.reading;
    if (reading == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetLabel(slot.label),
          const SheetNote(Icons.remove_rounded, 'Бүртгээгүй'),
        ],
      );
    }
    final recordedAt = reading.recordedAt;
    final off = reading.outOfRange;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetLabel(
          slot.label,
          trailing: [
            if (recordedAt != null) hourMinute(recordedAt),
            if (reading.byAdmin) '* админ',
          ].join(' · '),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: off ? Colors.red.withValues(alpha: 0.06) : grey50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${logValue(reading.temperature)}°C',
                      style: TextStyle(
                        color: limits.temperatureOff(reading.temperature) ? Colors.red.shade700 : null,
                      ),
                    ),
                    const TextSpan(text: '  ·  '),
                    TextSpan(
                      text: '${logValue(reading.humidity)}%',
                      style: TextStyle(
                        color: limits.humidityOff(reading.humidity) ? Colors.red.shade700 : null,
                      ),
                    ),
                  ],
                ),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade900,
                ),
              ),
              if (off)
                Text(
                  'Авсан арга хэмжээ: ${reading.correctiveNote ?? '—'}',
                  style: TextStyle(fontSize: 12.5, height: 1.4, color: Colors.red.shade700),
                ),
              if (reading.photo != null) ReadingPhoto(url: reading.photo!, size: 120),
            ],
          ),
        ),
      ],
    );
  }
}
