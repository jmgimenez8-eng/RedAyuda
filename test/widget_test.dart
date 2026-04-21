import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:redayuda/main.dart';

void main() {
  testWidgets('App arranca correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: RedAyudaApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}