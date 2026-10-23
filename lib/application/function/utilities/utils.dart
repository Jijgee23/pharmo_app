import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/authentication/root/root_provider.dart';

Future<T?> goto<T>(Widget widget) async {
  final res = await Get.to(
    widget,
    curve: Curves.fastLinearToSlowEaseIn,
    transition: Transition.rightToLeft,
  );

  return res as T;
}

Future gotoRemoveUntil(Widget widget) async {
  await Get.offAll(
    widget,
    curve: Curves.fastLinearToSlowEaseIn,
    transition: Transition.rightToLeft,
  );
}

Future gotoRootPage() async {
  final rooter = Get.context!.read<RootProvider>();
  await rooter.readUser().then(
    (val) async {
      await Get.offAllNamed('/root');
    },
  );
}

double parseDouble(dynamic value) {
  if (value == null) {
    return 0;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is String) {
    return double.parse(value);
  }
  if (value is double) {
    return value;
  }
  return value;
}

int parseInt(dynamic value) {
  if (value == null) {
    return 0;
  } else if (value is double) {
    return value.round();
  } else if (value is String) {
    return int.parse(value);
  }
  {
    return value;
  }
}

String toPrice(dynamic v) {
  // 1. Null эсвэл хоосон утга шалгах
  if (v == null || v.toString().trim().isEmpty) {
    return '0.00₮';
  }

  try {
    double numberValue;

    // 2. Төрөл хөрвүүлэлт
    if (v is num) {
      numberValue = v.toDouble();
    } else {
      // String болон бусад төрлийг parse хийх
      numberValue = double.tryParse(v.toString()) ?? 0.0;
    }

    // 3. Форматлах: '#,##0.00' нь ямагт 2 оронтой бутархайг харуулна
    final formatter = intl.NumberFormat('#,##0.00', 'en_US');
    return '${formatter.format(numberValue)}₮';
  } catch (e) {
    return '0.00₮';
  }
}

status(String status) {
  switch (status) {
    case "W":
      return 'Төлбөр хүлээгдэж буй';
    case "P":
      return 'Төлбөр төлөгдсөн';
    case "S":
      return 'Цуцлагдсан';
    case "C":
      return 'Биелсэн';
    default:
      return 'Тодорхойгүй';
  }
}

checker(Map response, String key) {
  if (response.containsKey(key)) {
    return true;
  } else {
    return false;
  }
}

/// A server timestamp ("2026-06-18 09:14:00" or ISO 8601) in local time;
/// null when missing or unreadable.
DateTime? parseDateTime(String? raw) {
  if (raw == null) return null;
  final t = DateTime.tryParse(raw.trim());
  if (t == null) return null;
  return t.isUtc ? t.toLocal() : t;
}

/// "09:14".
String hourMinute(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "Өнөөдөр 09:14", "Өчигдөр 18:02" or "10.18 09:14".
String friendlyDateTime(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  final now = DateTime.now();
  final days =
      DateTime(now.year, now.month, now.day).difference(DateTime(t.year, t.month, t.day)).inDays;
  if (days == 0) return 'Өнөөдөр ${hourMinute(t)}';
  if (days == 1) return 'Өчигдөр ${hourMinute(t)}';
  return '${two(t.month)}.${two(t.day)} ${hourMinute(t)}';
}

String maybeNull(String? text) {
  if (text == null || text.isEmpty || text == 'null') {
    return '';
  } else {
    return text;
  }
}

String maybeNullToJson(String? text) {
  if (text == null || text.isEmpty || text == 'null') {
    return '';
  } else {
    return text;
  }
}

/// Makes [imageFile] meet the server's upload rules — at most 1MB, and a
/// jpeg, png or webp. Returned as is when it already does; otherwise
/// re-encoded as a JPEG at most 800px wide, in a file of its own so several
/// picks don't overwrite each other. Throws a [FormatException] for a format
/// it cannot read (e.g. HEIC).
Future<File> compressImage(File imageFile) async {
  final ext = imageFile.path.split('.').last.toLowerCase();
  const accepted = ['jpg', 'jpeg', 'png', 'webp'];
  if (isImageLessThan1MB(imageFile) && accepted.contains(ext)) return imageFile;

  final bytes = await imageFile.readAsBytes();
  img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
  if (image == null) throw const FormatException('Unsupported image format');
  if (image.width > 800) image = img.copyResize(image, width: 800);
  final stamp = DateTime.now().microsecondsSinceEpoch;
  return File('${imageFile.parent.path}/compressed_$stamp.jpg')
    ..writeAsBytesSync(img.encodeJpg(image, quality: 80));
}

/// Picks an image to upload, lets the user crop it freely, then makes it
/// meet the upload rules (see [compressImage]). Null when the user cancels
/// either step, or the image can't be read (they're told so).
Future<File?> pickUploadImage(ImageSource source) async {
  // Let the picker shrink camera-sized photos natively (and hand back JPEG
  // on iOS) before the crop screen loads them.
  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1600,
    imageQuality: 85,
  );
  if (picked == null) return null;

  final cropped = await ImageCropper().cropImage(
    sourcePath: picked.path,
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 85,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Зураг тайрах',
        toolbarColor: primary,
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: primary,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
        freeStyleCropEnabled: true,
      ),
      IOSUiSettings(
        title: 'Зураг тайрах',
        doneButtonTitle: 'Болсон',
        cancelButtonTitle: 'Болих',
        aspectRatioLockEnabled: false,
      ),
    ],
  );
  if (cropped == null) return null;

  try {
    return await compressImage(File(cropped.path));
  } on FormatException {
    messageWarning('Энэ төрлийн зургийг дэмжихгүй байна. JPG, PNG эсвэл WEBP зураг сонгоно уу.');
    return null;
  }
}

bool isImageLessThan1MB(File imageFile) {
  const int oneMBInBytes = 1 * 1024 * 1024;
  int fileSize = imageFile.lengthSync();
  return fileSize < oneMBInBytes;
}

Future<DateTime?> pickdate(BuildContext context,
    {DateTime? initial, DateTime? first, DateTime? end}) async {
  final DateTime? newDate = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: first ?? DateTime(2020),
    lastDate: end ?? DateTime(2040),
  );
  return newDate;
}
