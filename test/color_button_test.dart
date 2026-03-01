import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tap_dash/widgets/color_button.dart';

void main() {
  testWidgets('ColorButton shows with isHighlighted', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ColorButton(
            color: Colors.red,
            isHighlighted: true,
            showCorrectFlash: false,
            size: 80,
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.byType(ColorButton), findsOneWidget);
  });

  testWidgets('ColorButton shows with showCorrectFlash', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ColorButton(
            color: Colors.green,
            isHighlighted: false,
            showCorrectFlash: true,
            size: 80,
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.byType(ColorButton), findsOneWidget);
  });

  testWidgets('ColorButton onTap called when tapped', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ColorButton(
            color: Colors.blue,
            isHighlighted: false,
            size: 80,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ColorButton));
    await tester.pump(const Duration(milliseconds: 150));

    expect(tapped, isTrue);
  });
}
