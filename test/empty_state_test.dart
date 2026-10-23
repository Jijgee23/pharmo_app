import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmo_app/widgets/others/empty_state.dart';

void main() {
  Finder content() => find
      .descendant(of: find.byType(EmptyState), matching: find.byType(Column))
      .first;

  testWidgets('centers itself in the space an Expanded gives it', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 120),
            Expanded(child: EmptyState(icon: Icons.inbox, title: 'Хоосон')),
          ],
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final area = tester.getRect(find.byType(EmptyState));
    final box = tester.getRect(content());
    expect((box.center.dy - area.center.dy).abs(), lessThan(1));
    expect((box.center.dx - area.center.dx).abs(), lessThan(1));
  });

  testWidgets('padding shifts the centre clear of a floating bar', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: EmptyState(
          icon: Icons.inbox,
          title: 'Хоосон',
          padding: EdgeInsets.only(bottom: 100),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final area = tester.getRect(find.byType(EmptyState));
    final box = tester.getRect(content());
    expect((box.center.dy - (area.center.dy - 50)).abs(), lessThan(1));
  });

  testWidgets('an empty list can still be pulled to refresh', (tester) async {
    var refreshed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async => refreshed = true,
          child: const EmptyState(icon: Icons.inbox, title: 'Хоосон'),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.fling(find.text('Хоосон'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(refreshed, isTrue);
  });

  testWidgets('sizes to its content inside a scroll view', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListView(
          children: const [EmptyState(icon: Icons.inbox, title: 'Хоосон')],
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Хоосон'), findsOneWidget);
  });

  testWidgets('shows the action only with both a label and a callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EmptyState(
          icon: Icons.inbox,
          title: 'Хоосон',
          actionLabel: 'Дахин ачаалах',
          onAction: () => tapped = true,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Дахин ачаалах'));
    expect(tapped, isTrue);
  });
}
