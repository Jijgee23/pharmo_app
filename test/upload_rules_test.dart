import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pharmo_app/application/function/api/api.dart';
import 'package:pharmo_app/application/function/utilities/utils.dart';

void main() {
  group('apiErrorMessage', () {
    test('reads the shapes the API answers errors in', () {
      expect(apiErrorMessage('Бүртгэлгүй имэйл хаяг байна!'), 'Бүртгэлгүй имэйл хаяг байна!');
      expect(apiErrorMessage({'product_id': ['Product not found!']}), 'Product not found!');
      expect(apiErrorMessage(['Бүртгэлтэй имэйл хаяг байна!']), 'Бүртгэлтэй имэйл хаяг байна!');
    });

    test('null when there is nothing to show', () {
      expect(apiErrorMessage(''), isNull);
      expect(apiErrorMessage(<String, dynamic>{}), isNull);
      expect(apiErrorMessage(null), isNull);
    });
  });

  group('compressImage', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('upload_rules'));
    tearDown(() => dir.deleteSync(recursive: true));

    File write(String name, List<int> bytes) => File('${dir.path}/$name')..writeAsBytesSync(bytes);

    test('keeps a small jpeg/png/webp as is', () async {
      final png = write('a.png', img.encodePng(img.Image(width: 20, height: 20)));
      expect((await compressImage(png)).path, png.path);
    });

    test('re-encodes other formats to a JPEG of its own per image', () async {
      final bmp = img.encodeBmp(img.Image(width: 20, height: 20));
      final first = await compressImage(write('a.bmp', bmp));
      final second = await compressImage(write('b.bmp', bmp));
      expect(first.path, endsWith('.jpg'));
      expect(second.path, isNot(first.path));
      expect(first.existsSync() && second.existsSync(), isTrue);
    });

    test('shrinks an oversized image to at most 800px wide, under 1MB', () async {
      final noisy = img.Image(width: 2400, height: 1600);
      for (final p in noisy) {
        p.setRgb((p.x * 7) % 256, (p.y * 13) % 256, (p.x * p.y) % 256);
      }
      final big = write('big.png', img.encodePng(noisy, level: 0));
      expect(isImageLessThan1MB(big), isFalse);
      final out = await compressImage(big);
      expect(img.decodeJpg(out.readAsBytesSync())!.width, 800);
      expect(isImageLessThan1MB(out), isTrue);
    });

    test('refuses a format it cannot read', () async {
      final heic = write('a.heic', List.filled(64, 7));
      expect(() => compressImage(heic), throwsFormatException);
    });
  });
}
