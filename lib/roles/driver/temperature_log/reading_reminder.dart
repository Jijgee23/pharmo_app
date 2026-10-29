import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/temperature_log/reading_sheet.dart';

/// After a delivery has started ([LogSlot.start]) or ended ([LogSlot.end]):
/// if today's [slot] reading is still missing, offers to record it now.
///
/// Only ever a reminder: the backend never makes the journal a condition of
/// starting or ending a delivery, so neither does the app, and anything
/// going wrong here stays quiet.
Future<void> remindReading(LogSlot slot) async {
  final logs = Get.context?.read<TemperatureLogProvider>();
  if (logs == null || !await logs.loadToday()) return;
  final today = logs.today;
  if (today == null || today.closed || today.log?.reading(slot) != null) return;
  // A supplier with no vehicles doesn't keep the journal.
  if (today.log == null && today.vehicles.isEmpty) return;
  final record = await confirmDialog(
    title: 'Температур бүртгэх үү?',
    message:
        'Өнөөдрийн ${slot.label.toLowerCase()} үеийн температур, чийгшил бүртгэгдээгүй байна.',
  );
  if (record) await showReadingSheet(slot);
}
