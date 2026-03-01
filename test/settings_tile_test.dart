import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_dash/widgets/settings_tile.dart';

void main() {
  testWidgets('SettingsTile displays title and switch', (WidgetTester tester) async {
    var value = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsTile(
            title: 'Test Setting',
            value: value,
            onChanged: (v) => value = v,
          ),
        ),
      ),
    );

    expect(find.text('Test Setting'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('SettingsTile Switch toggles on tap', (WidgetTester tester) async {
    var value = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsTile(
            title: 'Toggle',
            value: value,
            onChanged: (v) => value = v,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(value, isFalse);
  });

  testWidgets('SettingsTileSelector displays title and subtitle', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsTileSelector<String>(
            title: 'Pick',
            value: 'a',
            options: const ['a', 'b'],
            labelBuilder: (s) => s.toUpperCase(),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Pick'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('SettingsTileSelector opens bottom sheet on tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsTileSelector<String>(
            title: 'Pick Option',
            value: 'x',
            options: const ['x', 'y'],
            labelBuilder: (s) => s,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(SettingsTileSelector<String>));
    await tester.pumpAndSettle();

    expect(find.text('Pick Option'), findsWidgets);
    expect(find.text('x'), findsWidgets);
    expect(find.text('y'), findsWidgets);
  });

  testWidgets('SettingsTile displays title and switch when value false',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsTile(
            title: 'Off',
            value: false,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('Off'), findsOneWidget);
  });

  testWidgets('SettingsTileSelector onChanged called when option selected',
      (WidgetTester tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsTileSelector<String>(
            title: 'Pick',
            value: 'a',
            options: const ['a', 'b'],
            labelBuilder: (s) => s,
            onChanged: (v) => selected = v,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(SettingsTileSelector<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('b').last);
    await tester.pumpAndSettle();

    expect(selected, 'b');
  });
}
