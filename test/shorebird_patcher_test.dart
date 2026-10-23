import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/application/settings/services/shorebird_patcher.dart';

void main() {
  Future<void> openDialog(WidgetTester tester, {required bool preview}) async {
    await tester.pumpWidget(GetMaterialApp(
      navigatorKey: GlobalKeys.navigatorKey,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => ShorebirdPatcher.restartDialog(preview: preview),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('the debug preview is marked as a test, and its button only closes it',
      (tester) async {
    await openDialog(tester, preview: true);
    expect(find.text('ТЕСТ · debug build'), findsOneWidget);

    await tester.tap(find.text('Дахин эхлүүлэх'));
    // Long enough for the dialog to close, well before the toast times out.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Шинэчлэлт бэлэн боллоо'), findsNothing);
    expect(find.text('Тест: жинхэнэ шинэчлэлтийн үед апп энд дахин эхэлнэ.'), findsOneWidget);

    // Let the toast's own timers run out.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('the real dialog carries no test badge and stays up', (tester) async {
    await openDialog(tester, preview: false);
    expect(find.text('Шинэчлэлт бэлэн боллоо'), findsOneWidget);
    expect(find.text('ТЕСТ · debug build'), findsNothing);

    // Neither a tap outside nor back closes it.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Шинэчлэлт бэлэн боллоо'), findsOneWidget);
  });
}
