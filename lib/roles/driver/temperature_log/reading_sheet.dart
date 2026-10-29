import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/driver/temperature_log/vehicle_picker_sheet.dart';

/// Records today's [slot] reading, or replaces it.
Future<void> showReadingSheet(LogSlot slot) =>
    Get.bottomSheet(ReadingSheet(slot: slot), isScrollControlled: true);

class ReadingSheet extends StatefulWidget {
  final LogSlot slot;
  const ReadingSheet({super.key, required this.slot});

  @override
  State<ReadingSheet> createState() => _ReadingSheetState();
}

class _ReadingSheetState extends State<ReadingSheet> {
  // What the server takes: °C to one decimal within −30…60, % within 0…100.
  static final _temperatureFormat = RegExp(r'^-?\d{0,2}([.,]\d?)?$');
  static final _humidityFormat = RegExp(r'^\d{0,3}([.,]\d?)?$');

  final _temperature = TextEditingController();
  final _humidity = TextEditingController();
  final _note = TextEditingController();

  /// Picked here when the day has no vehicle yet; sent with the reading.
  int? _vehicleId;
  File? _photo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // The out-of-range notice follows what is typed.
    _temperature.addListener(_refresh);
    _humidity.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _temperature.dispose();
    _humidity.dispose();
    _note.dispose();
    super.dispose();
  }

  static double? _parse(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  // Number pads (iOS's above all) have no minus key.
  void _toggleSign() {
    final text = _temperature.text;
    _temperature.text = text.startsWith('-') ? text.substring(1) : '-$text';
    _temperature.selection = TextSelection.collapsed(offset: _temperature.text.length);
  }

  Future<void> _save(TodayLog today) async {
    final vehicleId = today.hasVehicle ? null : _vehicleId;
    final temperature = _parse(_temperature);
    final humidity = _parse(_humidity);
    final note = _note.text.trim();
    if (!today.hasVehicle && vehicleId == null) {
      messageWarning('Машинаа сонгоно уу!');
      return;
    }
    if (temperature == null) {
      messageWarning('Температур оруулна уу!');
      return;
    }
    if (temperature < -30 || temperature > 60) {
      messageWarning('Температур −30…60°C хооронд байна!');
      return;
    }
    if (humidity == null) {
      messageWarning('Чийгшил оруулна уу!');
      return;
    }
    if (humidity > 100) {
      messageWarning('Чийгшил 0…100% хооронд байна!');
      return;
    }
    final outOfRange = today.limitsFor(vehicleId).isOutOfRange(temperature, humidity);
    if (outOfRange && note.isEmpty) {
      messageWarning('Авсан арга хэмжээгээ бичнэ үү!');
      return;
    }
    setState(() => _saving = true);
    final saved = await context.read<TemperatureLogProvider>().saveReading(
          slot: widget.slot,
          temperature: temperature,
          humidity: humidity,
          // The note field is hidden, and stale, once the values are back in range.
          correctiveNote: outOfRange ? note : null,
          photo: _photo,
          vehicleId: vehicleId,
        );
    if (!mounted) return;
    if (saved) {
      messageComplete('${widget.slot.label} үеийн хэмжилт бүртгэгдлээ');
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }

  void _choosePhotoSource() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Камераар авах'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Зургийн сангаас сонгох'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      if (source == ImageSource.camera && await Permission.camera.isDenied) {
        await Permission.camera.request();
      }
      final photo = await pickUploadImage(source);
      if (photo != null && mounted) setState(() => _photo = photo);
    } catch (e) {
      messageWarning('Зураг сонгох үед алдаа гарлаа!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = context.watch<TemperatureLogProvider>().today;
    if (today == null) {
      return const AppSheet(
        title: 'Хэмжилт бүртгэх',
        children: [EmptyState(compact: true, icon: Icons.cloud_off_rounded, title: 'Журнал ачаалагдаагүй байна')],
      );
    }
    final earlier = today.log?.reading(widget.slot);
    final limits = today.limitsFor(_vehicleId);
    final temperature = _parse(_temperature);
    final humidity = _parse(_humidity);
    final outOfRange =
        temperature != null && humidity != null && limits.isOutOfRange(temperature, humidity);
    final plate = today.log?.plate ?? today.vehicle(_vehicleId)?.plate;
    return AppSheet(
      title: '${widget.slot.label} үеийн хэмжилт',
      subtitle: plate == null ? limits.label : '$plate · ${limits.label}',
      closable: !_saving,
      footer: SheetButton(
        label: earlier == null ? 'Бүртгэх' : 'Дахин бүртгэх',
        icon: Icons.check_rounded,
        busy: _saving,
        onPressed: () => _save(today),
      ),
      children: [
        if (!today.hasVehicle) ...[
          const SheetLabel('Машин'),
          VehiclePicker(
            vehicles: today.vehicles,
            selectedId: _vehicleId,
            onSelected: (v) => setState(() => _vehicleId = v.id),
          ),
          const SizedBox(height: 12),
        ],
        if (earlier != null) ...[
          SheetNote(
            Icons.history_rounded,
            'Өмнө нь ${earlier.label} бүртгэсэн. Дахин бүртгэвэл солигдох ба өмнөх утга түүхэнд хадгалагдана.',
          ),
          const SizedBox(height: 16),
        ],
        const SheetLabel('Температур', trailing: '−30…60°C'),
        Row(
          spacing: 8,
          children: [
            _SignButton(negative: _temperature.text.startsWith('-'), onTap: _toggleSign),
            Expanded(
              child: SheetField(
                controller: _temperature,
                hint: '18.5',
                suffixText: '°C',
                autofocus: today.hasVehicle,
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                inputFormatters: [_matching(_temperatureFormat)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SheetLabel('Харьцангуй чийгшил', trailing: '0…100%'),
        SheetField(
          controller: _humidity,
          hint: '45',
          suffixText: '%',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_matching(_humidityFormat)],
        ),
        if (outOfRange) ...[
          const SizedBox(height: 16),
          _OutOfRangeNote(limits: limits),
          const SizedBox(height: 12),
          const SheetLabel('Авсан арга хэмжээ *'),
          SheetField(
            controller: _note,
            hint: 'Жишээ нь: Агааржуулагч асаасан',
            maxLines: 3,
            inputFormatters: [LengthLimitingTextInputFormatter(255)],
          ),
        ],
        const SizedBox(height: 16),
        const SheetLabel('Хэмжигчийн зураг', trailing: 'Заавал биш'),
        _PhotoField(
          photo: _photo,
          onPick: _choosePhotoSource,
          onRemove: () => setState(() => _photo = null),
        ),
        if (_photo == null && earlier?.photo != null) ...[
          const SizedBox(height: 8),
          const SheetNote(
            Icons.photo_outlined,
            'Шинэ зураг оруулахгүй бол өмнөх зураг хэвээр үлдэнэ.',
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  // Keeps the text only while the whole of it still matches [format].
  static TextInputFormatter _matching(RegExp format) => TextInputFormatter.withFunction(
        (old, next) => format.hasMatch(next.text) ? next : old,
      );
}

class _SignButton extends StatelessWidget {
  final bool negative;
  final VoidCallback onTap;
  const _SignButton({required this.negative, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Хасах тэмдэг',
      child: Material(
        color: negative ? primary.withValues(alpha: 0.12) : grey100,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 52,
            height: 50,
            child: Center(
              child: Text(
                '±',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: negative ? primary.shade700 : grey600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutOfRangeNote extends StatelessWidget {
  final LogLimits limits;
  const _OutOfRangeNote({required this.limits});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red.shade400),
          Expanded(
            child: Text(
              'Зөвшөөрөгдөх хязгаараас (${limits.label}) гарсан байна. Авсан арга хэмжээгээ бичнэ үү.',
              style: TextStyle(fontSize: 12.5, height: 1.4, color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoField extends StatelessWidget {
  final File? photo;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _PhotoField({required this.photo, required this.onPick, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final file = photo;
    if (file == null) {
      return OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.add_a_photo_outlined, size: 20),
        label: const Text('Зураг нэмэх'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: grey200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(file, height: 140, width: 140, fit: BoxFit.cover),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, size: 16, color: white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
