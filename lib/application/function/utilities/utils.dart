import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart' as intl;
import 'package:image/image.dart' as img;
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/views/auth/root/root_provider.dart';

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
  await rooter.readUser().then((val) async {
    await Get.offAllNamed(
      '/root',
      // curve: Curves.fastLinearToSlowEaseIn,
      // transition: Transition.rightToLeft,
    );
  });
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

process(String status) {
  switch (status) {
    case "D":
      return 'Хүргэгдсэн';
    case "C":
      return 'Хаалттай';
    case "R":
      return 'Буцаагдсан';
    case "O":
      return 'Түгээлтэнд гарсан';
    case "N":
      return 'Шинэ';
    case "P":
      return 'Бэлэн болсон';
    case "Т":
      return 'Бэлтгэж эхлэсэн';
    case "A":
      return 'Хүлээн авсан';
    default:
      return 'Тодорхойгүй';
  }
}

getProcessGif(String process) {
  if (process == 'Шинэ') {
    return 'assets/stickers/hourglass.gif';
  } else if (process == 'Бэлтгэж эхэлсэн') {
    return 'assets/stickers/box.gif';
  } else if (process == 'Бэлэн болсон') {
    return 'assets/stickers/delivery-service.gif';
  } else if (process == 'Түгээлтэнд гарсан') {
    return 'assets/stickers/truck_animation.gif';
  } else if (process == 'Хүлээн авсан') {
    return 'assets/stickers/delivery-completed.gif';
  } else {
    return 'assets/stickers/hourglass.gif';
  }
}

getStatusGif(String status) {
  if (status == 'Төлбөр хүлээгдэж буй') {
    return 'assets/stickers/payment-time.gif';
  } else if (status == 'Төлбөр төлөгдсөн') {
    return 'assets/stickers/credit-card.gif';
  } else if (status == 'Цуцлагдсан') {
    return 'assets/stickers/delivery-service.gif';
  } else if (status == 'Биелсэн') {
    return 'assets/stickers/verified.gif';
  } else {
    return 'assets/stickers/hourglass.gif';
  }
}

getPayType(String status) {
  if (status == 'L') {
    return 'Зээлээр';
  } else if (status == 'C') {
    return 'Бэлнээр';
  } else if (status == 'T') {
    return 'Дансаар';
  } else {
    return 'Тодорхой биш';
  }
}

checker(Map response, String key) {
  if (response.containsKey(key)) {
    return true;
  } else {
    return false;
  }
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

String getDate(DateTime date) {
  return date.toString().substring(0, 10);
}

Future<File> compressImage(File imageFile) async {
  File? result;
  if (isImageLessThan1MB(imageFile)) {
    result = imageFile;
  } else {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
    image = img.copyResize(image!, width: 800);
    int quality = 80;
    List<int> compressedBytes = img.encodeJpg(image, quality: quality);
    File compressedImage = File('${imageFile.parent.path}/compressed_image.jpg')
      ..writeAsBytesSync(compressedBytes);
    print('Original size: ${imageFile.lengthSync()} bytes');
    print('Compressed size: ${compressedImage.lengthSync()} bytes');
    result = compressedImage;
  }
  return result;
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
    builder: (context, child) {
      return datePickerTheme(context, child);
    },
  );
  return newDate;
}

Theme datePickerTheme(BuildContext context, Widget? child) {
  return Theme(
    data: Theme.of(context).copyWith(
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: white,
        onSurface: black,
      ),
      scaffoldBackgroundColor: white,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
    ),
    child: child!,
  );
}
