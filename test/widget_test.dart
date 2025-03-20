import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coba/main.dart';

void main() {
  testWidgets('App should display login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
