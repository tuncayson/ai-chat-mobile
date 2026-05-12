import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('placeholder app renders title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('AI Chat')),
        ),
      ),
    );

    expect(find.text('AI Chat'), findsOneWidget);
  });
}
