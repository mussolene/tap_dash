import 'package:flutter_test/flutter_test.dart';
import 'package:tap_dash/main.dart';
import 'package:tap_dash/widgets/color_button.dart';

void main() {
  testWidgets('Color Sequence Game displays initial UI', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Color Sequence Game'), findsOneWidget);
    expect(find.text('Score: 0'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('Game has four color buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final colorButtons = find.byType(ColorButton);
    expect(colorButtons, findsNWidgets(4));
  });
}
