import 'dart:typed_data';

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

  Future<void> printOrder(DeliveryOrder order, {int? deliveryId}) async {
    setloading(true);
    try {
      final bool connected = await PrintBluetoothThermal.connectionStatus;
      if (!connected) {
        messageWarning('Төхөөрөмж холбоно уу!');
        return;
      }
      final bytes = await generateTicket(order, deliveryId: deliveryId);
      final result = await PrintBluetoothThermal.writeBytes(bytes);
      print("print result: $result");
      if (result) {
        if (connectedDevice != null) await _saveMac(connectedDevice!);
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

  Future<List<int>> generateTicket(DeliveryOrder order, {int? deliveryId}) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    final user = Authenticator.security;
    final delmanName = user?.name ?? '';
    final customerName =
        order.orderer?.name ?? order.customer?.name ?? order.user?.name ?? 'Unknown';
    final dateStr =
        order.createdOn.length >= 10 ? order.createdOn.substring(0, 10) : order.createdOn;
    final nowStr = intl.DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    bytes += generator.reset();
    bytes += generator.setGlobalCodeTable('CP866');

    // Header
    bytes += generator.text('PHARMO',
        styles: PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    bytes +=
        generator.textEncoded(_mn('Захиалгын хуудас'), styles: PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    // Order meta
    bytes += generator.textEncoded(_r2('Захиалга', '#${order.orderNo}'));
    bytes += generator.textEncoded(_r2('Захиалгын огноо', dateStr));
    bytes += generator.textEncoded(_r2('Захиалагч', customerName));
    bytes += generator.textEncoded(_r2('Төлбөр', order.paymentType.name));
    bytes += generator.textEncoded(_r2('Түгээлт', '$delmanName (Тгг)'));
    bytes += generator.textEncoded(_r2('Түгээлтийн бүс', order.zone.name));
    bytes += generator.textEncoded(_r2('НӨАТ', '${_numStr(order.totalPrice * 0.1)}T'));
    if (deliveryId != null) {
      bytes += generator.textEncoded(_r2('Түгээлтийн №', '$deliveryId'));
    }
    bytes += generator.textEncoded(_r2('Баримтын огноо', nowStr));
    bytes += generator.hr();

    // Item header
    bytes += generator.textEncoded(_r3('Baraa', 'Too', 'Une'), styles: PosStyles(bold: true));
    bytes += generator.hr();

    for (final item in order.items) {
      final qtyNum = num.tryParse((item.qty).toString())?.toDouble() ?? 0;
      final total = num.tryParse((item.totalPrice).toString())?.toDouble() ?? 0;
      final unit = qtyNum > 0 ? total / qtyNum : 0.0;
      bytes += generator.textEncoded(_r3(
        (item.name).toString(),
        qtyNum.toStringAsFixed(0),
        '${_numStr(unit)}T',
      ));
    }

    bytes += generator.hr();

    // Totals
    bytes += generator.textEncoded(_r2('Нийт тоо', '${order.totalCount.toStringAsFixed(0)} ш'),
        styles: PosStyles(bold: true));
    bytes += generator.textEncoded(_r2('Нийт үнэ', '${_numStr(order.totalPrice)}T'),
        styles: PosStyles(bold: true));

    if (order.payments.isNotEmpty) {
      bytes += generator.hr();
      for (final p in order.payments) {
        bytes += generator.textEncoded(_r2(p.payType, '${_numStr(p.amount)}T'));
      }
    }

    bytes += generator.hr();

    // Sign section
    bytes += generator.textEncoded(_r2('Хүлээлгэн өгсөн', delmanName));
    bytes += generator.textEncoded(_r2('Хүлээн авсан', '________________'));
    bytes += generator.textEncoded(_r2('Бүргүүлэх дүн', '${_numStr(order.totalPrice)}T'));

    bytes += generator.hr();

    // QR code as raster bitmap — works on any ESC/POS printer regardless of GS ( k support
    bytes += _qrBitmap('#${order.orderNo}|${_numStr(order.totalPrice)}T|$dateStr');

    bytes += generator.textEncoded(_mn('Баярлалаа!'),
        styles: PosStyles(bold: true, align: PosAlign.center));
    bytes += generator.feed(3);

    return bytes;
  }

  // ASCII-only bytes (numbers, symbols, prices)
  Uint8List _a(String text) => Uint8List.fromList(text.codeUnits);

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

  // Manual 2-col: label(16 left, CP866) | value(16 right, CP866) = 32 chars
  Uint8List _r2(String label, String value) {
    final lb = _mn(label);
    final vb = _mn(value);
    const w1 = 16, w2 = 16;
    final b1 = lb.length > w1 ? lb.sublist(0, w1) : lb;
    final b2 = vb.length > w2 ? vb.sublist(0, w2) : vb;
    return Uint8List.fromList([
      ...b1,
      ...List.filled(w1 - b1.length, 0x20),
      ...List.filled(w2 - b2.length, 0x20),
      ...b2,
    ]);
  }

  // Manual 3-col: name(16 left) | qty(5 right) | price(11 right) = 32 chars
  Uint8List _r3(String name, String qty, String price) {
    final nb = _mn(_sanitizeName(name));
    final qb = _a(qty);
    final pb = _a(price);
    const w1 = 16, w2 = 5, w3 = 11;
    final b1 = nb.length > w1 ? nb.sublist(0, w1) : nb;
    final b2 = qb.length > w2 ? qb.sublist(0, w2) : qb;
    final b3 = pb.length > w3 ? pb.sublist(0, w3) : pb;
    return Uint8List.fromList([
      ...b1,
      ...List.filled(w1 - b1.length, 0x20),
      ...List.filled(w2 - b2.length, 0x20),
      ...b2,
      ...List.filled(w3 - b3.length, 0x20),
      ...b3,
    ]);
  }

  // Encode a Mongolian/Cyrillic string to CP866 bytes.
  // Ө/Ү (unique to Mongolian) are not in CP866 — substitute with O/U.
  static const _cp866 = <int, int>{
    0x0410: 0x80, 0x0411: 0x81, 0x0412: 0x82, 0x0413: 0x83, 0x0414: 0x84,
    0x0415: 0x85, 0x0416: 0x86, 0x0417: 0x87, 0x0418: 0x88, 0x0419: 0x89,
    0x041A: 0x8A, 0x041B: 0x8B, 0x041C: 0x8C, 0x041D: 0x8D, 0x041E: 0x8E,
    0x041F: 0x8F, 0x0420: 0x90, 0x0421: 0x91, 0x0422: 0x92, 0x0423: 0x93,
    0x0424: 0x94, 0x0425: 0x95, 0x0426: 0x96, 0x0427: 0x97, 0x0428: 0x98,
    0x0429: 0x99, 0x042A: 0x9A, 0x042B: 0x9B, 0x042C: 0x9C, 0x042D: 0x9D,
    0x042E: 0x9E, 0x042F: 0x9F, 0x0430: 0xA0, 0x0431: 0xA1, 0x0432: 0xA2,
    0x0433: 0xA3, 0x0434: 0xA4, 0x0435: 0xA5, 0x0436: 0xA6, 0x0437: 0xA7,
    0x0438: 0xA8, 0x0439: 0xA9, 0x043A: 0xAA, 0x043B: 0xAB, 0x043C: 0xAC,
    0x043D: 0xAD, 0x043E: 0xAE, 0x043F: 0xAF, 0x0440: 0xE0, 0x0441: 0xE1,
    0x0442: 0xE2, 0x0443: 0xE3, 0x0444: 0xE4, 0x0445: 0xE5, 0x0446: 0xE6,
    0x0447: 0xE7, 0x0448: 0xE8, 0x0449: 0xE9, 0x044A: 0xEA, 0x044B: 0xEB,
    0x044C: 0xEC, 0x044D: 0xED, 0x044E: 0xEE, 0x044F: 0xEF,
    0x0401: 0xF0, 0x0451: 0xF1, // Ё ё
    // Mongolian-specific substitutions mapped to nearest CP866 equivalents
    0x04E8: 0x8E, // Ө → О (0x041E)
    0x04E9: 0xAE, // ө → о (0x043E)
    0x04AE: 0x93, // Ү → У (0x0423)
    0x04AF: 0xE3, // ү → у (0x0443)
  };

  // Keep only ASCII printable and Cyrillic; strip everything else (®, ™, emojis, etc.)
  String _sanitizeName(String text) {
    final buf = StringBuffer();
    for (final rune in text.runes) {
      if ((rune >= 0x20 && rune <= 0x7E) || (rune >= 0x0400 && rune <= 0x04FF)) {
        buf.writeCharCode(rune);
      }
    }
    return buf.toString();
  }

  Uint8List _mn(String text) {
    final out = <int>[];
    for (final rune in text.runes) {
      if (rune < 0x80) {
        out.add(rune);
      } else {
        final byte = _cp866[rune];
        if (byte != null) out.add(byte); // skip truly unknown chars silently
      }
    }
    return Uint8List.fromList(out);
  }

  String _numStr(dynamic v) {
    if (v == null) return '0';
    final n = v is num ? v.toDouble() : (double.tryParse(v.toString()) ?? 0);
    return intl.NumberFormat('#,##0', 'en_US').format(n);
  }

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
