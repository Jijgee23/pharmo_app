import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pharmo_app/application/application.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:qr/qr.dart';

class PrinterProvider extends ChangeNotifier {
  List<BluetoothInfo> devices = [];
  bool loading = false;
  void setloading(bool val) {
    loading = val;
    notifyListeners();
  }

  static const _boxName = 'printer_settings';
  static const _macKey = 'printer_mac';
  static const _printerName = 'printer_name';
  static const _paperSizeKey = 'paper_size';

  Future<BluetoothInfo?> _savedMac() async {
    final box = await Hive.openBox(_boxName);
    String? macAddress = await box.get(_macKey, defaultValue: null);
    if (macAddress == null) return null;
    String? printerName = await box.get(_printerName, defaultValue: null);
    return BluetoothInfo(name: printerName ?? "No name", macAdress: macAddress);
  }

  Future<void> _saveMac(BluetoothInfo device) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_macKey, device.macAdress);
    await box.put(_printerName, device.name);
  }

  Future<PaperSize?> getSavedPaperSize() async {
    final box = await Hive.openBox(_boxName);
    final val = box.get(_paperSizeKey, defaultValue: null);
    if (val == null) return null;
    return val == 'mm80' ? PaperSize.mm80 : PaperSize.mm58;
  }

  Future<void> _savePaperSize(PaperSize size) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_paperSizeKey, size == PaperSize.mm80 ? 'mm80' : 'mm58');
  }

  BluetoothInfo? savedBT;

  // CBCentralManager initializes asynchronously — first bluetoothEnabled call often
  // returns false before centralManagerDidUpdateState fires. Retry until poweredOn.
  Future<bool> _waitForBluetooth({int tries = 5}) async {
    for (int i = 0; i < tries; i++) {
      if (await PrintBluetoothThermal.bluetoothEnabled) return true;
      await Future.delayed(const Duration(milliseconds: 700));
    }
    return false;
  }

  // Called on PrintPreview open.
  // If a saved MAC exists → preview opens immediately, connect silently in background.
  // Otherwise → scan with loading spinner.
  Future<void> init() async {
    setloading(true);
    final mac = await _savedMac();
    if (mac == null) {
      await scanDevices();
      setloading(false);
      return;
    }
    // Fire-and-forget: preview is immediately visible, connection happens in background
    await _connectSaved(mac);
    setloading(false);
  }

  Future<void> _connectSaved(BluetoothInfo device) async {
    try {
      final bool enabled = await _waitForBluetooth();
      if (!enabled) return;
      devices = await PrintBluetoothThermal.pairedBluetooths;
      notifyListeners();
      BluetoothInfo? saved;
      try {
        saved = devices.firstWhere((d) => d.macAdress == device.macAdress);
      } catch (_) {}
      if (saved == null) return;
      final connected = await PrintBluetoothThermal.connect(macPrinterAddress: device.macAdress);
      if (connected) {
        connectedDevice = saved;
        if (connectedDevice != null) {
          await _saveMac(device);
        }
        notifyListeners();
      }
    } catch (_) {
      // ignore — user can still scan manually via refresh button
    }
  }

  Future scanDevices() async {
    setloading(true);
    try {
      final bool enabled = await _waitForBluetooth();
      if (enabled) {
        devices = await PrintBluetoothThermal.pairedBluetooths;
        connectedDevice = null;
        notifyListeners();
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      setloading(false);
    }
  }

  BluetoothInfo? connectedDevice;

  Future<void> printOrder(DeliveryOrder order, PaperSize papeSize, {int? deliveryId}) async {
    setloading(true);
    try {
      final bool connected = await PrintBluetoothThermal.connectionStatus;
      if (!connected) {
        messageWarning('Төхөөрөмж холбоно уу!');
        return;
      }
      final bytes = await generateTicket(order, papeSize, deliveryId: deliveryId);
      final result = await PrintBluetoothThermal.writeBytes(bytes);
      print("print result: $result");
      if (result) {
        if (connectedDevice != null) await _saveMac(connectedDevice!);
        await _savePaperSize(papeSize);
        messageComplete('Баримт хэвлэгдлээ!');
      } else {
        messageWarning('Хэвлэж чадсангүй');
      }
    } catch (e) {
      messageError('Хэвлэж чадсангүй');
      throw Exception(e);
    } finally {
      setloading(false);
    }
  }

  Future<List<int>> generateTicket(DeliveryOrder order, PaperSize paperSize,
      {int? deliveryId}) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    final user = Authenticator.security;
    final delmanName = user?.name ?? '';
    final customerName =
        order.orderer?.name ?? order.customer?.name ?? order.user?.name ?? 'Unknown';
    final dateStr =
        order.createdOn.length >= 10 ? order.createdOn.substring(0, 10) : order.createdOn;
    final nowStr = intl.DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    bytes += generator.reset();

    // Header — ASCII-only, ESC/POS text mode
    bytes += generator.text(
      'PHARMO',
      styles: PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    // Mongolian lines rendered as raster images — supports Ө Ү without substitution
    bytes += await _textLine('Захиалгын хуудас', paperSize, align: ui.TextAlign.center);
    bytes += generator.hr();

    // Order meta
    bytes += await _r2Image('Захиалга', '#${order.orderNo}', paperSize);
    bytes += await _r2Image('Захиалгын огноо', dateStr, paperSize);
    bytes += await _r2Image('Захиалагч', customerName, paperSize);
    bytes += await _r2Image('Төлбөр', order.paymentType.name, paperSize);
    bytes += await _r2Image('Түгээлт', '$delmanName (Тгг)', paperSize);
    bytes += await _r2Image('Түгээлтийн бүс', order.zone.name, paperSize);
    bytes += await _r2Image('НӨАТ', '${_numStr(order.totalPrice * 0.1)}₮', paperSize);
    if (deliveryId != null) {
      bytes += await _r2Image('Түгээлтийн №', '$deliveryId', paperSize);
    }
    bytes += await _r2Image('Баримтын огноо', nowStr, paperSize);
    bytes += generator.hr();

    // Item header
    bytes += await _r3Image('Бараа', 'Тоо', 'Үнэ', paperSize);
    bytes += generator.hr();

    for (final item in order.items) {
      final qtyNum = num.tryParse((item.qty).toString())?.toDouble() ?? 0;
      final total = num.tryParse((item.totalPrice).toString())?.toDouble() ?? 0;
      final unit = qtyNum > 0 ? total / qtyNum : 0.0;
      bytes += await _r3Image(
        item.name.toString(),
        qtyNum.toStringAsFixed(0),
        '${_numStr(unit)}₮',
        paperSize,
      );
    }

    bytes += generator.hr();

    // Totals
    bytes += await _r2Image('Нийт тоо', '${order.totalCount.toStringAsFixed(0)} ш', paperSize);
    bytes += await _r2Image('Нийт үнэ', '${_numStr(order.totalPrice)}₮', paperSize);

    if (order.payments.isNotEmpty) {
      bytes += generator.hr();
      for (final p in order.payments) {
        bytes += await _r2Image(p.payType, '${_numStr(p.amount)}₮', paperSize);
      }
    }

    bytes += generator.hr();

    // Sign section
    bytes += await _r2Image('Хүлээлгэн өгсөн', delmanName, paperSize);
    bytes += await _r2Image('Хүлээн авсан', '________________', paperSize);
    bytes += await _r2Image('Бүргүүлэх дүн', '${_numStr(order.totalPrice)}₮', paperSize);

    bytes += generator.hr();

    // QR code as raster bitmap
    bytes += _qrBitmap('#${order.orderNo}|${_numStr(order.totalPrice)}T|$dateStr');

    bytes += await _textLine('Баярлалаа!', paperSize, align: ui.TextAlign.center);
    bytes += generator.feed(3);

    return bytes;
  }

  // --- Raster text rendering (dart:ui) -----------------------------------

  static int _paperDots(PaperSize size) => size == PaperSize.mm80 ? 576 : 384;

  // RGBA pixels → ESC/POS GS v 0 raster command bytes
  List<int> _toBitmap(Uint8List pixels, int w, int h) {
    final wBytes = (w + 7) ~/ 8;
    final bmp = <int>[];
    for (int y = 0; y < h; y++) {
      for (int bx = 0; bx < wBytes; bx++) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          final x = bx * 8 + bit;
          if (x < w) {
            final pi = (y * w + x) * 4;
            final lum =
                (0.299 * pixels[pi] + 0.587 * pixels[pi + 1] + 0.114 * pixels[pi + 2]).round();
            if (lum < 128) byte |= (0x80 >> bit);
          }
        }
        bmp.add(byte);
      }
    }
    return [
      0x1D,
      0x76,
      0x30,
      0x00,
      wBytes & 0xFF,
      (wBytes >> 8) & 0xFF,
      h & 0xFF,
      (h >> 8) & 0xFF,
      ...bmp,
    ];
  }

  // Single text line rendered as raster — supports full Unicode (Ө Ү etc.)
  Future<List<int>> _textLine(
    String text,
    PaperSize paperSize, {
    ui.TextAlign align = ui.TextAlign.left,
    bool bold = false,
    bool large = false,
  }) async {
    final w = _paperDots(paperSize);
    final fs = large ? 44.0 : 22.0;
    final lh = (fs * 1.45).ceil();

    final rec = ui.PictureRecorder();
    final cvs = ui.Canvas(rec);
    cvs.drawRect(
      ui.Rect.fromLTWH(0, 0, w.toDouble(), lh.toDouble()),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );

    final para = (ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: align,
      fontSize: fs,
      fontWeight: bold ? ui.FontWeight.bold : ui.FontWeight.normal,
    ))
          ..pushStyle(ui.TextStyle(color: const ui.Color(0xFF000000)))
          ..addText(text))
        .build()
      ..layout(ui.ParagraphConstraints(width: w.toDouble()));

    cvs.drawParagraph(para, ui.Offset.zero);

    final img = await rec.endRecording().toImage(w, lh);
    final bd = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    return bd == null ? [] : _toBitmap(bd.buffer.asUint8List(), w, lh);
  }

  // 2-column raster line: label(left 58%) | value(right 42%)
  Future<List<int>> _r2Image(
    String label,
    String value,
    PaperSize paperSize, {
    bool bold = false,
  }) async {
    final w = _paperDots(paperSize);
    const fs = 22.0;
    final lh = (fs * 1.45).ceil();
    final fw = bold ? ui.FontWeight.bold : ui.FontWeight.normal;

    final rec = ui.PictureRecorder();
    final cvs = ui.Canvas(rec);
    cvs.drawRect(
      ui.Rect.fromLTWH(0, 0, w.toDouble(), lh.toDouble()),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );

    final ts = ui.TextStyle(color: const ui.Color(0xFF000000), fontSize: fs, fontWeight: fw);
    final lw = (w * 0.58).toDouble();
    final vw = w - lw;

    final lp = (ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: ui.TextAlign.left,
      fontSize: fs,
      fontWeight: fw,
      ellipsis: '…',
    ))
          ..pushStyle(ts)
          ..addText(label))
        .build()
      ..layout(ui.ParagraphConstraints(width: lw));
    cvs.drawParagraph(lp, ui.Offset.zero);

    final vp = (ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: ui.TextAlign.right,
      fontSize: fs,
      fontWeight: fw,
      ellipsis: '…',
    ))
          ..pushStyle(ts)
          ..addText(value))
        .build()
      ..layout(ui.ParagraphConstraints(width: vw));
    cvs.drawParagraph(vp, ui.Offset(lw, 0));

    final img = await rec.endRecording().toImage(w, lh);
    final bd = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    return bd == null ? [] : _toBitmap(bd.buffer.asUint8List(), w, lh);
  }

  // 3-column raster line: name(left 55%) | qty(center 17%) | price(right 28%)
  // Name wraps to additional lines; qty/price stay on the first line.
  Future<List<int>> _r3Image(
    String name,
    String qty,
    String price,
    PaperSize paperSize, {
    bool bold = false,
  }) async {
    final w = _paperDots(paperSize);
    const fs = 20.0;
    final minLh = (fs * 1.45).ceil();
    final fw = bold ? ui.FontWeight.bold : ui.FontWeight.normal;

    final ts = ui.TextStyle(color: const ui.Color(0xFF000000), fontSize: fs, fontWeight: fw);
    final nw = (w * 0.55).toDouble();
    final qw = (w * 0.17).toDouble();
    final pw = w - nw - qw;

    // Layout name first (no ellipsis) to measure wrapped height
    final np = (ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: ui.TextAlign.left,
      fontSize: fs,
      fontWeight: fw,
    ))
          ..pushStyle(ts)
          ..addText(name))
        .build()
      ..layout(ui.ParagraphConstraints(width: nw));

    final lh = np.height.ceil().clamp(minLh, 9999);

    final rec = ui.PictureRecorder();
    final cvs = ui.Canvas(rec);
    cvs.drawRect(
      ui.Rect.fromLTWH(0, 0, w.toDouble(), lh.toDouble()),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );

    cvs.drawParagraph(np, ui.Offset.zero);

    final qp = (ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: ui.TextAlign.center,
      fontSize: fs,
      fontWeight: fw,
    ))
          ..pushStyle(ts)
          ..addText(qty))
        .build()
      ..layout(ui.ParagraphConstraints(width: qw));
    cvs.drawParagraph(qp, ui.Offset(nw, 0));

    final pp = (ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: ui.TextAlign.right,
      fontSize: fs,
      fontWeight: fw,
      ellipsis: '…',
    ))
          ..pushStyle(ts)
          ..addText(price))
        .build()
      ..layout(ui.ParagraphConstraints(width: pw));
    cvs.drawParagraph(pp, ui.Offset(nw + qw, 0));

    final img = await rec.endRecording().toImage(w, lh);
    final bd = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    return bd == null ? [] : _toBitmap(bd.buffer.asUint8List(), w, lh);
  }

  // Render QR as ESC/POS raster bitmap (GS v 0) — works on all ESC/POS printers
  List<int> _qrBitmap(String data) {
    const scale = 8; // dots per QR module
    const quietZone = 3; // quiet zone in modules

    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.L,
    );
    final qrImage = QrImage(qrCode);

    final modules = qrImage.moduleCount;
    final totalModules = modules + quietZone * 2;
    final pixelSize = totalModules * scale;

    // Width must be a multiple of 8 (one byte = 8 horizontal dots)
    final widthBytes = (pixelSize + 7) ~/ 8;
    final heightDots = pixelSize;

    final bitmap = <int>[];
    for (int row = 0; row < heightDots; row++) {
      for (int byteIdx = 0; byteIdx < widthBytes; byteIdx++) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          final x = byteIdx * 8 + bit;
          final moduleX = (x ~/ scale) - quietZone;
          final moduleY = (row ~/ scale) - quietZone;
          final dark = moduleX >= 0 &&
              moduleX < modules &&
              moduleY >= 0 &&
              moduleY < modules &&
              qrImage.isDark(moduleY, moduleX);
          if (dark) byte |= (0x80 >> bit);
        }
        bitmap.add(byte);
      }
    }

    // ESC a 1 = center; GS v 0 m xL xH yL yH bitmap; ESC a 0 = left
    return [
      0x1B,
      0x61,
      0x01,
      0x1D,
      0x76,
      0x30,
      0x00,
      widthBytes & 0xFF,
      (widthBytes >> 8) & 0xFF,
      heightDots & 0xFF,
      (heightDots >> 8) & 0xFF,
      ...bitmap,
      0x1B,
      0x61,
      0x00,
    ];
  }

  String _numStr(dynamic v) {
    if (v == null) return '0';
    final n = v is num ? v.toDouble() : (double.tryParse(v.toString()) ?? 0);
    return intl.NumberFormat('#,##0', 'en_US').format(n);
  }

  Future<bool> isBluetoothReady() async => await _waitForBluetooth();

  Future connect(BluetoothInfo device) async {
    setloading(true);
    try {
      final connected = await PrintBluetoothThermal.connect(macPrinterAddress: device.macAdress);
      connectedDevice = device;
      notifyListeners();
      if (connected) {
        messageComplete('${device.name} нэртэй төхөөрөмж амжилттай холбогдоо');
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      setloading(false);
    }
  }
}
