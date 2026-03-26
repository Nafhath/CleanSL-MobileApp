import 'package:cleansl_app/shared/widgets/cleansl_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CleanSlButton renders its label text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CleanSlButton(
            text: 'Tap Me',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Tap Me'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('CleanSlButton onPressed is called when tapped', (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CleanSlButton(
            text: 'Submit',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
