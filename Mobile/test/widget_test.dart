import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:excelerate_app/main.dart';

void main() {
  testWidgets('Excelerate app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExcelerateApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
