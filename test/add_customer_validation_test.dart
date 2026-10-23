import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/application/application.dart';
import 'package:pharmo_app/roles/seller/customer/add_customer.dart';

void main() {
  Future<PharmProvider> pumpForm(WidgetTester tester, {CustomerDetail? customer}) async {
    final pharm = PharmProvider();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: pharm),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: MaterialApp(home: CustomerFormScreen(customer: customer)),
    ));
    await tester.pumpAndSettle();
    // As if the zone list had loaded.
    pharm.zones = [Zone(id: 1, name: 'Төв')];
    pharm.notifyListeners();
    await tester.pumpAndSettle();
    return pharm;
  }

  Future<void> submit(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  // Fields in order: register, name, phone, email, [phone 2, phone 3,] note.
  Finder field(int i) => find.byType(TextFormField).at(i);

  group('registering', () {
    testWidgets('submitting empty marks what the API requires, and the zone', (tester) async {
      await pumpForm(tester);
      await submit(tester, 'Бүртгэх');

      expect(find.text('Регистрийн дугаар оруулна уу'), findsOneWidget);
      expect(find.text('Нэр оруулна уу'), findsOneWidget);
      expect(find.text('Утасны дугаараа оруулна уу'), findsOneWidget);
      expect(find.text('Харилцагчийн бүсийг сонгоно уу'), findsOneWidget);
      // Email is optional for the API.
      expect(find.text('И-мейл хаягаа оруулна уу'), findsNothing);
      expect(find.text('Бүртгэл гүйцээнээ үү!'), findsNothing);
    });

    testWidgets('a field’s error clears once it is filled in', (tester) async {
      await pumpForm(tester);
      await submit(tester, 'Бүртгэх');

      await tester.enterText(field(1), 'Эмийн сан');
      await tester.pumpAndSettle();
      expect(find.text('Нэр оруулна уу'), findsNothing);
      expect(find.text('Регистрийн дугаар оруулна уу'), findsOneWidget);
    });

    testWidgets('a filled-in field is checked for format', (tester) async {
      await pumpForm(tester);
      await tester.enterText(field(2), '123');
      await tester.enterText(field(3), 'not-an-email');
      await submit(tester, 'Бүртгэх');

      expect(find.text('Утасны дугаар 8 оронтой байх ёстой!!'), findsOneWidget);
      expect(find.text('Имэйл хаяг буруу байна!'), findsOneWidget);
    });
  });

  group('editing', () {
    final customer = CustomerDetail(
      id: 7,
      name: 'Эм Импекс',
      rn: '1234567',
      phone: '99112233',
      phone2: '88112233',
      email: 'info@example.mn',
    );

    testWidgets('opens filled in, with the extra phones and no zone', (tester) async {
      await pumpForm(tester, customer: customer);

      expect(find.text('Харилцагч засах'), findsOneWidget);
      expect(find.text('Хадгалах'), findsOneWidget);
      expect(find.text('Эм Импекс'), findsOneWidget);
      expect(find.text('88112233'), findsOneWidget);
      expect(find.text('Бүс сонгоно уу'), findsNothing);
    });

    testWidgets('emptying a required field marks it red', (tester) async {
      await pumpForm(tester, customer: customer);
      await tester.enterText(field(1), '');
      await tester.enterText(field(4), '12');
      await submit(tester, 'Хадгалах');

      expect(find.text('Нэр оруулна уу'), findsOneWidget);
      expect(find.text('Утасны дугаар 8 оронтой байх ёстой!!'), findsOneWidget);
      expect(find.text('Регистрийн дугаар оруулна уу'), findsNothing);
    });
  });
}
